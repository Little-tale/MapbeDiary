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
        
        let result = DateFormatterManager.shared.calendarStartEnd(date: date)
        let locationMemos = folder.LocationMemo
            .where { $0.regdate >= result.start && $0.regdate < result.end }
        return MemoMapper.toEntities(Array(locationMemos))
    }
    
    func findLocationMemosCount(folderId: String, date: Date) async throws(RealmManagerError) -> Int {
        let memos = try await findLocationMemos(folderId: folderId, date: date)
        return memos.count
    }
    
    func findLocationMemosByDate(
        folderId: String
    ) async throws(RealmManagerError) -> [Date: [LocationMemoEntity]] {
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
        
        let memos = folder.LocationMemo.sorted(byKeyPath: "regdate", ascending: true)
        var grouped: [Date: [LocationMemoEntity]] = [:]
        
        for memo in memos {
            let day = Calendar.current.startOfDay(for: memo.regdate)
            grouped[day, default: []].append(MemoMapper.toEntity(memo))
        }
        
        return grouped
    }
    
    func findLocationMemosByMonth(
        folderId: String,
        month: Date
    ) async throws(RealmManagerError) -> [LocationMemoEntity] {
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
        
        let range = DateFormatterManager.shared.monthStartEnd(date: month)
        let locationMemos = folder.LocationMemo
            .where { $0.regdate >= range.start && $0.regdate < range.end }
        return MemoMapper.toEntities(Array(locationMemos))
    }
    
    func findLocationMemosByMonthGroupedByDate(
        folderId: String,
        month: Date
    ) async throws(RealmManagerError) -> [Date: [LocationMemoEntity]] {
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
        
        let range = DateFormatterManager.shared.monthStartEnd(date: month)
        let locationMemos = folder.LocationMemo
            .where { $0.regdate >= range.start && $0.regdate < range.end }
        
        var grouped: [Date: [LocationMemoEntity]] = [:]
        for memo in locationMemos {
            let day = Calendar.current.startOfDay(for: memo.regdate)
            grouped[day, default: []].append(MemoMapper.toEntity(memo))
        }
        
        return grouped
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
            try await DetailMemoRealmRepository.shared.deleteDetailMemo(
                detailId: detail.id.stringValue
            )
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
}
