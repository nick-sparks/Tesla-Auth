//
//  AuthDataSource.swift
//  Tesla-Auth
//
//  Created by Nick Sparks on 07/06/2020.
//  Copyright © 2020 Nick Sparks. All rights reserved.
//

import Foundation

enum AuthEvent : String {
    case SUCCESS = "Success"
    case FAILURE = "Failure"
}

class AuthDataSource {
    private let AUTH_URL = "https://owner-api.teslamotors.com"
    private let CLIENT_ID = "81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384"
    private let CLIENT_SECRET = "c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3"
    
    var authResponse: AuthResponse?
    var authToken: String?
    
    static let shared = AuthDataSource()
    
    internal func isUserRegistered() -> Bool {
        if (self.authResponse != nil) {
            return true
        } else if let refreshToken = SecureStorage.shared.get(AuthStorageKeys.refreshToken.rawValue) {
            self.triggerRefreshToken(refreshToken: refreshToken)
            return self.authResponse != nil
        }
        
        return false
    }
    
    internal func getUsername() -> String {
        guard let username = SecureStorage.shared.get(AuthStorageKeys.username.rawValue) else {
            return ""
        }
        return username
    }
    
    internal func deregister() {
        self.authResponse = nil
        SecureStorage.shared.delete(AuthStorageKeys.username.rawValue)
        SecureStorage.shared.delete(AuthStorageKeys.refreshToken.rawValue)
    }

    internal func registerUser(username: String, password: String, success: @escaping () -> Void, failure: @escaping () -> Void) {
        let params = [
            "grant_type": "password",
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "email": username,
            "password": password
        ]
        
        self.makeAuthRequest(path: "oauth/token", params: params, success: {() -> Void in
            // Store the user data - it works!
            SecureStorage.shared.set(username, forKey: AuthStorageKeys.username.rawValue)
            SecureStorage.shared.set(self.authResponse!.refreshToken, forKey: AuthStorageKeys.refreshToken.rawValue)
            
            success()
        }, failure: failure)
    }
    
    private func triggerRefreshToken(refreshToken: String) {
        let semaphore = DispatchSemaphore(value: 0)
        let params = [
            "grant_type": "refresh_token",
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "refresh_token": refreshToken
        ]
        
        self.makeAuthRequest(path: "oauth/token", params: params, success: {() -> Void in
            print("Successfully refreshed access token")
            SecureStorage.shared.set(self.authResponse!.refreshToken, forKey: AuthStorageKeys.refreshToken.rawValue)
            semaphore.signal()
        }, failure: {() -> Void in
            print("Failed to refresh access token")
            semaphore.signal()
        })
        
        semaphore.wait()
    }
    
    private func makeAuthRequest(path: String, params: [String: String], success: @escaping () -> Void, failure: @escaping () -> Void) {
        self.authResponse = nil
        let urlParams = (params.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }) as Array).joined(separator: "&")
        
        let url: URL = URL(string: "\(self.AUTH_URL)/\(path)?\(urlParams)")!
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.httpMethod = "POST"
        
        var session: URLSession!
        let sessConfiguration = URLSessionConfiguration.default
        
        session = URLSession(configuration : sessConfiguration)
        
        let task = session.dataTask(with: request, completionHandler: {(responseData : Data?, response : URLResponse?, error : Error?) -> Void in
            if error != nil {
                print("Failed to download the auth response")
            } else {
                parseData(targetType: AuthResponse.self, data: responseData!) { (authResult, error) in
                    if (error != nil) {
                        print("Error parsing data from auth response " + error!.localizedDescription)
                    }
                    
                    self.authResponse = authResult
                }
            }
            
            if (self.authResponse != nil) {
                success()
                return
            }
            
            failure()
        })
        
        task.resume()
    }
}
