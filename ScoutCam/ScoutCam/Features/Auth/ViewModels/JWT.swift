//
//  JWT.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import Foundation

enum JWT {
    /// Returns the expiration date encoded in a JWT's `exp` claim, or nil if it can't be read.
    nonisolated static func expirationDate(from token: String) -> Date? {
        let segments = token.components(separatedBy: ".")
        guard segments.count == 3 else { return nil }

        var base64 = segments[1]   // the payload segment

        // JWT uses base64URL, which swaps a couple characters and drops padding.
        // Convert it back to standard base64 so Foundation can decode it.
        base64 = base64
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        // Re-pad to a multiple of 4 characters.
        while base64.count % 4 != 0 {
            base64 += "="
        }

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return nil
        }

        return Date(timeIntervalSince1970: exp)
    }

    nonisolated static func isExpired(_ token: String, leeway: TimeInterval = 30) -> Bool {
        guard let expiry = expirationDate(from: token) else {
            return true   // can't read it → treat as expired/invalid
        }
        // Subtract a small leeway so we refresh slightly early rather than
        // right as it expires mid-request.
        return Date() >= expiry.addingTimeInterval(-leeway)
    }
}
