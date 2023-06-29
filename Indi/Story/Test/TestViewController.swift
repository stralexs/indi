//
//  TestViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 1.05.23.
//

import UIKit

class TestViewController: UIViewController {
    @IBOutlet var rootView: UIView!
    @IBOutlet var questionBackground: UIView!
    @IBOutlet var answersButtons: [UIButton]!
    @IBOutlet var questionsCountLabel: UILabel!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var answerResultImage: UIImageView!
    
    private let testingModel = TestingModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tuneUI()
        testingModel.testStart()
        testingModel.test(questionLabel: questionLabel, buttons: answersButtons, countLabel: questionsCountLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentResult(_:)), name: Notification.Name(rawValue: testNotificationKey), object: nil)
    }
    
    @objc func presentResult(_ notification: NSNotification) {
        if let result = notification.object {
            let alert = UIAlertController(title: "Ваш результат: \(result)%", message: nil, preferredStyle: .alert)
            
            let backAction = UIAlertAction(title: "В главное меню", style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            }
            let onceAgainAction = UIAlertAction(title: "Попробовать ещё раз", style: .cancel) {_ in
                self.testingModel.testStart()
                self.testingModel.test(questionLabel: self.questionLabel, buttons: self.answersButtons, countLabel: self.questionsCountLabel)
            }
            alert.addAction(backAction)
            alert.addAction(onceAgainAction)
            
            self.present(alert, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        testingModel.resetResults()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func tuneUI() {
        questionBackground.layer.cornerRadius = 20
        questionBackground.layer.borderColor = UIColor.indiMainYellow.cgColor
        questionBackground.layer.borderWidth = 5
        
        questionLabel.textColor = UIColor.indiMainBlue
        questionLabel.adjustsFontSizeToFitWidth = true
        
        answerResultImage.isHidden = true
        
        for button in answersButtons {
            button.layer.cornerRadius = 20
            button.backgroundColor = UIColor.indiMainBlue
            button.titleLabel?.numberOfLines = 3
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.textAlignment = .center
        }
    }
    
    @IBAction func answerButtonPressed(_ sender: UIButton) {
        sender.backgroundColor = UIColor.indiButtonPink
        testingModel.userAnswer = sender.titleLabel?.text
        rootView.isUserInteractionEnabled = false
        if testingModel.isRightAnswerCheck() {
            questionLabel.isHidden = true
            answerResultImage.image = UIImage(named: "Right_png")
            answerResultImage.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [self] _ in
                testingModel.nextQuestion()
                testingModel.test(questionLabel: questionLabel, buttons: answersButtons, countLabel: questionsCountLabel)
                sender.backgroundColor = UIColor.indiMainBlue
                answerResultImage.isHidden = true
                questionLabel.isHidden = false
                rootView.isUserInteractionEnabled = true
            }
        } else {
            answerResultImage.image = UIImage(named: "Wrong_png")
            questionLabel.isHidden = true
            answerResultImage.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [self] _ in
                testingModel.nextQuestion()
                testingModel.test(questionLabel: questionLabel, buttons: answersButtons, countLabel: questionsCountLabel)
                sender.backgroundColor = UIColor.indiMainBlue
                answerResultImage.isHidden = true
                questionLabel.isHidden = false
                rootView.isUserInteractionEnabled = true
            }
        }
    }
}
