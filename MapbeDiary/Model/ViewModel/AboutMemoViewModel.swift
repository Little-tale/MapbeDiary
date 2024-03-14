//
//  AboutMemoViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/14/24.
//

import Foundation

struct AboutMemoModel {
    var memoText: String?
    var iamgeData: Data?
}

final class AboutMemoViewModel {
    
    //MARK: Input -------------
    
    // Modify
    let inputMemoInfo: Observable<DetailMemo?> = Observable(nil)

    let saveInput: Observable<Void?> = Observable(nil)
    
    //MARK: Output =============
   
    let repoErrorPut: Observable<RealmManagerError?> = Observable(nil)
    let successOutput: Observable<Void?> = Observable(nil)
    
    // static
    let repository = RealmRepository()
    
    var emptyModel = AboutMemoModel(memoText: nil, iamgeData: nil)
    
    // New 새로 생성시에는 이모델
    var inputLoactionInfo: LocationMemo?
    
    
    init(){
        // 새로 생길 상황의 로직
        saveInput.bind { [weak self] model in
            guard let self else { return }
            guard let model else { return }
            saveButtonAction()
            print("저장 버튼 액션 연결")
        }
    }
    
    private func memoInfoAction(_ location: LocationMemo) {
        
    }
    
    private func saveButtonAction() {
        print("location")
        let model = emptyModel
        
        guard let location = inputLoactionInfo else {
            return // 실패 메시지 뛰우기
        }
       
        guard let text = model.memoText else {
            return // 텍스트는 필수 라고 하기!
        }
        if text.trimmingCharacters(in: .whitespaces).isEmpty {
            return // 테스트는 필수라고 하기!
        }
        
        print("model")
        
        let results = repository.makeDetailMemo(model, location)
        switch results {
        case .success(let void):
            if let data = model.iamgeData {
                // 이미지도 저장하는 로직 구성하기
                
            }
            successOutput.value = ()
        case .failure(let error):
            repoErrorPut.value = error
        }
    }
}
