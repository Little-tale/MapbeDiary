//
//  URLSessionManager.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import Foundation

// MARK: URLSessionManger SingleTone Patton
@available(*, deprecated, renamed: "NetworkManager", message: "Use NetworkManager instead.")
final class URLSessionManager {
    private init() {}
    static let shared = URLSessionManager()
    
    // MARK: 각 데이터 모델, API 모델을 통해 에러와 결과를 동시에
    /// Decodable을 채택한 모델을 통해 통신합니다. api는 ApiTypeError 를 구현하고 있어야 합니다.
    func fetch<T:Decodable>(type: T.Type, api: APIType, completionHandler: @escaping(RequestResults<T>) -> Void){
        makeRequest(api: api) { componentsResults in
            switch componentsResults {
            case .success(let success):
                
                    URLSession.shared.dataTask(with: success) {  [weak self]  data, response, error in
                        guard let self else { return }
                        
                        let errorCase = requestErrorTester(type: type,api: api, data: data, response: response, error: error)
                        
                        switch errorCase{
                        case .success(let sucsess):
                            DispatchQueue.main.async{
                                completionHandler(.success(sucsess))
                            }
                        case .failure(let failler):
                            DispatchQueue.main.async{
                                completionHandler(.failure(failler))
                            }
                        }
                    }.resume()
                    
            case .failure(let failure):
                completionHandler(.failure(failure))
            }
        }
    }
    
    
    
    
    //MARK: 요청 에러 테스터
    /// 에러존재 여부 응답 여부, 데이터 유무, 응답코드에 대응하는 오류가 있는지 확인합니다.
    private func requestErrorTester<T:Decodable>(type: T.Type, api: APIType, data: Data?, response: URLResponse?, error: Error?) -> RequestResults<T>{
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
    private func findErrorCodeOfCase<T: APIType>(type:T, stateCode: Int) -> NetworkManagerError?{
        print(#function)
        let errorCase = type.errorCodeCase(stateCode: stateCode)
        
        if let errorCase {
            return NetworkManagerError.apiError(errorCase)
        }
        return nil
    }
    
    
    //MARK: urlComponents 만드는 메서드
    /// urlCompocents를 생성합니다 실패시 에러를 URLSessinError 를 던집니다.
    private func makeRequest(api: APIType, completionHandler:  @escaping(componentsResults) -> Void){
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
            completionHandler(.success(urlRequst))
        case .failure(let failure):
            completionHandler(.failure(failure))
        }
    }
    
    //MARK: URL Requst 생성 메서드
    /// URL Requset 만드는 메서드
    private func makeUrlRequest(components: URLComponents) -> Result<URL, NetworkManagerError> {
        print(#function)
        guard let url = components.url else {
            return .failure(.componentsError)
        }
        return .success(url)
    }
}
