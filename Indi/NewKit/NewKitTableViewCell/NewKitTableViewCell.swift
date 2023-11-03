//
//  NewKitTableViewCell.swift
//  Indi
//
//  Created by Alexander Sivko on 25.05.23.
//

import RxSwift
import RxCocoa

final class NewKitTableViewCell: UITableViewCell {
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var correctAnswerLabel: UILabel!
    @IBOutlet var firstIncorrectAnswer: UILabel!
    @IBOutlet var secondIncorrectAnswer: UILabel!
    @IBOutlet var thirdIncorrectAnswer: UILabel!
    
    static let identifier = "NewKitTableViewCell"
    private let disposeBag = DisposeBag()
    private var viewModel: NewKitTableViewCellViewModelData?
    
    func configure(with viewModel: NewKitTableViewCellViewModelData) {
        self.viewModel = viewModel
        setupBinders()
    }
    
    private func setupBinders() {
        viewModel?.question.bind { _ in
            self.questionLabel.text = self.viewModel?.question.value.question
            self.correctAnswerLabel.text = self.viewModel?.question.value.correctAnswer
            self.firstIncorrectAnswer.text = self.viewModel?.question.value.incorrectAnswers?[0]
            self.secondIncorrectAnswer.text = self.viewModel?.question.value.incorrectAnswers?[1]
            self.thirdIncorrectAnswer.text = self.viewModel?.question.value.incorrectAnswers?[2]
        }
        .disposed(by: disposeBag)
    }
}
