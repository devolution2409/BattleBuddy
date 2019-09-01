//
//  DependencyInterfaces.swift
//  BattleBuddy
//
//  Created by Mike on 7/30/19.
//  Copyright © 2019 Veritas. All rights reserved.
//

import UIKit

// Mark:- Dependency Manager

protocol DependencyManager {
    static var shared: DependencyManager { get }
    var sessionManager: SessionManager { get }
    var databaseManager: DatabaseManager { get }
    var httpRequestor: HttpRequestor { get }
    var firebaseManager: FirebaseManager { get }
    var prefsManager: PreferencesManager { get }
    var twitchManager: TwitchManager { get }
    var feedbackManager: FeedbackManager { get }
    var adManager: AdManager { get }
    var metadataManager: GlobalMetadataManager { get }
    var ammoUtilitiesManager: AmmoUtilitiesManager { get }
}

// MARK:- Networking

protocol HttpRequestor {
    func sendGetRequest(url: String, headers: [String: String], completion: @escaping (_ : [String: Any]?) -> Void)
}

// MARK:- Session

protocol SessionDelegate {
    func sessionDidFinishLoading()
}

protocol SessionManager {
    func initializeSession()
    func isLoggedIn() -> Bool
}

// MARK: - Database

protocol DatabaseManager {
    func getAllItemsWithSearchQuery(_ query: String, handler: @escaping (_: [BaseItem]) -> Void)

    func getAllFirearms(handler: @escaping (_: [Firearm]) -> Void)
    func getAllArmor(handler: @escaping (_: [Armor]) -> Void)
    func getAllBodyArmor(handler: @escaping (_: [Armor]) -> Void)
    func getAllAmmo(handler: @escaping (_: [Ammo]) -> Void)
    func getAllMedical(handler: @escaping (_: [Medical]) -> Void)
    func getAllThrowables(handler: @escaping (_: [Throwable]) -> Void)
    func getAllMelee(handler: @escaping (_: [MeleeWeapon]) -> Void)

    func getAllFirearmsByType(handler: @escaping ([FirearmType: [Firearm]]) -> Void)
    func getAllArmorByClass(handler: @escaping ([ArmorClass: [Armor]]) -> Void)
    func getAllBodyArmorByClass(handler: @escaping ([ArmorClass: [Armor]]) -> Void)
    func getAllAmmoByCaliber(handler: @escaping ([String: [Ammo]]) -> Void)
    func getAllMedicalByType(handler: @escaping ([MedicalItemType: [Medical]]) -> Void)

    func getAllFirearmsOfType(type: FirearmType, handler: @escaping ([Firearm]) -> Void)
    func getAllFirearmsOfCaliber(caliber: String, handler: @escaping ([Firearm]) -> Void)
    func getAllAmmoOfCaliber(caliber: String, handler: @escaping ([Ammo]) -> Void)
    func getAllBodyArmorOfClass(armorClass: ArmorClass, handler: @escaping ([Armor]) -> Void)
    func getAllBodyArmorWithMaterial(material: ArmorMaterial, handler: @escaping ([Armor]) -> Void)
}

// MARK:- Ads

enum VideoAdState {
    case unavailable
    case loading
    case ready
}

protocol AdDelegate {
    func adManager(_ adManager: AdManager, didUpdate videoAdState: VideoAdState)
}

protocol AdManager {
    var adDelegate: AdDelegate? { get set }
    var currentVideoAdState: VideoAdState { get }
    func bannerAdsEnabled() -> Bool
    func updateBannerAdsSetting(_ enabled: Bool)
    func watchAdVideo(from rootVC: UIViewController)
}

// MARK:- Global Metadata

struct AmmoMetadata {
    let caliber: String
    let displayName: String
    let index: Int
}

struct GlobalMetadata {
    let totalUserCount: Int
    let totalAdsWatched: Int
    let ammoMetadata: [AmmoMetadata]

    init?(json: [String: Any]) {
        guard let ammoMeta = json["ammoMetadata"] as? [String: [String: Any]], let boxedUserCount = json["totalUserCount"] as? NSNumber, let boxedAdCount = json["totalAdsWatched"] as? NSNumber else {
            return nil
        }

        var tempAmmoMeta: [AmmoMetadata] = []
        for caliber in ammoMeta.keys {
            guard let data = ammoMeta[caliber], let displayName = data["displayName"] as? String,
                let rawIndex = data["index"] as? NSNumber else {
                return nil
            }

            tempAmmoMeta.append(AmmoMetadata(caliber: caliber, displayName: displayName, index: rawIndex.intValue))
        }

        totalUserCount = boxedUserCount.intValue
        totalAdsWatched = boxedAdCount.intValue
        ammoMetadata = tempAmmoMeta
    }
}

protocol GlobalMetadataManager {
    func getGlobalMetadata() -> GlobalMetadata?
    func updateGlobalMetadata(handler: @escaping (_ : GlobalMetadata?) -> Void)
}

// Mark:- Ammo Manager

protocol AmmoUtilitiesManager {
    func caliberDisplayName(_ caliber: String) -> String
}
