//
//  NetworkHelper.swift
//  Movies
//
//  Created by Alexander Livshits on 14/03/2024.
//

import Foundation

class NetworkHelper {
    static func performNetworkRequest<T: Decodable>(url: URL, requestType: String = "GET", parameters: [String : Any]? = nil, responseType: T.Type) async throws -> T {
        let headers = [
          "accept": "application/json",
          "content-type": "application/json",
          "Authorization": "Bearer \(Constants.apiAccessToken)"
        ]
        
        let request = NSMutableURLRequest(url: url,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = requestType
        request.allHTTPHeaderFields = headers
        request.cachePolicy = .reloadRevalidatingCacheData
        request.timeoutInterval = 5.0
        
        if let parameters {
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = postData as Data
        }
        
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
