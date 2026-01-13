//
//  MemoRealmRepository.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/14/26.
//

import Foundation
import RealmSwift

struct LocationMemoCreateInput {
    let title: String
    let contents: String?
    let phoneNumber: String?
    let location: Location
    let folderId: String
    let markerImageData: Data?
}

struct LocationMemoUpdateInput {
    let memoId: String
    let title: String?
    let contents: String?
    let phoneNumber: String?
    let markerImageData: Data?
}

struct LocationMemoSnapshot {
    let title: String
    let contents: String?
    let phoneNumber: String?
}

struct DetailMemoCreateInput {
    let locationMemoId: String
    let text: String
}

struct DetailMemoUpdateInput {
    let detailMemoId: String
    let text: String
}

struct DetailMemoImageCreateInput {
    let detailMemoId: String
    let imageData: Data
}

struct DetailMemoImageDeleteInput {
    let imageObjectId: String
}

@RealmActor
final class MemoRealmRepository {
    
    static let shared = MemoRealmRepository()
    
    private init() {}
}

// MARK: Create
@RealmActor
extension MemoRealmRepository {
    
    @discardableResult
    func createLocationMemo(
        input: LocationMemoCreateInput
    ) async throws(RealmManagerError) -> LocationMemo {
        let realm = try await RealmActor.shared.getRealm()
        
        let folderId: ObjectId
        do {
            folderId = try ObjectId(string: input.folderId)
        } catch {
            throw .cantFindObjectId
        }
        
        guard let folder = realm.object(ofType: Folder.self, forPrimaryKey: folderId) else {
            throw .cantFindFolder
        }
        
        let memo = LocationMemo(
            title: input.title,
            location: input.location,
            contents: input.contents,
            phoneNumber: input.phoneNumber
        )
        
        if let data = input.markerImageData {
            if !FileManagers.shard.saveMarkerImageForMemo(
                memoId: memo.id.stringValue,
                imageData: data
            ) {
                throw .cantAddImage
            }
            
            if !FileManagers.shard.saveMarkerZipImageForMemo(
                memoId: memo.id.stringValue,
                imageData: data
            ) {
                throw .cantAddImage
            }
        }
        
        do {
            try await realm.asyncWrite {
                realm.add(memo)
                folder.LocationMemo.append(memo)
            }
        } catch {
            throw .cantAddMemoInFolder
        }
        
        return memo
    }
    
    @discardableResult
    func createDetailMemo(
        input: DetailMemoCreateInput
    ) async throws(RealmManagerError) -> DetailMemo {
        let realm = try await RealmActor.shared.getRealm()
        let memoId: ObjectId
        do {
            memoId = try ObjectId(string: input.locationMemoId)
        } catch {
            throw .cantFindObjectId
        }
        
        guard let location = realm.object(
            ofType: LocationMemo.self,
            forPrimaryKey: memoId
        ) else {
            throw .cantFindLocationMemo
        }
        
        let detail = DetailMemo(detailContents: input.text, modifyDate: nil)
        
        do {
            try await realm.asyncWrite {
                realm.add(detail)
                if !location.detailMemos.contains(detail) {
                    location.detailMemos.append(detail)
                }
            }
        } catch {
            throw .cantMakeDetailMemo
        }
        
        return detail
    }
    
    @discardableResult
    func addDetailMemoImage(
        input: DetailMemoImageCreateInput
    ) async throws(RealmManagerError) -> ImageObject {
        let realm = try await RealmActor.shared.getRealm()
        let detailId: ObjectId
        do {
            detailId = try ObjectId(string: input.detailMemoId)
        } catch {
            throw .cantFindObjectId
        }
        
        guard let detail = realm.object(
            ofType: DetailMemo.self,
            forPrimaryKey: detailId
        ) else {
            throw .cantDeleteDetailMemo
        }
        
        var index = 0
        if let lastImage = detail.imagePaths.sorted(byKeyPath: "orderIndex", ascending: false).first {
            index = lastImage.orderIndex + 1
        }
        
        if index >= 3 {
            throw .cantAddImage
        }
        
        let imageObject = ImageObject(index: index)
        
        do {
            try await realm.asyncWrite {
                realm.add(imageObject)
                detail.imagePaths.append(imageObject)
            }
        } catch {
            throw .cantAddImage
        }
        
        if !FileManagers.shard.createMemoImage(
            detailMemoId: detail.id.stringValue,
            imgOJId: imageObject.id.stringValue,
            data: input.imageData
        ) {
            throw .cantAddImage
        }
        
        return imageObject
    }
}

// MARK: Read
@RealmActor
extension MemoRealmRepository {
    
    func findLocationMemo(id: String) async throws(RealmManagerError) -> LocationMemo {
        let realm = try await RealmActor.shared.getRealm()
        let memoId: ObjectId
        do {
            memoId = try ObjectId(string: id)
        } catch {
            throw .cantFindObjectId
        }

        guard let memo = realm.object(ofType: LocationMemo.self, forPrimaryKey: memoId) else {
            throw .cantFindLocationMemo
        }
        
        return memo
    }
    
    // MARK: FIXME: 렘 전체 SwiftConcurrency 변경후엔 삭제해야함.
    func findLocationMemoSnapshot(id: String) async throws(RealmManagerError) -> LocationMemoSnapshot {
        let memo = try await findLocationMemo(id: id)
        return LocationMemoSnapshot(
            title: memo.title,
            contents: memo.contents,
            phoneNumber: memo.phoneNumber
        )
    }
    
    func findLocationMemos(folderId: String) async throws(RealmManagerError) -> [LocationMemo] {
        let realm = try await RealmActor.shared.getRealm()
        let folderKey: ObjectId
        do {
            folderKey = try ObjectId(string: folderId)
        } catch {
            throw .cantFindObjectId
        }

        guard let folder = realm.object(ofType: Folder.self, forPrimaryKey: folderKey) else {
            throw .cantFindFolder
        }
        
        return Array(folder.LocationMemo)
    }
    
    func findLocationMemos(folderId: String, date: Date) async throws(RealmManagerError) -> [LocationMemo] {
        let realm = try await RealmActor.shared.getRealm()
        let folderKey: ObjectId
        do {
            folderKey = try ObjectId(string: folderId)
        } catch {
            throw .cantFindObjectId
        }

        guard let folder = realm.object(ofType: Folder.self, forPrimaryKey: folderKey) else {
            throw .cantFindFolder
        }
        
        let result = DateFormetters.shared.calendarStartEnd(date: date)
        let locationMemos = folder.LocationMemo
            .where { $0.regdate >= result.start && $0.regdate < result.end }
        return Array(locationMemos)
    }
    
    func findLocationMemosCount(folderId: String, date: Date) async throws(RealmManagerError) -> Int {
        let memos = try await findLocationMemos(folderId: folderId, date: date)
        return memos.count
    }
    
    func findFirstLocationMemo() async throws(RealmManagerError) -> LocationMemo? {
        let realm = try await RealmActor.shared.getRealm()
        return realm.objects(LocationMemo.self).first
    }
    
    func findMinDateLocationMemo(folderId: String) async throws(RealmManagerError) -> LocationMemo? {
        let realm = try await RealmActor.shared.getRealm()
        let folderKey: ObjectId
        do {
            folderKey = try ObjectId(string: folderId)
        } catch {
            throw .cantFindObjectId
        }

        guard let folder = realm.object(ofType: Folder.self, forPrimaryKey: folderKey) else {
            throw .cantFindFolder
        }
        
        let sorted = folder.LocationMemo.sorted(byKeyPath: "regdate", ascending: true)
        return sorted.first
    }
    
    func findDetailMemos(locationMemoId: String) async throws(RealmManagerError) -> [DetailMemo] {
        let realm = try await RealmActor.shared.getRealm()
        let memoId: ObjectId
        do {
            memoId = try ObjectId(string: locationMemoId)
        } catch {
            throw .cantFindObjectId
        }

        guard let location = realm.object(
            ofType: LocationMemo.self,
            forPrimaryKey: memoId
        ) else {
            throw .cantFindLocationMemo
        }
        
        return Array(location.detailMemos)
    }
    
    func findDetailImages(detailMemoId: String) async throws(RealmManagerError) -> [ImageObject] {
        let realm = try await RealmActor.shared.getRealm()
        let detailId: ObjectId
        do {
            detailId = try ObjectId(string: detailMemoId)
        } catch {
            throw .cantFindObjectId
        }

        guard let detail = realm.object(
            ofType: DetailMemo.self,
            forPrimaryKey: detailId
        ) else {
            throw .cantDeleteDetailMemo
        }
        
        return Array(detail.imagePaths)
    }
}

// MARK: Update
@RealmActor
extension MemoRealmRepository {
    
    func updateLocationMemo(
        input: LocationMemoUpdateInput
    ) async throws(RealmManagerError) {
        let realm = try await RealmActor.shared.getRealm()
        let memoId: ObjectId
        do {
            memoId = try ObjectId(string: input.memoId)
        } catch {
            throw .cantFindObjectId
        }
        
        if let data = input.markerImageData {
            if !FileManagers.shard.saveMarkerImageForMemo(
                memoId: memoId.stringValue,
                imageData: data
            ) {
                throw .cantAddImage
            }
            
            if !FileManagers.shard.saveMarkerZipImageForMemo(
                memoId: memoId.stringValue,
                imageData: data
            ) {
                throw .cantAddImage
            }
        }
        
        var value: [String: Any] = ["id": memoId]
        if let title = input.title { value["title"] = title }
        if let contents = input.contents { value["contents"] = contents }
        if let phoneNumber = input.phoneNumber { value["phoneNumber"] = phoneNumber }
        
        do {
            try await realm.asyncWrite {
                realm.create(LocationMemo.self, value: value, update: .modified)
            }
        } catch {
            throw .cantModifyMemo
        }
    }
    
    func updateDetailMemo(
        input: DetailMemoUpdateInput
    ) async throws(RealmManagerError) {
        let realm = try await RealmActor.shared.getRealm()
        let detailId: ObjectId
        do {
            detailId = try ObjectId(string: input.detailMemoId)
        } catch {
            throw .cantFindObjectId
        }
        
        do {
            try await realm.asyncWrite {
                let value: [String: Any] = [
                    "id": detailId,
                    "detailContents": input.text
                ]
                realm.create(DetailMemo.self, value: value, update: .modified)
            }
        } catch {
            throw .canModifiMemo
        }
    }
}

// MARK: Delete
@RealmActor
extension MemoRealmRepository {
    
    func deleteLocationMemo(id: ObjectId) async throws(RealmManagerError) {
        let realm = try await RealmActor.shared.getRealm()
        
        guard let location = realm.object(ofType: LocationMemo.self, forPrimaryKey: id) else {
            throw .cantFindLocationMemo
        }
        
        let details = Array(location.detailMemos)
        for detail in details {
            try await deleteDetailMemo(detailId: detail.id)
        }
        
        if !FileManagers.shard.removeMarkerImageAtMemo(memoIdString: id.stringValue) {
            throw .cantDeleteImage
        }
        
        do {
            try await realm.asyncWrite {
                realm.delete(location)
            }
        } catch {
            throw .cantDeleteLocationMemo
        }
    }
    
    func deleteDetailMemo(detailId: ObjectId) async throws(RealmManagerError) {
        let realm = try await RealmActor.shared.getRealm()
        
        guard let detail = realm.object(ofType: DetailMemo.self, forPrimaryKey: detailId) else {
            throw .cantDeleteDetailMemo
        }
        
        let images = Array(detail.imagePaths)
        let imageIdStrings = images.map { $0.id.stringValue }
        
        let results = FileManagers.shard.removeDetailImageList(
            detailId: detail.id.stringValue,
            imageIds: imageIdStrings
        )
        
        if case .failure = results {
            throw .cantDeleteImage
        }
        
        do {
            try await realm.asyncWrite {
                realm.delete(images)
                realm.delete(detail)
            }
        } catch {
            throw .cantDeleteDetailMemo
        }
    }
    
    func deleteDetailImage(
        input: DetailMemoImageDeleteInput
    ) async throws(RealmManagerError) {
        let realm = try await RealmActor.shared.getRealm()
        let imageId: ObjectId
        do {
            imageId = try ObjectId(string: input.imageObjectId)
        } catch {
            throw .cantFindObjectId
        }
        
        guard let image = realm.object(
            ofType: ImageObject.self,
            forPrimaryKey: imageId
        ) else {
            throw .cantDeleteImage
        }
        
        guard let detail = image.parents.first else {
            throw .cantDeleteDetailMemo
        }
        
        let result = FileManagers.shard.removeDetailImage(
            detailId: detail.id.stringValue,
            imageId: image.id.stringValue
        )
        
        if case .failure = result {
            throw .cantDeleteImage
        }
        
        let index = image.orderIndex
        do {
            try await realm.asyncWrite {
                realm.delete(image)
                for data in detail.imagePaths where data.orderIndex > index {
                    data.orderIndex -= 1
                }
            }
        } catch {
            throw .cantDeleteImage
        }
    }
}
