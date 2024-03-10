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



class SearchViewModel {
    
    // MARK: Input
    var searchTextOb: Observable<SearchModel?> = Observable(nil)
    var currentPage: Observable<Int?> = Observable(nil)
    // MARK: Output
    var outPutModel: Observable<[Document]?> = Observable([])
    var outPutError: Observable<URLSessionManagerError?> = Observable(nil)
    
    // Static
    var endPage: Int?
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
    
    private func requestText(_ model: SearchModel) {
        URLSessionManager.shared.fetch(type: KakaoLocalModel.self, api: KakaoApiModel.keywordLocation(text: model.searchText, page: currentPage.value ?? 1, x: model.long, y: model.lat)) {
            [weak self] result in
            guard let self else {return}
            switch result{
            case .success(let data):
                endPage = data.meta.pageableCount
                print("마지막 페이지",endPage ?? "")
                outPutModel.value?.append(contentsOf: data.documents)
            case .failure(let fail):
                outPutError.value = fail
            }
        }
    }
    
    deinit {
        print("사라질께요!", self)
    }
    
}
