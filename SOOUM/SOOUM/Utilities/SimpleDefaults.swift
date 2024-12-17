//
//  SimpleDefaults.swift
//  SOOUM
//
//  Created by 오현식 on 10/14/24.
//

import Foundation


class SimpleDefaults {
    
    static let shared = SimpleDefaults()
    
    private let simpleKey: String = "com.sooum"
    
    
    // MARK: Core location
    
    private let locationKey: String = "location"
    
    @discardableResult
    func initLocation() -> Coordinate {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        let coordinate = Coordinate()
        guard let encoded = self.encoded(coordinate) else { return coordinate }
        self.save(key: self.locationKey, data: encoded)
        return coordinate
    }
    
    func loadLocation() -> Coordinate {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        guard let data = self.load(key: self.locationKey) as? Data,
              let coordinate = self.decoded(data) else {
            return self.initLocation()
        }
        return coordinate
    }
    
    func isLocationEmpty() -> Bool {
        return self.loadLocation().latitude.isEmpty && self.loadLocation().longitude.isEmpty
    }
    
    @discardableResult
    func saveLocation(_ coordinate: Coordinate) -> Coordinate {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        guard let encoded = self.encoded(coordinate) else { return coordinate }
        self.save(key: self.locationKey, data: encoded)
        return coordinate
    }
    
    @discardableResult
    func removeLocation() -> Coordinate {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        return self.initLocation()
    }
    
    func encoded(_ coordinate: Coordinate) -> Data? {
        guard let encoded = try? JSONEncoder().encode(coordinate) else { return nil }
        return encoded
    }
    
    func decoded(_ data: Data) -> Coordinate? {
        guard let decoded = try? JSONDecoder().decode(Coordinate.self, from: data) else { return nil }
        return decoded
    }
    
    
    // MARK: Remote notification activation
    
    private let remoteNotificationActivationKey: String = "remote.notification.activation"

    @discardableResult
    func initRemoteNotificationActivation() -> Bool {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        let key: String = "\(self.simpleKey).\(self.remoteNotificationActivationKey)"
        UserDefaults.standard.set(true, forKey: key)
        return true
    }

    func loadRemoteNotificationActivation() -> Bool {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        let key: String = "\(self.simpleKey).\(self.remoteNotificationActivationKey)"
        guard let value = UserDefaults.standard.value(forKey: key) as? Bool else {
            return self.initRemoteNotificationActivation()
        }
        return value
    }

    @discardableResult
    func saveRemoteNotificationActivation(_ value: Bool) -> Bool {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        let key: String = "\(self.simpleKey).\(self.remoteNotificationActivationKey)"
        UserDefaults.standard.set(value, forKey: key)
        return value
    }
}

extension SimpleDefaults {
    
    func save(key: String, data: Any?) {
        guard let data = data else { return }
        UserDefaults.standard.set(data, forKey: "\(self.simpleKey).\(key)")
    }
    
    func load(key: String) -> Any? {
        return UserDefaults.standard.object(forKey: "\(self.simpleKey).\(key)")
    }
    
    func delete(key: String) {
        UserDefaults.standard.removeObject(forKey: "\(self.simpleKey).\(key)")
    }
}
