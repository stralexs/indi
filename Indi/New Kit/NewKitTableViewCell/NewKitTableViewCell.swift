//
//  NewKitTableViewCell.swift
//  Indi
//
//  Created by Alexander Sivko on 25.05.23.
//

import UIKit

final class NewKitTableViewCell: UITableViewCell {
    @IBOutlet var background: UIView!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var correctAnswerLabel: UILabel!
    @IBOutlet var firstIncorrectAnswer: UILabel!
    @IBOutlet var secondIncorrectAnswer: UILabel!
    @IBOutlet var thirdIncorrectAnswer: UILabel!
    
    var viewModel: NewKitTableViewCellViewModel! {
        didSet {
            setupBinders()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tuneUI()
    }
    
    private func tuneUI() {
        background.backgroundColor = UIColor.indiLightPink
    }
    
    private func setupBinders() {
        viewModel.question.bind { [weak self] _ in
            self?.questionLabel.text = self?.viewModel.questionText
            self?.correctAnswerLabel.text = self?.viewModel.correctAnswerText
            self?.firstIncorrectAnswer.text = self?.viewModel.firstIncorrectAnswerText
            self?.secondIncorrectAnswer.text = self?.viewModel.secondIncorrectAnswerText
            self?.thirdIncorrectAnswer.text = self?.viewModel.thirdIncorrectAnswerText
        }
    }
}
