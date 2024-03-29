//
//  InspirationsViewController.swift
//  ExpandingCollectionView
//
//  Created by Vamshi Krishna on 30/04/17.
//  Copyright © 2017 VamshiKrishna. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices

private let reuseIdentifier = "Cell"

class InspirationsViewController: UICollectionViewController {

	
	var detailVC: CardContentViewController?
	let backgroundQueue = OperationQueue()
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		backgroundQueue.maxConcurrentOperationCount = 4
		PHPhotoLibrary.shared().register(self)
		
        collectionView?.backgroundColor = UIColor(rgb: 0x1B1C1D)
//        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
		collectionView?.collectionViewLayout = UICollectionViewFlowLayout()
		detailVC = storyboard?.instantiateViewController(withIdentifier: "CardContent") as? CardContentViewController
		
		IAPManager.shared().fetchAvailableProducts()
		
		IAPManager.shared().purchaseStatusBlock = {[weak self] (type) in
			guard let strongSelf = self else{ return }
			if type == .purchased {
				let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
				let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
					strongSelf.collectionView?.reloadData()
				})
				alertView.addAction(action)
				strongSelf.present(alertView, animated: true, completion: nil)
			}
		}
    }
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		guard let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
			return
		}
		flowLayout.invalidateLayout()
	}
	// MARK: - Properties
	
	@IBOutlet weak var livePhotoView: PHLivePhotoView!
	var showLivePhoto: PHLivePhoto!
	var showingPhoto: CIImage!
	var images: [FilterImage] = []
	var effectList = [ "CIVignette", "CIPhotoEffectNoir", "CIColorInvert", "CIColorCrossPolynomial", "CIColorMonochrome", "CIPhotoEffectChrome", "CIPhotoEffectFade", "CIPhotoEffectInstant", "CIFalseColor", "CIPhotoEffectMono", "CISepiaTone", "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer"]
	
//	var effectList = ["CIPhotoEffectInstant"]//, "CIVignette", "CIPhotoEffectNoir", "CIColorInvert", "CIColorCrossPolynomial", "CIColorMonochrome", "CIPhotoEffectChrome", "CIFalseColor", "CIPhotoEffectMono", "CISepiaTone", "CIPhotoEffectTonal", "CIPhotoEffectTransfer"]
	
	private var targetSize: CGSize {
		let scale: CGFloat = 1.1 //UIScreen.main.scale
		return CGSize(width: self.view.bounds.width * scale,
					  height: self.view.bounds.height * scale)
	}
	
	fileprivate var asset: PHAsset?
	
	// MARK: - Life Cycle
	
	deinit {
		PHPhotoLibrary.shared().unregisterChangeObserver(self)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// MARK: - Action
	
	@IBAction func addButtonDidTouch(_ sender: AnyObject) {
		self.showImagePicker()
//		showBuyAlert()
	}
	
	
	// MARK: - Private
	
	fileprivate func showImagePicker() {
		if IAPManager.shared().photoLeft == 0 {
			showBuyAlert()
			return
		} else if IAPManager.shared().shouldShowAlert() {
			showWaitAlert()
		} else {
			presentImagePicker()
		}
	}
	
	fileprivate func presentImagePicker() {
		let controller = UIImagePickerController()
		controller.delegate = self
		controller.sourceType = .photoLibrary
		controller.allowsEditing = false
		controller.mediaTypes = [kUTTypeImage as String, kUTTypeLivePhoto as String]
		self.present(controller, animated: true, completion: nil)
	}
	
	fileprivate func showBuyAlert() {
		let alert = FCAlertView()
		alert.delegate = self
		alert.colorScheme = .flatMidnight
		alert.showAlert(in: self,
						withTitle: "Full Livert",
						withSubtitle: "You ran out of this week free Livert. Upgarde to Full version for unlimited Liverts. 🌃🌕",
						withCustomImage: #imageLiteral(resourceName: "Luna"),
						withDoneButtonTitle: "Unlock Full",
						andButtons: ["Wait"])
	}
	
	fileprivate func showWaitAlert() {
		let alert = FCAlertView()
		alert.delegate = self
		alert.colorScheme = .flatMidnight
		alert.showAlert(in: self,
						withTitle: "Full Livert",
						withSubtitle: "Upgarde to Full version for unlimited Liverts. 🌕⭐️",
						withCustomImage: #imageLiteral(resourceName: "Luna"),
						withDoneButtonTitle: "Unlock Full",
						andButtons: ["Wait"])
	}
	
	
	fileprivate func updateImage() {
		guard let asset = self.asset else { return }
		
//		// Prepare the options to pass when fetching the live photo.
//		let options = PHLivePhotoRequestOptions()
//		options.deliveryMode = .fastFormat
////		options.deliveryMode = .highQualityFormat
//		options.isNetworkAccessAllowed = true
		
		let photoOptions = PHImageRequestOptions()
		photoOptions.isNetworkAccessAllowed = true
		photoOptions.isSynchronous = true
        photoOptions.deliveryMode = .highQualityFormat
		
//		// Request the live photo for the asset from the default PHImageManager.
//		PHImageManager.default().requestLivePhoto(for: asset,
//												  targetSize: self.targetSize,
//												  contentMode: .aspectFit,
//												  options: options,
//												  resultHandler: { livePhoto, info in
//													// If successful, show the live photo view and display the live photo.
//													guard let livePhoto = livePhoto else { return }
//
//													// Now that we have the Live Photo, show it.
//													self.livePhotoView?.livePhoto = livePhoto
////													self.generatePreviews()
//													return
//
//		})
		
		PHImageManager.default().requestImage(for: asset, targetSize: self.targetSize, contentMode: .aspectFit, options: photoOptions, resultHandler:  { livePhoto, info in
			if let livePhoto = livePhoto {
				self.images.removeAll()
				
				self.backgroundQueue.cancelAllOperations()
				
				self.showingPhoto = CIImage(image: livePhoto)
				for (index, effect) in self.effectList.enumerated() {
					self.images.append(FilterImage(title: effect, backgroundImage: nil))
					
					self.backgroundQueue.addOperation(){
							if #available(iOS 11.0, *) {
								self.images[index] = FilterImage(title: effect, backgroundImage: InspirationsViewController.convert(cmage: self.showingPhoto.applyingFilter(effect)))
							} else {
								// Fallback on earlier versions
							}
							
							DispatchQueue.main.sync {
								self.collectionView?.reloadItems(at: [IndexPath(item: index, section: 0)])
//													self.collectionView?.reloadData()
							}
						}
					
				}
				self.collectionView?.reloadData()
			}
		})
	}
	
	func generatePreviews() {
		images.removeAll()
		
		guard let asset = self.asset else { return }
		
		
		let formatIdentifier = Bundle.main.bundleIdentifier!
		let formatVersion = "1.0"
		
		// Set up a handler to make sure we can handle prior edits.
		let options = PHContentEditingInputRequestOptions()
		options.canHandleAdjustmentData = { adjustmentData in
			return adjustmentData.formatIdentifier == formatIdentifier && adjustmentData.formatVersion == formatVersion
		}
		
		// Check whether the asset supports the content editing operation
		if !asset.canPerform(.content) { return }
		
		// Request PHContentEditingInput
		asset.requestContentEditingInput(with: options, completionHandler: { input, info in
			guard let input = input else { fatalError("can't get content editing input: \(info)") }
			
			// Create PHLivePhotoEditingContext from PHContentEditingInput
			guard let livePhotoContext = PHLivePhotoEditingContext(livePhotoEditingInput: input) else { fatalError("can't get live photo to edit") }
			
			if #available(iOS 11.0, *) {
				
				self.showingPhoto = livePhotoContext.fullSizeImage
				for effect in self.effectList {
						self.images.append(FilterImage(title: effect, backgroundImage: nil))
				}
			} else {
				// Fallback on earlier versions
			}
			self.collectionView?.reloadData()
		})
	}
	
	
	fileprivate func applyFilterPreview(_ filterName: String) {
		guard let asset = self.asset else { return }
		
		let formatIdentifier = Bundle.main.bundleIdentifier!
		let formatVersion = "1.0"
		
		// Set up a handler to make sure we can handle prior edits.
		let options = PHContentEditingInputRequestOptions()
		options.canHandleAdjustmentData = { adjustmentData in
			return adjustmentData.formatIdentifier == formatIdentifier && adjustmentData.formatVersion == formatVersion
		}
		
		// Check whether the asset supports the content editing operation
		if !asset.canPerform(.content) { return }
		
		// Request PHContentEditingInput
		asset.requestContentEditingInput(with: options, completionHandler: { input, info in
			guard let input = input else { fatalError("can't get content editing input: \(info)") }
			
			// Create PHAdjustmentData
			let adjustmentData = PHAdjustmentData(formatIdentifier: formatIdentifier,
												  formatVersion: formatVersion,
												  data: filterName.data(using: .utf8)!)
			
			// Create PHContentEditingOutput and set PHAdjustmentData
			let output = PHContentEditingOutput(contentEditingInput: input)
			output.adjustmentData = adjustmentData
			
			// Create PHLivePhotoEditingContext from PHContentEditingInput
			guard let livePhotoContext = PHLivePhotoEditingContext(livePhotoEditingInput: input) else { fatalError("can't get live photo to edit") }
			
			// Set frameProcessor
			livePhotoContext.frameProcessor = { frame, _ in
                return frame.image.applyingFilter(filterName)
			}
			
			livePhotoContext.prepareLivePhotoForPlayback(withTargetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), options: nil, completionHandler: { photo, error in
				self.livePhotoView?.livePhoto = photo
			})
		})
	}
	
	static func convert(cmage:CIImage) -> UIImage
	{
		let context:CIContext = CIContext.init(options: nil)
		let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
		let image:UIImage = UIImage.init(cgImage: cgImage)
		return image
	}
	
	private func revertAsset() {
		guard let asset = self.asset else { return }
		
		// Commit the edit to the Photos library.
		PHPhotoLibrary.shared().performChanges({
			let request = PHAssetChangeRequest(for: asset)
			request.revertAssetContentToOriginal()
		}, completionHandler: { success, error in
			if !success { print(Date(), #function, #line, "can't revert asset: \(error)")
			}
		})
	}
}

// MARK: - PHPhotoLibraryChangeObserver

extension InspirationsViewController: PHPhotoLibraryChangeObserver {
	func photoLibraryDidChange(_ changeInstance: PHChange) {
		guard let asset = self.asset else { return }
		
		// Call might come on any background queue. Re-dispatch to the main queue to handle it.
		DispatchQueue.main.sync {
			// Check if there are changes to the asset we're displaying.
			guard let details = changeInstance.changeDetails(for: asset) else { return }
			
			// Get the updated asset.
			self.asset = details.objectAfterChanges as? PHAsset
			
			// If the asset's content changed, update the image and stop any video playback.
			if details.assetContentChanged {
				self.updateImage()
			}
		}
	}
}

// MARK: - UINavigationControllerDelegate

extension InspirationsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Get PHAsset
        let fetchResult = info[UIImagePickerController.InfoKey.phAsset] as! PHAsset?
        self.asset = fetchResult

        self.updateImage()
        
        IAPManager.shared().resetPhoto()

        picker.dismiss(animated: true, completion: nil)
    }
}

extension InspirationsViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return (showingPhoto != nil) ? images.count : 2
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if indexPath.row < images.count {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
			cell.imageView.delegate = self
			
//			cell.imageView.shouldPresent(detailVC, from: self, fullscreen: true)
			
			cell.inspiration = images[indexPath.item]
			cell.imageView.backgroundColor = collectionView.backgroundColor
			return cell
		} else {
			if indexPath.item == 0 {
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath) as! ButtonCell
				cell.loadTapped = { [unowned self] (buttonCell) -> Void in
					self.showImagePicker()
				}
				cell.countLabel.clipsToBounds = true
				cell.labelBackgroundView.isHidden = IAPManager.shared().fullPurchased
				cell.resetCountDownLabel.isHidden = IAPManager.shared().fullPurchased
				cell.countLabel.text = "Free: \(IAPManager.shared().photoLeft)"
				cell.resetCountDownLabel.text = "\(IAPManager.shared().getNextResetDay()) days until reset"
				return cell
			} else {
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreditCell", for: indexPath)
				return cell
			}
		}
		
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let layout = collectionViewLayout as! UltravisualLayout
//        let offset = layout.dragOffset * CGFloat(indexPath.item)
//        if collectionView.contentOffset.y != offset - layout.positionOffset * layout.highlightPositionIndex {
//			print(offset - layout.positionOffset * layout.highlightPositionIndex)
//            collectionView.setContentOffset(CGPoint(x: 0, y: offset - layout.positionOffset * layout.highlightPositionIndex), animated: true)
//		} else {
////			self.applyFilter(effectList[indexPath.item])
//		}
    }
	
	
}

extension InspirationsViewController: CardDelegate {
	func cardDidTapInside(card: Card) {
		detailVC!.asset = self.asset
		detailVC!.view.backgroundColor = UIColor.clear// collectionView.backgroundColor
		if let card = card as? CardArticle {
			detailVC!.filterName = card.category
		}
		card.shouldPresent(detailVC, from: self, fullscreen: true)
	}
	func cardWillShowDetailView(card: Card) {
		navigationController?.setNavigationBarHidden(true, animated: true)
	}
	func cardWillCloseDetailView(card: Card) {
		navigationController?.setNavigationBarHidden(false, animated: true)
	}
	func cardDidCloseDetailView(card: Card) {
//		detailVC = storyboard?.instantiateViewController(withIdentifier: "CardContent") as? CardContentViewController
	}
	func cardDidShowDetailView(card: Card) {
		
	}
}

extension InspirationsViewController: FCAlertViewDelegate {
	func FCAlertDoneButtonClicked(alertView: FCAlertView) {
		//iap
		IAPManager.shared().purchaseMyProduct(index: 0)
	}
	func alertView(alertView: FCAlertView, clickedButtonIndex index: Int, buttonTitle title: String) {
		if title == "Wait" && IAPManager.shared().photoLeft > 0 {
			presentImagePicker()
		}
	}
}

extension InspirationsViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize {
		var size = CGSize.zero
		if images.count <= 0 && sizeForItemAt.item == 1 {
			size = CGSize(width: self.view.frame.size.width - 48, height: 100)
		} else {
			size = CGSize(width: self.view.frame.size.width - 48, height: (self.view.frame.size.width - 48) * 5/4)
			if self.view.frame.size.width > 700 || self.view.frame.size.height / self.view.frame.size.width < 0.7 {
				size = CGSize(width: size.width/2.2, height: size.height/2.2)
			}
		}
		return size
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 20
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 20
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24)
	}
}
