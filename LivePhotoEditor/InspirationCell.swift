//
//  InspirationCell.swift
//  ExpandingCollectionView
//
//  Created by Vamshi Krishna on 30/04/17.
//  Copyright © 2017 VamshiKrishna. All rights reserved.
//

import UIKit

class InspirationCell: UICollectionViewCell {
    
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var imageCoverView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var timeAndRoomLabel: UILabel!
    @IBOutlet private weak var speakerLabel: UILabel!
	@IBOutlet weak var roundedView: UIView!
	
	@IBOutlet weak var allView: UIView!
	var inspiration:FilterImage?{
        didSet{
            if let inspiration = inspiration{
                imageView.image = inspiration.backgroundImage
                titleLabel.text = inspiration.title
            }
        }
    }
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		self.allView.layer.shadowRadius = 4
		self.allView.layer.shadowOpacity = 0.2
		self.allView.layer.shadowColor = UIColor.gray.cgColor
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
        imageCoverView.alpha = 0.2 - (delta * (0.2 - 0.01))
        timeAndRoomLabel.alpha = delta
        speakerLabel.alpha = delta
		titleLabel.alpha = maxAlpha - ( (1.0 - delta) * (maxAlpha - minAlpha))
    }
}

class FilterImage: NSObject {
	
	var title: String
	var backgroundImage: UIImage?
	
	init(title:String, backgroundImage:UIImage?){
		self.title = title
		self.backgroundImage = backgroundImage
	}
}
