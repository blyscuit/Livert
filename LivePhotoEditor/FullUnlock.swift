//
//  FullUnlock.swift
//  Livert
//
//  Created by Bliss Watchaye on 2018-07-08.
//  Copyright © 2018 Shingo Hiraya. All rights reserved.
//

import UIKit
import StoreKit

enum IAPHandlerAlertType{
	case disabled
	case restored
	case purchased
	
	func message() -> String{
		switch self {
		case .disabled: return "Purchases are disabled in your device!"
		case .restored: return "You've successfully restored your purchase!"
		case .purchased: return "You've successfully bought this purchase!"
		}
	}
}

class IAPManager: NSObject {
	private static let leftKey = "leftKey"
	private static let fullPurchaseKey = "fullPurchaseKey"
	private static let GirlfriendOfDrummerRage =
	"com.theNameYouPickedEarlier.Rage.GirlFriendOfDrummerRage"
	
	let NON_CONSUMABLE_PURCHASE_PRODUCT_ID = "iap1"
//	fileprivate var productID = ""
	fileprivate var productsRequest = SKProductsRequest()
	fileprivate var iapProducts = [SKProduct]()
	var purchaseStatusBlock: ((IAPHandlerAlertType) -> Void)?
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
	
	
	// MARK: - MAKE PURCHASE OF A PRODUCT
	func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
	
	// MARK: - RESTORE PURCHASE
	func restorePurchase(){
		SKPaymentQueue.default().add(self)
		SKPaymentQueue.default().restoreCompletedTransactions()
	}
	func purchaseMyProduct(index: Int){
		if iapProducts.count == 0 { return }
		
		if self.canMakePurchases() {
			let product = iapProducts[index]
			let payment = SKPayment(product: product)
			SKPaymentQueue.default().add(self)
			SKPaymentQueue.default().add(payment)
			
			print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
//			productID = product.productIdentifier
		} else {
			purchaseStatusBlock?(.disabled)
		}
	}
	
	private override init() {
		let left = UserDefaults.standard.integer(forKey: IAPManager.leftKey)
		photoLeft = left == 0 ? fullTrial : left
		UserDefaults.standard.set(photoLeft, forKey: IAPManager.leftKey)
		fullPurchased = UserDefaults.standard.bool(forKey: IAPManager.fullPurchaseKey)
		saving = false
		super.init()
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
	
	func fetchAvailableProducts(){
		
		// Put here your IAP Products ID's
		let productIdentifiers = NSSet(objects: NON_CONSUMABLE_PURCHASE_PRODUCT_ID
		)
		
		productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
		productsRequest.delegate = self
		productsRequest.start()
	}
}

extension IAPManager: SKProductsRequestDelegate, SKPaymentTransactionObserver{
	// MARK: - REQUEST IAP PRODUCTS
	func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
		
		if (response.products.count > 0) {
			iapProducts = response.products
			for product in iapProducts{
				let numberFormatter = NumberFormatter()
				numberFormatter.formatterBehavior = .behavior10_4
				numberFormatter.numberStyle = .currency
				numberFormatter.locale = product.priceLocale
				let price1Str = numberFormatter.string(from: product.price)
				print(product.localizedDescription + "\nfor just \(price1Str!)")
			}
		}
	}
	
	func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
		purchaseFull()
		purchaseStatusBlock?(.restored)
	}
	
	// MARK:- IAP PAYMENT QUEUE
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		for transaction:AnyObject in transactions {
			if let trans = transaction as? SKPaymentTransaction {
				switch trans.transactionState {
				case .purchased:
					print("purchased")
					SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
					purchaseStatusBlock?(.purchased)
					break
					
				case .failed:
					print("failed")
					SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
					break
				case .restored:
					print("restored")
					SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
					break
					
				default: break
				}}}
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
