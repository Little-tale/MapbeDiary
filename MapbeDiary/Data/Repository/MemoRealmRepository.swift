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
    ) async throws(RealmManagerError) -> LocationMemoEntity {
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
        
        return MemoMapper.toEntity(memo)
    }
    
    @discardableResult
    func createDetailMemo(
        input: DetailMemoCreateInput
    ) async throws(RealmManagerError) -> DetailMemoEntity {
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
        
        return MemoMapper.toEntity(detail)
    }
    
    @discardableResult
    func addDetailMemoImage(
        input: DetailMemoImageCreateInput
    ) async throws(RealmManagerError) -> URL {
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
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentDirectory
            .appendingPathComponent(detail.id.stringValue)
            .appendingPathComponent("\(imageObject.id.stringValue).jpeg")
    }
}

// MARK: Read
@RealmActor
extension MemoRealmRepository {
    
    func findLocationMemo(id: String) async throws(RealmManagerError) -> LocationMemoEntity {
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
        
        return MemoMapper.toEntity(memo)
    }
    
    func findLocationMemos(folderId: String) async throws(RealmManagerError) -> [LocationMemoEntity] {
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
        
        return MemoMapper.toEntities(Array(folder.LocationMemo))
    }
    
    func findLocationMemos(folderId: String, date: Date) async throws(RealmManagerError) -> [LocationMemoEntity] {
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
        return MemoMapper.toEntities(Array(locationMemos))
    }
    
    func findLocationMemosCount(folderId: String, date: Date) async throws(RealmManagerError) -> Int {
        let memos = try await findLocationMemos(folderId: folderId, date: date)
        return memos.count
    }
    
    func findFirstLocationMemo() async throws(RealmManagerError) -> LocationMemoEntity? {
        let realm = try await RealmActor.shared.getRealm()
        guard let memo = realm.objects(LocationMemo.self).first else { return nil }
        return MemoMapper.toEntity(memo)
    }
    
    func findMinDateLocationMemo(folderId: String) async throws(RealmManagerError) -> LocationMemoEntity? {
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
        guard let memo = sorted.first else { return nil }
        return MemoMapper.toEntity(memo)
    }
    
    func findDetailMemos(locationMemoId: String) async throws(RealmManagerError) -> [DetailMemoEntity] {
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
        
        return MemoMapper.toEntities(Array(location.detailMemos))
    }
    
    func findDetailImages(detailMemoId: String) async throws(RealmManagerError) -> [URL] {
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
        
        let imageIds = Array(detail.imagePaths.map { $0.id.stringValue })
        let result = FileManagers.shard.findDetailImageDataUrl(
            detailID: detail.id.stringValue,
            imageIds: imageIds
        )
        switch result {
        case let .success(urls):
            return urls
        case .failure:
            return []
        }
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
    
    func deleteLocationMemo(id: String) async throws(RealmManagerError) {
        let realm = try await RealmActor.shared.getRealm()
        let memoId: ObjectId
        do {
            memoId = try ObjectId(string: id)
        } catch {
            throw .cantFindObjectId
        }

        guard let location = realm.object(ofType: LocationMemo.self, forPrimaryKey: memoId) else {
            throw .cantFindLocationMemo
        }
        
        let details = Array(location.detailMemos)
        for detail in details {
            try await deleteDetailMemo(detailId: detail.id.stringValue)
        }
        
        if !FileManagers.shard.removeMarkerImageAtMemo(memoIdString: memoId.stringValue) {
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
    
    func deleteDetailMemo(detailId: String) async throws(RealmManagerError) {
        let realm = try await RealmActor.shared.getRealm()
        let detailObjId: ObjectId
        do {
            detailObjId = try ObjectId(string: detailId)
        } catch {
            throw .cantFindObjectId
        }

        guard let detail = realm.object(ofType: DetailMemo.self, forPrimaryKey: detailObjId) else {
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
