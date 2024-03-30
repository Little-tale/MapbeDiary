//
//  CalendarCellViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/30/24.
//

import Foundation

final class CalendarCellViewModel: ViewModelType {
    
    struct Input{
        let locationMemo: LocationMemo
    }
    
    struct Output {
        let imageData: URL?
        let titleLabel: String
        let dateLabel: String
    }
    
    func trasform(_ input: Input) -> Output {
        let title = input.locationMemo.title
        let date = input.locationMemo.regdate.localDate()
        let url = findLocationImageData(input.locationMemo.id.stringValue)
        
        return Output(imageData: url, titleLabel: title, dateLabel: date)
    }
    
    private func findLocationImageData(_ id : String) -> URL? {
        return FileManagers.shard.loadImageOrignerMarker(id)
    }
}
