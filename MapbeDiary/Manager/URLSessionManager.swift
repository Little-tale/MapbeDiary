//
//  URLSessionManager.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import Foundation

// MARK: API 타입 + 각 API의 에러 수집
protocol APIType{
    
    var query : [URLQueryItem]? {get} // API 쿼리
    
    var header : [String: String] {get} // API 헤더
    
    var method : String? {get} // API 메서드 정의 없으면 기본 GET
    
    var schem : String?{get} // url 스키마 정의 없으면 기본 "https:"
    
    var host: String {get} // url 호스트
    
    var path: String {get} // url path
    
    /// 에러코드에 따른 에러 케이스를 주셔야합니다.
    func errorCodeCase(stateCode: Int) -> ApiTypeError?
}

// MARK: API TypeError의 필수 요건
protocol ApiTypeError: Error {
    
    var errorCode: Int { get } // 에러코드에 따라 메시지가 반영됩니다.
    
    var message: String { get } // 이 메시지가 구현됩니다.
    
}

// MARK: URLSessinManger 에서 나올수 있는 대략적인 에러
enum URLSessionManagerError: Error{
    
    case nodata // 데이터가 없습니다.
    
    case noResponse // 응답이 없습니다.
    
    case errorResponseCode // 응답코드가 200이 아니며, 문서에도 없습니다.
    
    case failRequest // 요청을 실패합니다.
    
    case errorDecoding // 디코딩을 실패합니다.
    
    case cantStatusCoding // 상태 코드로 변경할수 없습니다.
    
    case componatsError // 컴포넌츠 변경에 문제가 발생했습니다.
    
    case unknownError // 예상치 못한 경우 입니다.
    
    case apiError(ApiTypeError) // API 관련 에러입니다.
    
    // MARK: 출시일때는 수정해야함.
    var errorMessage: String {
        switch self {
        case .nodata:
            return "API_error_Response".localized
        case .noResponse:
            return"API_error_Response".localized
        case .errorResponseCode:
            return "API_error_Response".localized
        case .failRequest:
            return "API_error_Request".localized
        case .errorDecoding:
            return "API_error_Response".localized
        case .cantStatusCoding:
            return "API_error_Response".localized
        case .componatsError:
            return "API_error_Response".localized
        case .unknownError:
            return "API_error_Response".localized
        case .apiError(let apiTypeError):
            return apiTypeError.message
        }
    }
    
}

typealias requestResults<T:Decodable> = Result<T,URLSessionManagerError>

typealias componentsResults = Result<URLRequest,URLSessionManagerError>

// MARK: URLSessionManger SingleTone Patton
final class URLSessionManager {
    private init() {}
    static let shared = URLSessionManager()
    
    // MARK: 각 데이터 모델, API 모델을 통해 에러와 결과를 동시에
    /// Decodable을 채택한 모델을 통해 통신합니다. api는 ApiTypeError 를 구현하고 있어야 합니다.
    func fetch<T:Decodable>(type: T.Type, api: APIType, compliteHandler: @escaping(requestResults<T>) -> Void){
        makeRequest(api: api) { componentsResults in
            switch componentsResults {
            case .success(let success):
                    URLSession.shared.dataTask(with: success) {  [weak self]  data, response, error in
                        guard let self else { return }
                        let errorCase = requestErrorTester(type: type,api: api, data: data, response: response, error: error)
                        switch errorCase{
                        case .success(let sucsess):
                            DispatchQueue.main.async{
                                compliteHandler(.success(sucsess))
                            }
                        case .failure(let failler):
                            DispatchQueue.main.async{
                                compliteHandler(.failure(failler))
                            }
                        }
                    }.resume()
                    
            case .failure(let failure):
                compliteHandler(.failure(failure))
            }
        }
    }
    //MARK: 요청 에러 테스터
    /// 에러존재 여부 응답 여부, 데이터 유무, 응답코드에 대응하는 오류가 있는지 확인합니다.
    private func requestErrorTester<T:Decodable>(type: T.Type, api: APIType, data: Data?, response: URLResponse?, error: Error?) -> requestResults<T>{
        print(#function)
        
        /// 에러가 가 존재합니다.
        guard error == nil else { return .failure(.failRequest)}
        /// 응답이 없습니다.
        guard let response else { return .failure(.noResponse)}
        // 데이터가 없습니다.
        guard let data else {return .failure(.nodata)}
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
    private func findErrorCodeOfCase<T: APIType>(type:T, stateCode: Int) -> URLSessionManagerError?{
        print(#function)
        let errorCase = type.errorCodeCase(stateCode: stateCode)
        
        if let errorCase {
            return URLSessionManagerError.apiError(errorCase)
        }
        return nil
    }
    
    
    //MARK: urlComponents 만드는 메서드
    /// urlCompocents를 생성합니다 실패시 에러를 URLSessinError 를 던집니다.
    private func makeRequest(api: APIType, compliteHandler:  @escaping(componentsResults) -> Void){
        print(#function)
        
        var urlComponents = URLComponents()
        urlComponents.scheme = api.schem ?? "https" // 에러 V
        urlComponents.host = api.host
        urlComponents.path = api.path
        urlComponents.queryItems = api.query
        
        let url = makeUrlRequest(components: urlComponents)
        switch url {
        case .success(let success):
            var urlRequst = URLRequest(url: success)
            urlRequst.allHTTPHeaderFields = api.header
            urlRequst.httpMethod = api.method
            compliteHandler(.success(urlRequst))
        case .failure(let failure):
            compliteHandler(.failure(failure))
        }
    }
    //MARK: URL Requst 생성 메서드
    /// URL Requset 만드는 메서드
    private func makeUrlRequest(components: URLComponents) -> Result<URL, URLSessionManagerError> {
        print(#function)
        guard let url = components.url else {
            return .failure(.componatsError)
        }
        return .success(url)
    }
    
}
