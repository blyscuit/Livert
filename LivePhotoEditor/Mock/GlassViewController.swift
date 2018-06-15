//
//  GlassViewController.swift
//  UIMock
//
//  Created by 23Perspective on 15/6/2561 BE.
//  Copyright © 2561 23Perspective. All rights reserved.
//

import UIKit

class GlassViewController: UIViewController {
    @IBOutlet weak var bankCollection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        bankCollection.dataSource = self
        bankCollection.delegate = self
        self.bankCollection.register(UINib(nibName: "BankCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")

    }
}

extension GlassViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell", for: indexPath) as! BankCollectionViewCell
        
        return cell
    }
    
    
}

extension GlassViewController: UICollectionViewDelegate {
    
}
