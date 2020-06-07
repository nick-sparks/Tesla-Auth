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
            
            success()
        }, failure: failure)
    }
    
    private func makeAuthRequest(path: String, params: [String: String], success: @escaping () -> Void, failure: @escaping () -> Void) {
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
                        print("Error parsing data from auth response")
                    }
                    
                    self.authToken = authResult?.accessToken
                }
            }
            
            if (self.authToken != nil) {
                success()
                return
            }
            
            failure()
        })
        
        task.resume()
    }
}
