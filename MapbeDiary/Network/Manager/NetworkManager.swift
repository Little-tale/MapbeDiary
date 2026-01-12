//
//  NetworkManager.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import Foundation

typealias RequestResults<T:Decodable> = Result<T,NetworkManagerError>

typealias componentsResults = Result<URLRequest,NetworkManagerError>

struct NetworkManager {
    
    /// Network Fetch Function
    /// - Parameters:
    ///   - type: Decodable Type
    ///   - api: APIType
    /// - Returns: requestResults
    static func fetch<T:Decodable>(type: T.Type, api: APIType) async -> RequestResults<T> {
        let request = makeRequest(api: api)
        
        switch request {
        case .success(let success):
            
            do {
                let (data, response) = try await URLSession.shared.data(for: success)
                
                let errorCase = requestErrorTester(type: type, api: api, data: data, response: response, error: nil)
                
                switch errorCase {
                case .success(let success):
                    
                    return .success(success)
                    
                case .failure(let error):
                    
                    return .failure(error)
                }
            } catch {
                
                return .failure(.failRequest)
            }
        case .failure(let error):
            
            return .failure(error)
        }
    }
}

// MARK: Private Helpers
extension NetworkManager {
    
    private static func makeRequest(api: APIType) -> componentsResults {
        print(#function)

        var urlComponents = URLComponents()
        
        urlComponents.scheme = api.scheme ?? "https" // 에러 V
        urlComponents.host = api.host
        urlComponents.path = api.path
        urlComponents.queryItems = api.query
        
        let url = makeUrlRequest(components: urlComponents)
        switch url {
        case .success(let success):
            var urlRequst = URLRequest(url: success)
            urlRequst.allHTTPHeaderFields = api.header
            urlRequst.httpMethod = api.method
            
            return .success(urlRequst)
            
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    //MARK: URL Requst 생성 메서드
    /// URL Requset 만드는 메서드
    private static func makeUrlRequest(components: URLComponents) -> Result<URL, NetworkManagerError> {
        print(#function)
        guard let url = components.url else {
            return .failure(.componentsError)
        }
        return .success(url)
    }
    
    private static func requestErrorTester<T:Decodable>(type: T.Type, api: APIType, data: Data?, response: URLResponse?, error: Error?) -> RequestResults<T>{
        print(#function)
        
        /// 에러가 가 존재합니다.
        guard error == nil else { return .failure(.failRequest)}
        /// 응답이 없습니다.
        guard let response else { return .failure(.noResponse)}
        // 데이터가 없습니다.
        guard let data else {return .failure(.noData)}
        // 응답값이 없습니다.
        guard let response = response as? HTTPURLResponse else { return .failure(.cantStatusCoding)}
        
        // 에러코드가 존재합니다.
        if let error = findErrorCodeOfCase(type: api, stateCode: response.statusCode){
            return .failure(error)
        }
        // 에러코드에 해당한 사유는 없지만 200이 아닙니다.
        if response.statusCode != 200 {
            return .failure(.errorResponseCode)
        }
        
        do{
            let result = try JSONDecoder().decode(T.self, from: data)
            return .success(result)
        } catch {
            return .failure(.errorDecoding)
        }
    }
    
    //MARK:  에러코드를 찾아줍니다.
    /// 에라코드를 찾아줍니다.
    private static func findErrorCodeOfCase<T: APIType>(type:T, stateCode: Int) -> NetworkManagerError?{
        print(#function)
        let errorCase = type.errorCodeCase(stateCode: stateCode)
        
        if let errorCase {
            return NetworkManagerError.apiError(errorCase)
        }
        return nil
    }
}
