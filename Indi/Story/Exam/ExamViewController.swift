//
//  ExamViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 20.05.23.
//

import UIKit

class ExamViewController: UIViewController {
    @IBOutlet var questionBackground: UIView!
    @IBOutlet var questionsCountLabel: UILabel!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var textField: UITextField!
    @IBOutlet var answerResultImage: UIImageView!
    @IBOutlet var rootView: UIView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var examResultLabel: UILabel!
    @IBOutlet var bottomBackgroundView: UIView!
    
    private let examModel = ExamModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tuneUI()
        examModel.testStart()
        examModel.test(questionLabel: questionLabel, buttons: nil, countLabel: questionsCountLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentResult(_:)), name: Notification.Name(rawValue: examResultNotificationKey), object: nil)
    }
    
    @objc private func presentResult(_ notification: NSNotification) {
        if let result = notification.object {
            let alert = UIAlertController(title: "Ваш результат: \(result)%", message: nil, preferredStyle: .alert)
            
            let backAction = UIAlertAction(title: "В главное меню", style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            }
            let onceAgainAction = UIAlertAction(title: "Попробовать ещё раз", style: .cancel) {_ in
                self.examModel.testStart()
                self.examModel.test(questionLabel: self.questionLabel, buttons: nil, countLabel: self.questionsCountLabel)
            }
            alert.addAction(backAction)
            alert.addAction(onceAgainAction)
            
            self.present(alert, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        examModel.resetResults()
        NotificationCenter.default.removeObserver(self)
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
        if UserDataManager.shared.getUserResult(for: examModel.examName) == 0 {
            descriptionLabel.isHidden = true
            examResultLabel.isHidden = true
        } else {
            examResultLabel.text = "\(UserDataManager.shared.getUserResult(for: examModel.examName))%"
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ExamViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        examModel.userAnswer = textField.text
        rootView.isUserInteractionEnabled = false
        if examModel.isRightAnswerCheck() {
            SoundManager.shared.playCorrectSound()
            answerResultImage.image = UIImage(named: "Right_png")
            questionLabel.isHidden = true
            answerResultImage.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [self] _ in
                examModel.nextQuestion()
                examModel.test(questionLabel: questionLabel, buttons: nil, countLabel: questionsCountLabel)
                answerResultImage.isHidden = true
                questionLabel.isHidden = false
                rootView.isUserInteractionEnabled = true
            }
        } else {
            SoundManager.shared.playWrongSound()
            answerResultImage.image = UIImage(named: "Wrong_png")
            questionLabel.isHidden = true
            answerResultImage.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [self] _ in
                examModel.nextQuestion()
                examModel.test(questionLabel: questionLabel, buttons: nil, countLabel: questionsCountLabel)
                answerResultImage.isHidden = true
                questionLabel.isHidden = false
                rootView.isUserInteractionEnabled = true
            }
        }
        textField.text = ""
        return true
    }
}
