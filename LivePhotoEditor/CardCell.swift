//
//  CardCell.swift
//  LivePhotoEditor
//
//  Created by Bliss Watchaye on 2018-07-07.
//  Copyright © 2018 Shingo Hiraya. All rights reserved.
//

import UIKit

class CardCell: UICollectionViewCell {
	
	@IBOutlet weak var imageView: CardArticle!
	@IBOutlet fileprivate weak var imageCoverView: UIView!
	
	@IBOutlet weak var allView: UIView!
	var inspiration:FilterImage?{
		didSet{
			if let inspiration = inspiration{
				imageView.backgroundImage = inspiration.backgroundImage
				imageView.category = inspiration.title
			}
		}
	}
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		clipsToBounds = false
		//imageCoverView?.removeFromSuperview()
	}
	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
		super.apply(layoutAttributes)
		
		// 1
		let standardHeight = UltravisualLayoutConstants.Cell.standardHeight
		let featuredHeight = UltravisualLayoutConstants.Cell.featuredHeight
		
		// 2
		let delta = 1 - ((featuredHeight - frame.height) / (featuredHeight - standardHeight))
		
		// 3
		let minAlpha: CGFloat = 0.3
		let maxAlpha: CGFloat = 0.75
		imageCoverView?.alpha = 0.2 - (delta * (0.2 - 0.01))
	}
}
