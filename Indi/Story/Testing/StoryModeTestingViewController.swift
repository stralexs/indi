//
//  TestingViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 1.05.23.
//

import RxSwift
import RxCocoa

final class StoryModeTestingViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet var questionBackground: UIView!
    @IBOutlet var answersButtons: [UIButton]!
    @IBOutlet var questionsCountLabel: UILabel!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var answerResultImage: UIImageView!
    
    var viewModel: (StoryModeTestingViewModelData & StoryModeTestingViewModelLogic)!
    private let disposeBag = DisposeBag()
    
    //MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tuneUI()
        setupTesting()
        setupTestingResults()
        setupQuestionsCounter()
    }
}

// MARK: - Rx setup
extension StoryModeTestingViewController {
    private func setupTesting() {
        viewModel.questions
            .map { $0.first }
            .bind(onNext: { question in
                self.questionLabel.text = question?.question
                for button in self.answersButtons {
                    button.setTitle(question?.randomAnswers[button.tag], for: .normal)
                }
            })
        .disposed(by: disposeBag)
        
        for button in answersButtons {
            button.rx.tap.bind(onNext: {
                button.backgroundColor = UIColor.indiButtonPink
                self.view.isUserInteractionEnabled = false
                self.viewModel.test(titleLabel: button.titleLabel?.text)
            })
            .disposed(by: disposeBag)
        }
        
        viewModel.answerResult.bind(onNext: { result in
            self.presentResult(isAnswerCorrect: result)
        })
        .disposed(by: disposeBag)
    }
    
    private func setupTestingResults() {
        viewModel.testingResult.bind(onNext: { testingResult in
            let alert = UIAlertController(title: "Ваш результат: \(testingResult)%", message: nil, preferredStyle: .alert)
            
            let backAction = UIAlertAction(title: "К выбору тестов", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            let onceAgainAction = UIAlertAction(title: "Попробовать ещё раз", style: .cancel) {_ in
                self.viewModel.testStart()
            }
            alert.addAction(backAction)
            alert.addAction(onceAgainAction)
            
            self.present(alert, animated: true)
        })
        .disposed(by: disposeBag)
    }
    
    private func setupQuestionsCounter() {
        viewModel.questionsCount.bind(onNext: {
            self.questionsCountLabel.text = $0
        })
        .disposed(by: disposeBag)
    }
}

    // MARK: - Functionality
extension StoryModeTestingViewController {
    private func tuneUI() {
        questionBackground.layer.borderColor = UIColor.indiMainYellow.cgColor
        questionBackground.layer.borderWidth = 5
                
        for button in answersButtons {
            button.layer.cornerRadius = 20
            button.backgroundColor = UIColor.indiMainBlue
            button.titleLabel?.numberOfLines = 3
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.textAlignment = .center
        }
    }
    
    private func presentResult(isAnswerCorrect: Bool) {
        let image = isAnswerCorrect ? UIImage(named: "Right_png") : UIImage(named: "Wrong_png")
        
        self.viewModel.playSound(isAnswerCorrect)
        self.answerResultImage.image = image
        self.questionLabel.isHidden = true
        self.answerResultImage.isHidden = false
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.viewModel.nextQuestion()
            self.answersButtons.forEach { $0.backgroundColor = .indiMainBlue }
            self.questionLabel.isHidden = false
            self.answerResultImage.isHidden = true
            self.view.isUserInteractionEnabled = true
        }
    }
}
