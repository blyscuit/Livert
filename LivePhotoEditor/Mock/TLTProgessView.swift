//
//  TLTProgessView.swift
//  TLT
//
//  Created by Nattapong Unaregul on 13/3/18.
//  Copyright © 2018 Toyata. All rights reserved.
//

import UIKit
@IBDesignable
class TLTProgessView: UIControl {
    @IBInspectable
    var height : CGFloat = 5 {
        didSet{

        }
    }
    fileprivate var _progress : CGFloat = 0.5 {
        didSet{
           #if TARGET_INTERFACE_BUILDER
            
           #endif
        }
    }
    @IBInspectable
    var progress : CGFloat {
        get{
            return _progress
        }set{
            _progress = newValue
//            _progress = 0
            CATransaction.setAnimationDuration(0.5)
            CATransaction.setDisableActions(false)
            CATransaction.begin()
            
            updateLayerFrames()
            CATransaction.commit()
        }
    }

    func setUpConstraint()  {
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    lazy var pgLayer : CAShapeLayer = {
        let p = CAShapeLayer()
        return p
    }()
    lazy var pgPath : UIBezierPath = {
        let  p = UIBezierPath()
        return p
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInitilization()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInitilization()
    }
    func sharedInitilization()  {
        self.layer.cornerRadius = 3
        setUpConstraint()
    }
    var hasLayoutSubviews : Bool = false
    override func layoutSubviews() {
        super.layoutSubviews()
        if !hasLayoutSubviews {
            hasLayoutSubviews = true
            self.layer.addSublayer(pgLayer)
            pgPath.move(to: CGPoint(x: 0, y: self.bounds.height / 2))
            pgPath.addLine(to: CGPoint(x: self.bounds.width , y: self.bounds.height / 2))
            pgLayer.path = pgPath.cgPath
            pgLayer.strokeColor = UIColor(red: 107/255, green: 219/255, blue: 189/255, alpha: 1.0).cgColor
            pgLayer.lineWidth = height
            pgLayer.strokeStart = 0.0
            pgLayer.strokeEnd = _progress
            self.clipsToBounds = true
        }
    }
    
    func updateLayerFrames() {
        pgLayer.strokeEnd = _progress
    }
}
