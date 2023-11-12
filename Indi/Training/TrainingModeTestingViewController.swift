//
//  TrainingModeTestingViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 22.05.23.
//

import RxSwift
import RxCocoa

final class TrainingModeTestingViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet var questionBackground: UIView!
    @IBOutlet var answersButtons: [UIButton]!
    @IBOutlet var questionsCountLabel: UILabel!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var answerResultImage: UIImageView!
    @IBOutlet var progressView: UIProgressView!
    
    var viewModel: (TrainingModeTestingViewModelData & TrainingModeTestingViewModelLogic)!
    private let disposeBag = DisposeBag()
    
    //MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tuneUI()
        setupTraining()
        setupTrainingResults()
        setupUIElements()
    }
}

    // MARK: - Rx setup
extension TrainingModeTestingViewController {
    private func setupTraining() {
        viewModel.questions
            .map { $0.first }
            .subscribe(onNext: { question in
                self.questionLabel.text = question?.question
                for button in self.answersButtons {
                    button.setTitle(question?.randomAnswers[button.tag], for: .normal)
                }
            },
            onCompleted: {
                self.presentBasicAlert(title: "Поздравляем, все слова выучены!", message: nil, actions: [.backToMenu]) { _ in
                    self.navigationController?.popToRootViewController(animated: true)
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
    
    private func setupTrainingResults() {
        viewModel.trainingResult.bind(onNext: { trainingResult in
            let alert = UIAlertController(title: "Слов выучено: \(trainingResult.0)/\(trainingResult.1)", message: nil, preferredStyle: .alert)
            
            let backAction = UIAlertAction(title: "В главное меню", style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            }
            let onceAgainAction = UIAlertAction(title: "Продолжить учить оставшиеся", style: .cancel) {_ in
                self.viewModel.anotherTest()
            }
            alert.addAction(backAction)
            alert.addAction(onceAgainAction)
            
            self.present(alert, animated: true)
        })
        .disposed(by: disposeBag)
    }
    
    private func setupUIElements() {
        viewModel.testingProgress.bind(onNext: {
            self.progressView.progress = $0
        })
        .disposed(by: disposeBag)
        
        viewModel.questionsCount.bind(onNext: {
            self.questionsCountLabel.text = $0
        })
        .disposed(by: disposeBag)
    }
}

    // MARK: - Functionality
extension TrainingModeTestingViewController {
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
