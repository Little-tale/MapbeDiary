//
//  CalendarCellViewModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/30/24.
//

import Foundation

final class CalendarCellViewModel: ViewModelType {
    
    struct Input{
        let locationMemo: LocationMemoEntity
    }
    
    struct Output {
        let imageData: URL?
        let titleLabel: String
        let dateLabel: String
    }
    
    func trasform(_ input: Input) -> Output {
        let title = input.locationMemo.title
        
        let dateOf = input.locationMemo.regDate
        let dateString = DateFormetters.shared.localDate(dateOf, style:.short, timeStyle: .short)
        
        let url = findLocationImageData(input.locationMemo.id)
        
        return Output(imageData: url, titleLabel: title, dateLabel: dateString)
    }
    
    private func findLocationImageData(_ id : String) -> URL? {
        return FileManagers.shard.loadImageOrignerMarker(id)
    }
}
