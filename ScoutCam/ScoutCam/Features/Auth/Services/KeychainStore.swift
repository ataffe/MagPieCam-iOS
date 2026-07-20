//
//  KeychainStore.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/19/26.
//
import Foundation
import Security

enum KeychainError: Error {
    case unableToSave(status: OSStatus)
    case unableToRead(status: OSStatus)
}

nonisolated struct KeychainStore {
    private let service: String
    
    init(service: String = Bundle.main.bundleIdentifier ?? "scout.scoutcam") {
        self.service = service
    }

    func save(_ value: String, for key: String) throws {
        let data = Data(value.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // Delete any existing item first
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.unableToSave(status: status)
        }
    }

    func read(_ key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil   // no token stored yet — a normal case, not an error
        }
        guard status == errSecSuccess else {
            throw KeychainError.unableToRead(status: status)
        }

        guard let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }

    func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
