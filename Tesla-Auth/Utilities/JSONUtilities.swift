//
//  JSONUtilities.swift
//  Tesla-Auth
//
//  Created by Nick Sparks on 07/06/2020.
//  Copyright © 2020 Nick Sparks. All rights reserved.
//

import Foundation

private let jsonDecoder = JSONDecoder()

public func parseData<T: Decodable>(targetType: T.Type, data: Data, completion: (T?, Error?) -> Void) {
    do {
        
        let result = try jsonDecoder.decode(targetType.self, from: data)
        completion(result, nil)
    } catch {
        print("Error parsing data for: \(targetType), with error: \(error)")
        completion(nil, error)
    }
}
