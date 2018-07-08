//
//  DetailViewController.swift
//  Demo
//
//  Created by Paolo Cuscela on 03/11/17.
//  Copyright © 2017 Paolo Cuscela. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class CardContentViewController: UIViewController {

	var asset: PHAsset?
	var filterName: String?
    override func viewDidLoad() {
    }
	
	override func viewWillAppear(_ animated: Bool) {
		statusBarHidden = true
	}
	override func viewDidDisappear(_ animated: Bool) {
		statusBarHidden = false
	}
	var statusBarHidden = false {
		didSet {
			UIView.animate(withDuration: 0.5) { () -> Void in
				self.setNeedsStatusBarAppearanceUpdate()
			}
		}
	}
	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return UIStatusBarAnimation.slide
	}
	override var prefersStatusBarHidden: Bool {
		return statusBarHidden
	}
	
    @IBAction func doMagic(_ sender: Any) {
		guard let filterName = self.filterName else { return }
        applyFilter(filterName)
        
        
    }
	
	func showAlert() {
		let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
		
		alert.view.tintColor = UIColor.black
		let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
		loadingIndicator.hidesWhenStopped = true
		loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
		loadingIndicator.startAnimating();
		
		alert.view.addSubview(loadingIndicator)
		present(alert, animated: true, completion: nil)
	}
	
	fileprivate func applyFilter(_ filterName: String) {
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
		
		self.showAlert()
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
			guard let livePhotoContext = PHLivePhotoEditingContext(livePhotoEditingInput: input) else {
				//				fatalError("can't get live photo to edit")
				// not live
				
				
				self.dismiss(animated: false, completion: nil)
				return
			}
			
			// Set frameProcessor
			livePhotoContext.frameProcessor = { frame, _ in
				return frame.image.applyingFilter(filterName, withInputParameters: nil)
			}
			self.dismiss(animated: false, completion: nil)

			// Perform saveLivePhoto
			livePhotoContext.saveLivePhoto(to: output) { success, error in
				if success {
					// Commit the edit to the Photos library.
					PHPhotoLibrary.shared().performChanges({
						let request = PHAssetChangeRequest(for: asset)
						request.contentEditingOutput = output
					}, completionHandler: { success, error in
						if !success {
							print(Date(), #function, #line, "cannot edit asset: \(error)")
						}
					})
				} else {
					let url = input.fullSizeImageURL
					// Generate rendered JPEG data
					if let path = url?.path {
						var image = UIImage(contentsOfFile: path)!
						if #available(iOS 11.0, *) {
							let ciimage = CIImage(image: image)?.applyingFilter(filterName)
							let renderedJPEGData = UIImageJPEGRepresentation(InspirationsViewController.convert(cmage: ciimage!), 0.9)
							// Save JPEG data
							
							
							if let success = try? renderedJPEGData?.write(to: output.renderedContentURL) {
								
								PHPhotoLibrary.shared().performChanges({
									
									let request = PHAssetChangeRequest(for: asset)
									request.contentEditingOutput = output
								}, completionHandler: { success, error in
									if !success {
										print(Date(), #function, #line, "cannot edit asset: \(error)")
									}
								})
							} else {
								
							}
						} else {
							// Fallback on earlier versions
						}
						
						
					}
					// Call completion handler to commit edit to Photos.
					
					// Clean up temporary files, etc.
					
					print(Date(), #function, #line, "cannot output live photo")
				}
			}
		})
	}
	
}
