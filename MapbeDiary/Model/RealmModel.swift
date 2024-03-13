//
//  RealmModel.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/7/24.
//

import Foundation
import RealmSwift

class Folder: Object { // Primary키로 바로 메모 이미지 생성
    @Persisted(primaryKey: true) var id: ObjectId // 프라이 머리키
    @Persisted var folderName: String // 사용자 메모 관리 폴더.
    @Persisted var regDate: Date // 생성날짜
    @Persisted var modifyDate: Date // 수정된 날짜
    @Persisted var LocationMemo: List<LocationMemo> // Memo 리스트
    @Persisted var index: Int // 후에가서 드래그앤 드롭을 할수도 있음으로 해놓기
    
    convenience
    init(folderName: String, index: Int) {
        self.init()
        self.folderName = folderName
        self.regDate = Date() // 생성 즉시
        self.modifyDate = Date() // 생성 즉시 후에 수정 가능하게
        self.index = index
    }
    
}

class Location: EmbeddedObject {
    @Persisted var lat: String // 경도
    @Persisted var lon: String // 위도
    
    convenience
    init(lat: String, lon: String) {
        self.init()
        self.lat = lat
        self.lon = lon
    }
}

class LocationMemo: Object {
    // ID
    @Persisted(primaryKey: true) var id : ObjectId  // 해당 id를 통해 이미지 폴더 이름
    // title
    @Persisted var title: String // 제목
    @Persisted var location: Location? // 위치
    @Persisted var contents: String? // 대표 짧은 글
    @Persisted var phoneNumber: String? // 전화번호
    @Persisted var regdate: Date // 생성일
    @Persisted var detailMemos: List<DetailMemo>
    
    @Persisted(originProperty: "LocationMemo") var parents: LinkingObjects<Folder>
    
    convenience
    init(title: String, location: Location, contents: String?, phoneNumber: String? = nil){
        self.init()
        self.title = title
        self.location = location
        self.contents = contents
        self.regdate = Date()
        self.phoneNumber = phoneNumber
    }
}

class DetailMemo: Object {
    
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var detailContents: String // 세부 메모
    @Persisted var regDate: Date
    @Persisted var modifeyDate: Date
    @Persisted var imagePaths: List<ImageObject> // 이미지 경로 배열
    
    @Persisted(originProperty: "detailMemos") var parents: LinkingObjects<LocationMemo>
    
    convenience
    init(detailContents: String, modifyDate: Date?) {
        self.init()
        self.detailContents = detailContents
        self.regDate = Date()
        self.modifeyDate = modifyDate ?? Date()
    }
    
}

class ImageObject: Object {
    @Persisted(primaryKey: true) var id : ObjectId // 고유 아이디
    @Persisted var imagename: String // 이미지 이름은 UUID 로 할수도
    @Persisted var regDate: Date // 생성 날짜
    @Persisted var orderIndex: Int // 후에 정렬이나 순서 교체 염두
    
    convenience
    init(imagename: String, index: Int) {
        self.init()
        self.imagename = imagename
        self.regDate = Date()
        self.orderIndex = index
    }

}



/*
 //
 //  RealmModel.swift
 //  MapbeDiary
 //
 //  Created by Jae hyung Kim on 3/7/24.
 //

 import Foundation
 import RealmSwift

 class Folder: Object { // Primary키로 바로 메모 이미지 생성
     @Persisted(primaryKey: true) var id: ObjectId // 프라이 머리키
     @Persisted var folderName: String // 사용자 메모 관리 폴더.
     @Persisted var regDate: Date // 생성날짜
     @Persisted var modifyDate: Date // 수정된 날짜
     @Persisted var memolist: List<Memo> // Memo 리스트
     @Persisted var index: Int // 후에가서 드래그앤 드롭을 할수도 있음으로 해놓기
     
     convenience
     init(folderName: String, index: Int) {
         self.init()
         self.folderName = folderName
         self.regDate = Date() // 생성 즉시
         self.modifyDate = Date() // 생성 즉시 후에 수정 가능하게
         self.index = index
     }
     
 }

 class Memo: Object {
     // ID
     @Persisted(primaryKey: true) var id : ObjectId  // 해당 id를 통해 이미지 폴더 이름
     // title
     @Persisted var title: String // 제목
     @Persisted var location: Location? // 위치
     @Persisted var contents: String? // 간단메모
     @Persisted var detailContents: String? // 세부 메모
     @Persisted var phoneNumber: String? // 전화번호
     @Persisted var imagePaths: List<ImageObject> // 이미지 경로 배열
     @Persisted var regdate: Date // 생성일
     @Persisted(originProperty: "memolist") var parents: LinkingObjects<Folder>
     
     convenience
     init(title: String, location: Location, contents: String?, phoneNumber: String? = nil){
         self.init()
         self.title = title
         self.location = location
         self.contents = contents
         self.regdate = Date()
         self.phoneNumber = phoneNumber
     }
     
 }

 class ImageObject: Object {
     @Persisted(primaryKey: true) var id : ObjectId // 고유 아이디
     @Persisted var imagename: String // 이미지 이름은 UUID 로 할수도
     @Persisted var regDate: Date // 생성 날짜
     @Persisted var orderIndex: Int // 후에 정렬이나 순서 교체 염두
     
     convenience
     init(imagename: String, index: Int) {
         self.init()
         self.imagename = imagename
         self.regDate = Date()
         self.orderIndex = index
     }

 }

 class Location: EmbeddedObject {
     @Persisted var lat: String // 경도
     @Persisted var lon: String // 위도
     
     convenience
     init(lat: String, lon: String) {
         self.init()
         self.lat = lat
         self.lon = lon
     }
 }




 */
