//
//  KitCollectionViewCell.swift
//  Indi
//
//  Created by Alexander Sivko on 19.05.23.
//

import UIKit

class KitSelectionCollectionViewCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var background: UIView!
    @IBOutlet var testResultBackground: UIView!
    @IBOutlet var testResultLabel: UILabel!
    @IBOutlet var progressView: UIView!
    @IBOutlet var progressViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tuneUI()
    }
    
    private func tuneUI() {
        background.backgroundColor = UIColor.indiLightPink
        self.layer.cornerRadius = 20
        label.adjustsFontSizeToFitWidth = true
        testResultBackground.backgroundColor = UIColor.indiMainBlue
        progressView.backgroundColor = UIColor.indiSaturatedPink
    }
}
