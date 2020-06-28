//
//  Auth.swift
//  Tesla-Auth
//
//  Created by Nick Sparks on 07/06/2020.
//  Copyright © 2020 Nick Sparks. All rights reserved.
//

import Foundation

struct AuthResponse: Decodable {
    var accessToken: String
    var refreshToken: String
    var expiresIn: Int
    var createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case createdAt = "created_at"
    }
}

enum AuthError: Error {
    case missingUsername
    case missingPassword
    case missingAccountData
    case requestFailure
    case missingAuthToken
}

enum AuthStorageKeys: String {
    case username = "username"
    case password = "password"
    case refreshToken = "refreshToken"
}

class Auth {
    
}
