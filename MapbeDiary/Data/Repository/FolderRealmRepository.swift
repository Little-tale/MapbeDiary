//
//  FolderRealmActor.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import RealmSwift

@RealmActor
final class FolderRealmRepository {
    
    static let shared = FolderRealmRepository()
    
    private init() {}
    
    
    // MARK: Required
    func setUp() async {
        let realm = try? await RealmActor.shared.getRealm()
        guard let realm else {
            print("NEED FIX from makeRealm - \(#file) - \(#line)")
            return
        }
        
        if UserDefaultsManager.currentFolderID == nil {
            let folder = Array(realm.objects(Folder.self)).first
            UserDefaultsManager.currentFolderID = folder?.id.stringValue
        }
    }
}

// MARK: Create
@RealmActor
extension FolderRealmRepository {
    
    @discardableResult
    func makeFolder(folderName: String) async throws(RealmManagerError) -> FolderEntity {
        let realm = try await RealmActor.shared.getRealm()
        
        let folders = realm.objects(Folder.self)
            .sorted(by: \.index, ascending: false)
        
        let index = folders.count
        
        do {
            let folder = Folder(folderName: folderName, index: index)
            try await realm.asyncWrite {
                realm.add(folder)
            }
            return FolderMapper.toEntity(folder)
        } catch {
            throw .canMakeFolder
        }
    }
}

// MARK: Find
@RealmActor
extension FolderRealmRepository {
    
    func findFolder(id: String) async throws(RealmManagerError) -> FolderEntity {
        let realm = try await RealmActor.shared.getRealm()
        
        do {
            let idObj = try ObjectId(string: id)
            
            let folder = realm.object(
                ofType: Folder.self,
                forPrimaryKey: idObj
            )
            guard let folder else {
                throw RealmManagerError.cantFindFolder
            }
            
            return FolderMapper.toEntity(folder)
        } catch {
            throw .cantFindObjectId
        }
    }
}

// MARK: DELETE
@RealmActor
extension FolderRealmRepository {
    
     func removeFolderInEveryThing(
         folderId: String
     ) async throws(RealmManagerError) {
         let realm = try await RealmActor.shared.getRealm()
         let idObj: ObjectId
         do {
             idObj = try ObjectId(string: folderId)
         } catch {
             throw .cantFindObjectId
         }
         
         guard let folder = realm.object(ofType: Folder.self, forPrimaryKey: idObj) else {
             throw .cantFindFolder
         }
         
         let locationMemos = findAllMemoAtFolder(folder: folder)
         var details: [DetailMemo] = []
         
         for locationMemo in locationMemos {
             details.append(contentsOf: Array(locationMemo.detailMemos))
         }
         
         if !details.isEmpty {
             try await removeDetailsMemos(details)
         }
         
         try await removeLocationMemos(locationMemos)
     }

     func removeAllFoldersAndContents() async throws(RealmManagerError) {
         let realm = try await RealmActor.shared.getRealm()
         let folders = Array(realm.objects(Folder.self))

         for folder in folders {
             let locationMemos = findAllMemoAtFolder(folder: folder)
             var details: [DetailMemo] = []

             for locationMemo in locationMemos {
                 details.append(contentsOf: Array(locationMemo.detailMemos))
             }

             if !details.isEmpty {
                 try await removeDetailsMemos(details)
             }

             if !locationMemos.isEmpty {
                 try await removeLocationMemos(locationMemos)
             }

             guard let realmFolder = realm.object(ofType: Folder.self, forPrimaryKey: folder.id) else {
                 throw .cantDeleteOfFolder
             }

             do {
                 try realm.write {
                     realm.delete(realmFolder)
                 }
             } catch {
                 throw .cantDeleteOfFolder
             }
         }
     }
     
     private func findAllMemoAtFolder(folder: Folder) -> [LocationMemo] {
         Array(folder.LocationMemo)
     }
     
     private func removeLocationMemos(_ locations: [LocationMemo]) async throws(RealmManagerError) {
         let realm = try await RealmActor.shared.getRealm()
         
         for location in locations {
             if !FileManagers.shard.removeMarkerImageAtMemo(memoIdString: location.id.stringValue) {
                 throw .cantDeleteImage
             }
             
             guard let memo = realm.object(ofType: LocationMemo.self, forPrimaryKey: location.id) else {
                 throw .cantDeleteMemo
             }
             
             do {
                 try realm.write {
                     realm.delete(memo)
                 }
             } catch {
                 throw .cantDeleteMemo
             }
         }
     }
     
     private func removeDetailsMemos(_ details: [DetailMemo]) async throws(RealmManagerError) {
         let realm = try await RealmActor.shared.getRealm()
         
         for detail in details {
             guard let realmDetail = realm.object(ofType: DetailMemo.self, forPrimaryKey: detail.id) else {
                 throw .cantDeleteDetailMemo
             }

             let images = Array(realmDetail.imagePaths)
             for image in images {
                 let result = FileManagers.shard.removeDetailImage(
                     detailId: realmDetail.id.stringValue,
                     imageId: image.id.stringValue
                 )

                 if case .failure = result {
                     throw .cantDeleteMemo
                 }
             }

             do {
                 try realm.write {
                     realm.delete(images)
                     realm.delete(realmDetail)
                 }
             } catch {
                 throw .cantDeleteDetailMemo
             }
         }
     }
     
     private func removeDetail(detailId: ObjectId, realm: Realm) throws(RealmManagerError) {
         guard let detail = realm.object(ofType: DetailMemo.self, forPrimaryKey: detailId) else {
             throw .cantDeleteDetailMemo
         }
         
         do {
             try realm.write {
                 realm.delete(detail)
             }
         } catch {
             throw .cantDeleteDetailMemo
         }
     }
     
     private func removeImageObject(imageId: ObjectId, realm: Realm) throws(RealmManagerError) {
         guard let image = realm.object(ofType: ImageObject.self, forPrimaryKey: imageId) else {
             throw .cantDeleteImage
         }
         
         let index = image.orderIndex
         do {
             try realm.write {
                 realm.delete(image)
                 let datas = realm.objects(ImageObject.self).where { $0.orderIndex > index }
                 for data in datas {
                     data.orderIndex -= 1
                 }
             }
         } catch {
             throw .cantDeleteImage
         }
     }

}
