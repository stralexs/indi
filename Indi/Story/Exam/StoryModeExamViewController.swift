//
//  StoryModeExamViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 20.05.23.
//

import RxSwift
import RxCocoa

final class StoryModeExamViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet var questionBackground: UIView!
    @IBOutlet var questionsCountLabel: UILabel!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var textField: UITextField!
    @IBOutlet var answerResultImage: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var examResultLabel: UILabel!
    
    var viewModel: (StoryModeExamViewModelData & StoryModeExamViewModelLogic)!
    private let disposeBag = DisposeBag()
    
    //MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tuneUI()
        addTapGesture()
        setupExam()
        setupExamResults()
        setupQuestionsCounter()
        setupExamResultsInfo()
    }
}

    // MARK: - Rx setup
extension StoryModeExamViewController {
    private func setupExam() {
        viewModel.questions
            .map { $0.first }
            .subscribe(onNext: { question in
                self.questionLabel.text = question?.question
            })
            .disposed(by: disposeBag)
        
        viewModel.answerResult.bind(onNext: { result in
            self.presentResult(isAnswerCorrect: result)
        })
        .disposed(by: disposeBag)
        
        textField.rx.controlEvent([.editingDidEndOnExit])
            .asObservable()
            .bind(onNext: {
                self.view.isUserInteractionEnabled = false
                self.viewModel.exam(textField: self.textField.text)
                self.textField.text = ""
            })
            .disposed(by: disposeBag)
    }
    
    private func setupExamResults() {
        viewModel.examResult.bind(onNext: { examResult in
            let alert = UIAlertController(title: "Ваш результат: \(examResult)%", message: nil, preferredStyle: .alert)
            
            let backAction = UIAlertAction(title: "В главное меню", style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            }
            let onceAgainAction = UIAlertAction(title: "Попробовать ещё раз", style: .cancel) { _ in
                self.viewModel.examStart()
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
    
    private func setupExamResultsInfo() {
        viewModel.userExamResults.bind(onNext: { result in
            if result == 0 {
                self.descriptionLabel.isHidden = true
                self.examResultLabel.isHidden = true
            } else {
                self.examResultLabel.text = "\(result)%"
            }
        })
        .disposed(by: disposeBag)
    }
}

    // MARK: - Functionality
extension StoryModeExamViewController {
    private func tuneUI() {
        questionBackground.layer.borderColor = UIColor.indiMainYellow.cgColor
        questionBackground.layer.borderWidth = 5
    }
    
    private func presentResult(isAnswerCorrect: Bool) {
        let image = isAnswerCorrect ? UIImage(named: "Right_png") : UIImage(named: "Wrong_png")
        
        self.viewModel.playSound(isAnswerCorrect)
        self.answerResultImage.image = image
        self.questionLabel.isHidden = true
        self.answerResultImage.isHidden = false
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.viewModel.nextQuestion()
            self.questionLabel.isHidden = false
            self.answerResultImage.isHidden = true
            self.view.isUserInteractionEnabled = true
        }
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
