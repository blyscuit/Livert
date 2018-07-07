//
//  ButtonCell.swift
//  LivePhotoEditor
//
//  Created by Bliss Watchaye on 2018-07-07.
//  Copyright © 2018 Shingo Hiraya. All rights reserved.
//

import UIKit

class ButtonCell: UICollectionViewCell {
	
	var loadTapped: ((UICollectionViewCell) -> Void)?
	
	@IBAction func loadPress(_ sender: Any) {
		loadTapped?(self)
	}
}
