//
//  TextFiledTesterViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/13/24.
//

import Foundation

struct TextViewModel {
    var text: String
    var rangeStart: Int
    var rangeLength: Int
    var replacing: String
    
}

class TextFiledTesterViewModel {
    
    let titleTester: Observable<TextViewModel?> = Observable(nil)
    let simpleMemoTester: Observable<TextViewModel?> = Observable(nil)
    let phoneTextTester: Observable<TextViewModel?> = Observable(nil)
    
    
    var canAllowed: Observable<Bool> = Observable(true)
    
    init(){
        titleTester.bind { [weak self] model in
            guard let self else { return }
            guard let model else { return }
            canAllowed.value = maxLanthTester(model: model,count: 22)
        }
        simpleMemoTester.bind { [weak self] model in
            guard let self else { return }
            guard let model else { return }
            canAllowed.value = maxLanthTester(model: model,count: 20)
        }
        phoneTextTester.bind { [weak self] model in
            guard let self else { return }
            guard let model else { return }
            canAllowed.value = maxLanthTester(model: model,count: 16)
        }
    }
    
    private func maxLanthTester(model: TextViewModel, count: Int) -> Bool {
        let newText = (model.text as NSString).replacingCharacters(in: NSRange(location: model.rangeStart, length: model.rangeLength), with: model.replacing)
        return newText.count <= count
    }
    
}
