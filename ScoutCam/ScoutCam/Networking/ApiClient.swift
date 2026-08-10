//
//  ApiClient.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/17/26.
//

import Foundation
import os

extension Logger {
    nonisolated static let apiClient = Logger(
        subsystem: "scout.scoutcam",
        category: "apiClient"
    )
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum APIError: Error {
    case invalidResponse
    case unauthorized
    case decodingError(Error)
    case encodingError(Error)
    case serverError(statusCode: Int, message: String?)
    case validationErrors([String: [String]])
    case offline
    case timeout
    case cancelled
    case transport(URLError)
}

actor ApiClient {
    private let baseUrl: URL
    private let session: URLSession
    private var authToken: String?
    private var tokenProvider: (() async throws -> String?)?

    init(baseUrl: URL, session: URLSession = .shared) {
        self.baseUrl = baseUrl
        self.session = session
    }

    func setAuthToken(_ token: String?) {
        authToken = token
    }

    func deleteAuthToken() {
        authToken = nil
    }

    func setTokenProvider(_ provider: @escaping () async throws -> String?) {
        tokenProvider = provider
    }
    
    // For no request body but response body
    func request<Response: Decodable>(
        _ endpoint: any ApiEndpoint
    ) async throws -> Response {
        let data = try await execute(endpoint.path, method: endpoint.method, bodyData: nil, queryItems: endpoint.queryItems)
        return try decode(data)
    }

    // For request body and response
    func request<Body: Encodable, Response: Decodable>(
        endpoint: any ApiEndpoint,
        body: Body
    ) async throws -> Response {
        let data = try await execute(endpoint.path, method: endpoint.method, bodyData: encode(body), queryItems: endpoint.queryItems)
        return try decode(data)
    }

    // For request body but no response body
    func request<Body: Encodable>(endpoint: any ApiEndpoint, body: Body) async throws {
        _ = try await execute(endpoint.path, method: endpoint.method, bodyData: encode(body), queryItems: endpoint.queryItems)
    }

    // For no request or response body
    func request(_ endpoint: any ApiEndpoint) async throws {
        _ = try await execute(endpoint.path, method: endpoint.method, bodyData: nil, queryItems: endpoint.queryItems)
    }

    // Used for requests that must not trigger the token provider (e.g. the refresh call itself).
    func requestUnauthenticated<Body: Encodable, Response: Decodable>(
        endpoint: any ApiEndpoint,
        body: Body
    ) async throws -> Response {
        let data = try await execute(endpoint.path, method: endpoint.method, bodyData: encode(body), queryItems: endpoint.queryItems, skipAuth: true)
        return try decode(data)
    }

    private func encode<Body: Encodable>(_ body: Body) throws -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            return try encoder.encode(body)
        } catch {
            throw APIError.encodingError(error)
        }
    }

    private func decode<Response: Decodable>(_ data: Data) throws -> Response {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    private func execute(
        _ endpoint: String,
        method: HTTPMethod,
        bodyData: Data?,
        queryItems: [URLQueryItem] = [],
        skipAuth: Bool = false
    ) async throws -> Data {
        let baseURL = baseUrl.appendingPathComponent(endpoint)
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        if !queryItems.isEmpty { components?.queryItems = queryItems }
        guard let url = components?.url else { throw APIError.invalidResponse }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        if let bodyData {
            urlRequest.httpBody = bodyData
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if !skipAuth {
            let token: String?
            if let provider = tokenProvider {
                token = try await provider()
            } else {
                token = authToken
            }
            if let token {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw APIError.offline
            case .timedOut:
                throw APIError.timeout
            case .cancelled:
                throw APIError.cancelled
            default:
                Logger.apiClient.error("Error making request to \(endpoint): \(urlError)")
                throw APIError.transport(urlError)
            }
        } catch {
            Logger.apiClient.error("Error making request to \(endpoint): \(error)")
            throw APIError.transport(URLError(.badServerResponse))
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            Logger.apiClient.error("Error server returned an invalid response.")
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw parseError(from: data, statusCode: httpResponse.statusCode)
        }

        return data
    }
    
    private func parseError(from data: Data, statusCode: Int) -> APIError {
        if statusCode == 401 {
            return .unauthorized
        }
        
        struct DetailError: Decodable { let detail: String? }
        if let detail = (try? JSONDecoder().decode(
            DetailError.self,
            from: data
        ))?.detail {
            return .serverError(statusCode: statusCode, message: detail)
        }
        
        if let fieldErrors = try? JSONDecoder().decode(
            [String: [String]].self,
            from: data
        ) {
            return .validationErrors(fieldErrors)
        }
        
        return .serverError(statusCode: statusCode, message: nil)
    }
}
