//
//  MockViewController.swift
//  LivePhotoEditor
//
//  Created by 23Perspective on 15/6/2561 BE.
//  Copyright © 2561 Shingo Hiraya. All rights reserved.
//

import UIKit

class MockViewController: UIViewController {

    @IBOutlet weak var progressView: TLTProgessView!
    override func viewDidLoad() {
        progressView.progress = 0.3
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBAction func press(_ sender: Any) {
        progressView.progress = 0.7
    }
    
}
