//
//  UserDefaultsManager.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/13/26.
//

import Foundation

public final actor UserDefaultsManager {
    
    public enum Key: String {
        case currentFolderID
        
        var value: String {
            return self.rawValue
        }
    }
    
    @UserDefaultsWrapper(key: Key.currentFolderID.value, placeValue: nil)
    public static var currentFolderID: String?
}

@propertyWrapper
public struct UserDefaultsWrapper<T: Codable> {
    public let key: String
    public let placeValue: T
    
    private let userDefaults = UserDefaults.standard
    
    public var wrappedValue: T {
        get {
            guard let data = userDefaults.data(forKey: key),
                  let value = try? CodableManager.shared.jsonDecoding(model: T.self, from: data) else {
                return placeValue
            }

            return value
        } set {
            guard let data = try? CodableManager.shared.jsonEncoding(from: newValue)
            else {
                return
            }
            userDefaults.setValue(data, forKey: key)
        }
    }
}
