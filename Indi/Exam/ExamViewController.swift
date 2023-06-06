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
    @IBOutlet var bottomImage: UIImageView!
    
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
        questionBackground.layer.borderColor = CGColor(red: 250 / 255, green: 185 / 255, blue: 26 / 255, alpha: 1)
        questionBackground.layer.borderWidth = 5
        
        questionLabel.textColor = UIColor(red: 54 / 255, green: 63 / 255, blue: 242 / 255, alpha: 1)
        questionLabel.adjustsFontSizeToFitWidth = true
        
        answerResultImage.isHidden = true
        
        textField.delegate = self
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        
        rootView.backgroundColor = UIColor(red: 54 / 255, green: 63 / 255, blue: 242 / 255, alpha: 1)
        
        bottomImage.image = UIImage(named: "AppIcon_noBackground")
    }
}

extension ExamViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        examModel.userAnswer = textField.text
        rootView.isUserInteractionEnabled = false
        if examModel.isRightAnswerCheck() {
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
