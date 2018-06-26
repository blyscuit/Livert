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
    
    var inspiration:FilterImage?{
        didSet{
            if let inspiration = inspiration{
                imageView.image = inspiration.backgroundImage
                titleLabel.text = inspiration.title
            }
        }
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
        imageCoverView.alpha = maxAlpha - (delta * (maxAlpha - minAlpha))
        timeAndRoomLabel.alpha = delta
        speakerLabel.alpha = delta
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
