//
//  NetworkHelper.swift
//  Movies
//
//  Created by Alexander Livshits on 14/03/2024.
//

import Foundation

class NetworkHelper {
    static func performNetworkRequest<T: Decodable>(url: URL, responseType: T.Type) async throws -> T {
        let headers = [
          "accept": "application/json",
          "Authorization": "Bearer \(Constants.apiToken)"
        ]

        let request = NSMutableURLRequest(url: url,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 5.0
        
        let (data, response) = try await URLSession.shared.data(for: request as URLRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "Invalid response", code: 0, userInfo: nil)
        }
                
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        let decodedResponse = try jsonDecoder.decode(T.self, from: data)
        return decodedResponse
    }
}
