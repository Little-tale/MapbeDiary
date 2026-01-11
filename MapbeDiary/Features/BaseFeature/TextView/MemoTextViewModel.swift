//
//  MemoTextViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/13/24.
//

import Foundation


class MemoTextViewModel {
    
    let textInput: Observable<TextViewModel?> = Observable(nil)
    
    let activeOutPut: Observable<Bool> = Observable(true)
    
    let textViewdidChangeInput: Observable<String?> = Observable(nil)
    
    
    
    let placeHolderText: Observable<String?> = Observable(nil)
    
    let currentTextCountOutPut: Observable<Int> = Observable(0)
    
    let processingText: Observable<String?> = Observable(nil)
    
    let placeHolderBoolOutput: Observable<Bool?> = Observable(nil)
    
    

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
