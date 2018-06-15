//
//  BankCollectionView.swift
//  UIMock
//
//  Created by 23Perspective on 15/6/2561 BE.
//  Copyright © 2561 23Perspective. All rights reserved.
//

import UIKit

class BankCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var cellOutline: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    let activeBorderColor = #colorLiteral(red: 0.8941176471, green: 0.5137254902, blue: 0.4196078431, alpha: 1)
    let notActiveBorderColor = #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8823529412, alpha: 1)
    let activeBorderWidth = 2.0
    let notActiveBorderWidth = 0.5
    override var isSelected: Bool{
        didSet{
            self.toggleBorder(self.isSelected)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cellOutline.layer.cornerRadius = 6.0
        cellOutline.layer.borderColor = #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8823529412, alpha: 1)
        cellOutline.layer.borderWidth = 0.5
        cellOutline.layer.applySketchShadow(alpha: 0.2, x: 0, y: 1, blur: 8.8, spread: 0.2)
    }
    
    func toggleBorder(_ active: Bool) {
        if active {
            cellOutline.layer.borderColor = activeBorderColor.cgColor
            cellOutline.layer.borderWidth = CGFloat(activeBorderWidth)
        } else {
            cellOutline.layer.borderColor = notActiveBorderColor.cgColor
            cellOutline.layer.borderWidth = CGFloat(notActiveBorderWidth)
        }
    }

}
