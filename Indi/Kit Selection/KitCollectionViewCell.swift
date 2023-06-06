//
//  KitCollectionViewCell.swift
//  Indi
//
//  Created by Alexander Sivko on 19.05.23.
//

import UIKit

class KitCollectionViewCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var background: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tuneUI()
    }
    
    private func tuneUI() {
        background.backgroundColor = UIColor(red: 1, green: 200 / 255, blue: 199 / 255, alpha: 1)
        self.layer.cornerRadius = 20
        label.adjustsFontSizeToFitWidth = true
    }
}
