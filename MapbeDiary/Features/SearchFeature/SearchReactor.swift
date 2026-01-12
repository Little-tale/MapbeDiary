//
//  SearchReactor.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import Foundation
import RxSwift
import ReactorKit

final class SearchReactor: Reactor {
    
    struct SearchViewPaged: Sendable {
        var currentPage: Int = 1
        var callItemCount: Int = 15
        var isEnd: Bool = false
    }
    
    struct State {
        var currentText = ""
        var pagedObj = SearchViewPaged()
        var searchResults: [PlaceDocumentEntity] = []
        var isLoading: Bool = false
        var errorModel: NetworkManagerError? = nil
        var isEmpty: Bool = true
    }
    
    enum Action {
        case search(currentText: String?)
        case loadNextPage

    }
    
    enum Mutation {
        case resetPaged
        case searchResults(results: [PlaceDocumentEntity], isAppend: Bool)
        case setLoading(Bool)
        case setPage(Int)
        case setEndPage(Bool)
        case apiError(NetworkManagerError?)
        case setCurrentText(String)
    }
    
    var initialState: State = State()
    
    private let coordinate: CoordinateEntity?
    
    init(
        coordinate: CoordinateEntity? = nil
    ) {
        self.coordinate = coordinate
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        let state = currentState
        
        switch action {
            
        case .loadNextPage:
            guard !state.isLoading else { return .empty() }
            guard !state.pagedObj.isEnd else { return .empty() }
            
            let next = state.pagedObj.currentPage + 1
            
            return .concat([
                .just(.setPage(next)),
                .just(.setLoading(true)),
                requestKeywordLocation(
                    page: next,
                    text: state.currentText,
                    x: coordinate?.latitude,
                    y: coordinate?.longitude,
                    append: true,
                )
                .throttle(
                    .milliseconds(100),
                    latest: false,
                    scheduler: MainScheduler.instance
                ),
                .just(.setLoading(false))
            ])
            
        case let .search(currentText: text):
            guard let text else {
                return .concat([
                    .just(.resetPaged),
                    .just(.setCurrentText(text ?? "")),
                    .just(.searchResults(results: [], isAppend: false))
                ])
            }
            
            
            return .concat([
                .just(.setCurrentText(text)),
                requestKeywordLocation(
                    page: state.pagedObj.currentPage,
                    text: text,
                    x: coordinate?.latitude,
                    y: coordinate?.longitude,
                    append: false
                )
            ])
        }
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .resetPaged:
            state.pagedObj = SearchViewPaged()
            
        case let .searchResults(result, isAppend):
            if isAppend {
                state.searchResults.append(contentsOf: result)
            } else {
                state.searchResults = result
                state.isEmpty = result.isEmpty
            }
            
        case let .setPage(page):
            state.pagedObj.currentPage = page

        case let .setLoading(isLoading):
            state.isLoading = isLoading
            
        case let .setCurrentText(text):
            state.currentText = text
            
        case let .apiError(error):
            state.errorModel = error
            
        case let .setEndPage(bool):
            state.pagedObj.isEnd = bool
        }
        
        return state
    }
}

// MARK: Network
extension SearchReactor {
    
    private func requestKeywordLocation(
        page: Int,
        text: String,
        x: Double? = nil,
        y: Double? = nil,
        append: Bool
    ) -> Observable<Mutation> {
        return .run(priority: .background) { send in
            if !append {
                await send(.resetPaged)
            }
            
            let result = await NetworkManager.fetch(type: KakaoLocalDTO.self, api: KakaoApiRouter.keywordLocation(
                text: text,
                page: page,
                x: x,
                y: y )
            )
            
            switch result {
            case let .success(dto):
                let mapping = KakaoMapper.toEntity(with: dto.documents)
                
                await send(.searchResults(results: mapping, isAppend: append))
                
                await send(.setEndPage(dto.meta.isEnd))
                
            case let .failure(error):
                await send(.apiError(error))
            }
            
        }
    }
}
