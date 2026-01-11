//
//  MemoTextViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/13/24.
//

import Foundation


class MemoTextViewModel {
    
    let textInput: _Observable<TextViewModel?> = _Observable(nil)
    
    let activeOutPut: _Observable<Bool> = _Observable(true)
    
    let textViewdidChangeInput: _Observable<String?> = _Observable(nil)
    
    
    
    let placeHolderText: _Observable<String?> = _Observable(nil)
    
    let currentTextCountOutPut: _Observable<Int> = _Observable(0)
    
    let processingText: _Observable<String?> = _Observable(nil)
    
    let placeHolderBoolOutput: _Observable<Bool?> = _Observable(nil)
    
    

    var MaxCount: Int?
    var maxLines: Int?
    
    init(){
        textInput.bind { [weak self] model in
            guard let self else { return }
            guard let model else { return }
            guard let MaxCount else { return }
            activeOutPut.value = maxLanthTester(model: model, count: MaxCount)
        }
        textViewdidChangeInput.bind { [weak self] string in
            guard let self else { return }
            guard let string else { return }
            textViewPlaceHolderTrriger(string)
        }
    }

    private func maxLanthTester(model: TextViewModel, count: Int) -> Bool {
        let newText = (model.text as NSString).replacingCharacters(in: NSRange(location: model.rangeStart, length: model.rangeLength), with: model.replacing)
        
        currentTextCountOutPut.value = newText.count
        
        if let maxLines {
            let lines = newText.components(separatedBy: "\n")
            
            if lines.count > maxLines {
                return false
            }
        }
        return newText.count <= count
    }
    
    private func textViewPlaceHolderTrriger(_ text: String){
        placeHolderBoolOutput.value = text.isEmpty
    }
}
