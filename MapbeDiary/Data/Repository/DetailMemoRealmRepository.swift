//
//  DetailMemoRealmRepository.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/17/26.
//

import Foundation
import RealmSwift

struct DetailMemoCreateInput {
    let locationMemoId: String
    let text: String
}

struct DetailMemoImageCreateInput {
    let detailMemoId: String
    let imageData: Data
}

struct DetailMemoUpdateInput {
    let detailMemoId: String?
    let locationMemoId: String
    let text: String
    let imageDatas: [Data]
}

struct DetailMemoImageDeleteInput {
    let imageObjectId: String
}

@RealmActor
final class DetailMemoRealmRepository {
    
    static let shared = DetailMemoRealmRepository()
    private init() {}
    
}

// MARK: Create
@RealmActor
extension DetailMemoRealmRepository {
    
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
extension DetailMemoRealmRepository {
    
    func findDetailMemo(id: String) async throws(RealmManagerError) -> DetailMemoEntity {
        let realm = try await RealmActor.shared.getRealm()
        let detailId: ObjectId
        do {
            detailId = try ObjectId(string: id)
        } catch {
            throw .cantFindObjectId
        }
        
        guard let detail = realm.object(ofType: DetailMemo.self, forPrimaryKey: detailId) else {
            throw .cantDeleteDetailMemo
        }
        
        return MemoMapper.toEntity(detail)
    }
    
    func findDetailMemos(
        locationMemoId: String
    ) async throws(RealmManagerError) -> [DetailMemoEntity] {
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
    
    func findDetailImages(
        detailMemoId: String
    ) async throws(RealmManagerError) -> [URL] {
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
extension DetailMemoRealmRepository {
    
    func updateDetailMemo(
        input: DetailMemoUpdateInput
    ) async throws(RealmManagerError) {
        let realm = try await RealmActor.shared.getRealm()
        let locationId: ObjectId
        do {
            locationId = try ObjectId(string: input.locationMemoId)
        } catch {
            throw .cantFindObjectId
        }
        
        guard let location = realm.object(
            ofType: LocationMemo.self,
            forPrimaryKey: locationId
        ) else {
            throw .cantFindLocationMemo
        }
        
        let detail: DetailMemo
        if let detailMemoId = input.detailMemoId {
            let detailId: ObjectId
            do {
                detailId = try ObjectId(string: detailMemoId)
            } catch {
                throw .cantFindObjectId
            }
            
            if let existing = realm.object(ofType: DetailMemo.self, forPrimaryKey: detailId) {
                detail = existing
                do {
                    try await realm.asyncWrite {
                        detail.detailContents = input.text
                        detail.modifeyDate = Date()
                        
                        if !location.detailMemos.contains(detail) {
                            location.detailMemos.append(detail)
                        }
                    }
                } catch {
                    throw .canModifiMemo
                }
            } else {
                let created = DetailMemo(detailContents: input.text, modifyDate: Date())
                created.id = detailId
                do {
                    try await realm.asyncWrite {
                        realm.add(created)
                        location.detailMemos.append(created)
                    }
                } catch {
                    throw .canModifiMemo
                }
                detail = created
            }
        } else {
            let created = DetailMemo(detailContents: input.text, modifyDate: Date())
            do {
                try await realm.asyncWrite {
                    realm.add(created)
                    location.detailMemos.append(created)
                }
            } catch {
                throw .canModifiMemo
            }
            detail = created
        }
        
        let existingImages = Array(detail.imagePaths)
        if !existingImages.isEmpty {
            let imageIdStrings = existingImages.map { $0.id.stringValue }
            let results = FileManagers.shard.removeDetailImageList(
                detailId: detail.id.stringValue,
                imageIds: imageIdStrings
            )
            
            if case .failure = results {
                throw .cantDeleteImage
            }
            
            do {
                try await realm.asyncWrite {
                    realm.delete(existingImages)
                }
            } catch {
                throw .cantDeleteImage
            }
        }
        
        for data in input.imageDatas {
            _ = try await addDetailMemoImage(
                input: DetailMemoImageCreateInput(
                    detailMemoId: detail.id.stringValue,
                    imageData: data
                )
            )
        }
    }
}

// MARK: Delete
@RealmActor
extension DetailMemoRealmRepository {
    
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
