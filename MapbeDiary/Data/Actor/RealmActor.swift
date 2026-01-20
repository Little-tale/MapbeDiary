//
//  RealmActor.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import RealmSwift

@globalActor actor RealmActor {
    
    static let shared = RealmActor()

    private var realm: Realm?

    private init() {
        Task {
            await self.setup()
        }
    }

    private func setup() async {
        do {
            realm = try await Realm(actor: RealmActor.shared)
            #if DEBUG
            print(realm?.configuration.fileURL ?? "Can't get Realm fileURL")
            #endif
        } catch {
            print("Realm 초기화 실패: \(error)")
            realm = nil
        }
    }
    
    
    func getRealm() async throws(RealmManagerError) -> Realm {
        if let realm = realm {
            return realm
        }
        
        await setup()

        guard let realm = realm else {
            throw RealmManagerError.cantInit
        }

        return realm
    }
}
