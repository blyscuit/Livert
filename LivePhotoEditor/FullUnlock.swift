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
	let fullTrial = 3
	// Initialization
	
	private init() {
		let left = UserDefaults.standard.integer(forKey: IAPManager.leftKey)
		photoLeft = left == 0 ? fullTrial : left
		UserDefaults.standard.set(photoLeft, forKey: IAPManager.leftKey)
		fullPurchased = UserDefaults.standard.bool(forKey: IAPManager.fullPurchaseKey)
		saving = false
		checkResetDay()
	}
	
	func decreasePhotoCount() {
		if saving { return }
		photoLeft -= 1
		saving = true
		UserDefaults.standard.set(photoLeft, forKey: IAPManager.leftKey)
		checkResetDay()
	}
	
	func purchaseFull() {
		UserDefaults.standard.set(true, forKey: IAPManager.fullPurchaseKey)
	}
	
	func resetPhoto() {
		saving = false
	}
	
	func checkResetDay() -> Int {
		let date = Date()
		let calendar = Calendar.current
		
		let day = calendar.component(.day, from: date)
		
		let date1 = calendar.startOfDay(for: date)
		if day == 1 || day == 15 {
			photoLeft = fullTrial
			UserDefaults.standard.set(photoLeft, forKey: IAPManager.leftKey)
			return 0
		} else if day > 15 {
			let date2Full = Calendar.current.date(byAdding: .month, value: 1, to: date)
			let date2 = calendar.startOfDay(for: (date2Full?.firstDayOfTheMonth)!)
			
			let components = calendar.dateComponents([.day], from: date1, to: date2)
			
			return components.day!
		} else {
			var dateComponents = DateComponents()
			dateComponents = calendar.dateComponents([.year, .month], from: date)
			dateComponents.day = 15
			// Create date from components
			let userCalendar = Calendar.current // user calendar
			let someDateTime = calendar.date(from: dateComponents)
			let date2 = calendar.startOfDay(for: someDateTime!)
			
			let components = calendar.dateComponents([.day], from: date1, to: date2)
			return components.day!
		}
	}
	
	func shouldShowAlert() -> Bool {
		return photoLeft == (fullTrial - 1) || photoLeft == 0
	}
	
	
	func getNextResetDay() -> String {
		return "\(checkResetDay())"
	}
	
	// MARK: - Accessors
	
	class func shared() -> IAPManager {
		return iapManager
	}
	
}
extension Date {
	var weekday: Int {
		return Calendar.current.component(.weekday, from: self)
	}
	var firstDayOfTheMonth: Date {
		return Calendar.current.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
	}
}
