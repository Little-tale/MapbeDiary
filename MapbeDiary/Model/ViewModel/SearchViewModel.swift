//
//  SearchViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/10/24.
//

import Foundation

struct SearchModel {
    var searchText: String
    var long: Double // x
    var lat: Double // y
    
    init(searchText: String, long: Double, lat: Double) {
        self.searchText = searchText
        self.long = long
        self.lat = lat
    }
}



final class SearchViewModel {
    
    // MARK: Input
    var searchTextOb: Observable<SearchModel?> = Observable(nil)
    var currentPage: Observable<Int?> = Observable(nil)
    // MARK: Output
    var outPutModel: Observable<[Document]?> = Observable([])
    var outPutError: Observable<URLSessionManagerError?> = Observable(nil)
    
    // Static
    var endPageBool: Bool?
    var pageNation: Int = 15
    
    init(){
        searchTextOb.bind { [weak self] model in
            guard let self else { return }
            guard let model else { return }
            if model.searchText == "" { return }
            requestText(model)
        }
        currentPage.bind { [weak self] num in
            guard let self else { return }
            guard num != nil else {return}
            
            guard let data = searchTextOb.value else { return }
            if num == 1 { return }
            
            requestText(data)
        }
    }
    /*
     검색 쪽을 한번 Concurrency 로 변경해 보겠습니다.
     */
    
    private
    func requestText(_ model: SearchModel) {
        Task {
            do {
                let result = try await URLSessionManagerForConcurrency.shared.fetch(
                    type: KakaoLocalModel.self,
                    apiType: KakaoApiModel.keywordLocation(
                        text: model.searchText,
                        page: currentPage.value ?? 1,
                        x: model.long,
                        y: model.lat
                    )
                )
                endPageBool = result.meta.isEnd
                outPutModel.value?.append(contentsOf: result.documents)
            } catch let error as URLSessionManagerError {
                outPutError.value = error
            } catch {
                outPutError.value = .unknownError
            }
        }
    }
    
    
    deinit {
        print("SearchViewModel: Deinit")
    }
    
}
