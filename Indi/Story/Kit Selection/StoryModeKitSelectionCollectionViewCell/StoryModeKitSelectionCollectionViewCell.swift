//
//  StoryModeKitSelectionCollectionViewCell.swift
//  Indi
//
//  Created by Alexander Sivko on 19.05.23.
//

import UIKit

final class StoryModeKitSelectionCollectionViewCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var background: UIView!
    @IBOutlet var testResultBackground: UIView!
    @IBOutlet var testResultLabel: UILabel!
    @IBOutlet var progressView: UIView!
    @IBOutlet var progressViewHeight: NSLayoutConstraint!
    
    var viewModel: StoryModeKitSelectionCollectionViewCellViewModel! {
        didSet {
            viewModel.cellHeight = self.frame.height
            label.text = viewModel.kitName
            testResultLabel.text = "\(viewModel.testResult)%"
            progressViewHeight.constant = viewModel.progressHeight
        }
    }
    
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
