//
//  ButtonCell.swift
//  LivePhotoEditor
//
//  Created by Bliss Watchaye on 2018-07-07.
//  Copyright © 2018 Shingo Hiraya. All rights reserved.
//

import UIKit

class ButtonCell: UICollectionViewCell {
	
	@IBOutlet weak var resetCountDownLabel: UILabel!
	@IBOutlet weak var labelBackgroundView: UIView!
	var loadTapped: ((UICollectionViewCell) -> Void)?
	@IBOutlet weak var countLabel: UILabel!
	@IBAction func loadPress(_ sender: Any) {
		loadTapped?(self)
	}
	
	override func didMoveToSuperview() {
		labelBackgroundView.layer.cornerRadius = labelBackgroundView.frame.size.height/2
		countLabel.textAlignment = .center
	}
}
