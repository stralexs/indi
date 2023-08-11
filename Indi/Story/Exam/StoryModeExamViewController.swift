//
//  StoryModeExamViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 20.05.23.
//

import UIKit

final class StoryModeExamViewController: UIViewController {
    //MARK: - Variables
    @IBOutlet var questionBackground: UIView!
    @IBOutlet var questionsCountLabel: UILabel!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var textField: UITextField!
    @IBOutlet var answerResultImage: UIImageView!
    @IBOutlet var rootView: UIView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var examResultLabel: UILabel!
    @IBOutlet var bottomBackgroundView: UIView!
    
    var viewModel: StoryModeExamViewModelProtocol!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tuneUI()
        addTapGesture()
        showUserResultsInfo()
        viewModel.testStart()
        viewModel.test(questionLabel: questionLabel, buttons: nil, countLabel: questionsCountLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentResult(_:)), name: Notification.Name(rawValue: examResultNotificationKey), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.resetResults()
    }
    
    //MARK: - Methods
    @objc private func presentResult(_ notification: NSNotification) {
        if let result = notification.object {
            let alert = UIAlertController(title: "Ваш результат: \(result)%", message: nil, preferredStyle: .alert)
            
            let backAction = UIAlertAction(title: "В главное меню", style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            }
            let onceAgainAction = UIAlertAction(title: "Попробовать ещё раз", style: .cancel) {_ in
                self.viewModel.testStart()
                self.viewModel.test(questionLabel: self.questionLabel, buttons: nil, countLabel: self.questionsCountLabel)
            }
            alert.addAction(backAction)
            alert.addAction(onceAgainAction)
            
            self.present(alert, animated: true)
        }
    }
    
    private func tuneUI() {
        questionBackground.layer.cornerRadius = 20
        questionBackground.layer.borderColor = UIColor.indiMainYellow.cgColor
        questionBackground.layer.borderWidth = 5
        
        questionLabel.textColor = UIColor.indiMainBlue
        questionLabel.adjustsFontSizeToFitWidth = true
        
        answerResultImage.isHidden = true
        
        textField.delegate = self
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        
        bottomBackgroundView.backgroundColor = UIColor.indiMainBlue
        bottomBackgroundView.layer.cornerRadius = 30
                
        examResultLabel.textColor = UIColor.white
        descriptionLabel.textColor = UIColor.indiMainYellow
    }
    
    private func showUserResultsInfo() {
        if viewModel.userResultForExam() == 0 {
            descriptionLabel.isHidden = true
            examResultLabel.isHidden = true
        } else {
            examResultLabel.text = "\(viewModel.userResultForExam())%"
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

    //MARK: - TextField Delegate
extension StoryModeExamViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.userAnswer = textField.text
        rootView.isUserInteractionEnabled = false
        if viewModel.isRightAnswerCheck() {
            SoundManager.shared.playCorrectSound()
            answerResultImage.image = UIImage(named: "Right_png")
            questionLabel.isHidden = true
            answerResultImage.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                self?.viewModel.nextQuestion()
                self?.viewModel.test(questionLabel: self?.questionLabel, buttons: nil, countLabel: self?.questionsCountLabel)
                self?.answerResultImage.isHidden = true
                self?.questionLabel.isHidden = false
                self?.rootView.isUserInteractionEnabled = true
            }
        } else {
            SoundManager.shared.playWrongSound()
            answerResultImage.image = UIImage(named: "Wrong_png")
            questionLabel.isHidden = true
            answerResultImage.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                self?.viewModel.nextQuestion()
                self?.viewModel.test(questionLabel: self?.questionLabel, buttons: nil, countLabel: self?.questionsCountLabel)
                self?.answerResultImage.isHidden = true
                self?.questionLabel.isHidden = false
                self?.rootView.isUserInteractionEnabled = true
            }
        }
        textField.text = ""
        return true
    }
}
