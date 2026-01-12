//
//  URLSessionManagerForConcurrency.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 5/8/24.
//

import Foundation

@available(*, deprecated, renamed: "URLSessionManager", message: "use URLSessionManager")
final class URLSessionManagerForConcurrency {
    
    private
    init() {}
    
    private
    let jsDecoding: JSONDecoder = {
        let decode = JSONDecoder()
        decode.keyDecodingStrategy = .useDefaultKeys
        return decode
    }()
    
    static
    let shared = URLSessionManagerForConcurrency()
    
    func fetch<T:Decodable>(type: T.Type, apiType: APIType) async throws -> T {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = apiType.scheme ?? "https" // 에러 V
        urlComponents.host = apiType.host
        urlComponents.path = apiType.path
        urlComponents.queryItems = apiType.query
        
        guard let url = urlComponents.url else {
            throw NetworkManagerError.componentsError
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = apiType.header
        urlRequest.httpMethod = apiType.method
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let response = response as? HTTPURLResponse else {
                throw NetworkManagerError.noResponse
            }
            
            if !(200..<300).contains(response.statusCode) {
                throw NetworkManagerError.cantStatusCoding
            }
            
            let decodeData = try jsDecoding.decode(type, from: data)
            
            return decodeData
            
        } catch {
            throw NetworkManagerError.failRequest
        }
       
        
    }
    
}
