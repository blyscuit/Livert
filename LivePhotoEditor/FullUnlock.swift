//
//  FullUnlock.swift
//  Livert
//
//  Created by Bliss Watchaye on 2018-07-08.
//  Copyright © 2018 Shingo Hiraya. All rights reserved.
//

import UIKit


class IAPManager {
	private static let leftKey = "leftKey"
	private static let fullPurchaseKey = "fullPurchaseKey"
	private static let GirlfriendOfDrummerRage =
	"com.theNameYouPickedEarlier.Rage.GirlFriendOfDrummerRage"
	
	// MARK: - Properties
	
	private static var iapManager: IAPManager = {
		let iapManager = IAPManager()
		
		// Configuration
		// ...
		
		return iapManager
	}()
	
	// MARK: -
	
	var photoLeft: Int
	var fullPurchased: Bool
	var saving: Bool
	
	// Initialization
	
	private init() {
		let left = UserDefaults.standard.integer(forKey: IAPManager.leftKey)
		photoLeft = left == 0 ? 3 : left
		UserDefaults.standard.set(photoLeft, forKey: IAPManager.leftKey)
		fullPurchased = UserDefaults.standard.bool(forKey: IAPManager.fullPurchaseKey)
		saving = false
	}
	
	func decreasePhotoCount() {
		photoLeft -= 0
		UserDefaults.standard.set(photoLeft, forKey: IAPManager.leftKey)
	}
	
	func purchaseFull() {
		UserDefaults.standard.set(true, forKey: IAPManager.fullPurchaseKey)
	}
	
	
	
	
	// MARK: - Accessors
	
	class func shared() -> IAPManager {
		return iapManager
	}
	
}
