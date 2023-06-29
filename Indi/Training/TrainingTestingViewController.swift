//
//  TrainingTestingViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 22.05.23.
//

import UIKit

class TrainingTestingViewController: UIViewController {
    @IBOutlet var rootView: UIView!
    @IBOutlet var questionBackground: UIView!
    @IBOutlet var answersButtons: [UIButton]!
    @IBOutlet var questionsCountLabel: UILabel!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var answerResultImage: UIImageView!
    @IBOutlet var progressView: UIProgressView!
    
    private let trainingTestingModel = TrainingTestingModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tuneUI()
        trainingTestingModel.testStart()
        trainingTestingModel.test(questionLabel: questionLabel, buttons: answersButtons, countLabel: questionsCountLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentResult(_:)), name: Notification.Name(rawValue: workoutResultNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(workoutIsDone(_:)), name: Notification.Name(rawValue: workoutIsDoneNotificationKey), object: nil)
    }
    
    @objc func workoutIsDone(_ notification: NSNotification) {
        let alert = UIAlertController(title: "Поздравляем, все слова выучены!", message: nil, preferredStyle: .alert)
        
        let backAction = UIAlertAction(title: "В главное меню", style: .cancel) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(backAction)
        self.present(alert, animated: true)
    }
    
    @objc func presentResult(_ notification: NSNotification) {
        if let result = notification.object as? [Int] {
            let alert = UIAlertController(title: "Слов выучено: \(result[0])/\(result[1])", message: nil, preferredStyle: .alert)
            
            let backAction = UIAlertAction(title: "В главное меню", style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            }
            let onceAgainAction = UIAlertAction(title: "Продолжить учить оставшиеся", style: .cancel) {_ in
                self.trainingTestingModel.anotherTest()
                self.trainingTestingModel.test(questionLabel: self.questionLabel, buttons: self.answersButtons, countLabel: self.questionsCountLabel)
            }
            alert.addAction(backAction)
            alert.addAction(onceAgainAction)
            
            self.present(alert, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        trainingTestingModel.resetResults()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func tuneUI() {       
        questionBackground.layer.cornerRadius = 20
        questionBackground.layer.borderColor = UIColor.indiMainYellow.cgColor
        questionBackground.layer.borderWidth = 5
        
        questionLabel.textColor = UIColor.indiMainBlue
        questionLabel.adjustsFontSizeToFitWidth = true

        answerResultImage.isHidden = true
        
        progressView.progress = 0
            
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
        trainingTestingModel.userAnswer = sender.titleLabel?.text
        rootView.isUserInteractionEnabled = false
        if trainingTestingModel.isRightAnswerCheck() {
            progressView.progress = Float(trainingTestingModel.testingProgress)
            answerResultImage.image = UIImage(named: "Right_png")
            questionLabel.isHidden = true
            answerResultImage.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [self] _ in
                trainingTestingModel.nextQuestion()
                trainingTestingModel.test(questionLabel: questionLabel, buttons: answersButtons, countLabel: questionsCountLabel)
                sender.backgroundColor = UIColor.indiMainBlue
                questionLabel.isHidden = false
                answerResultImage.isHidden = true
                rootView.isUserInteractionEnabled = true
            }
        } else {
            answerResultImage.image = UIImage(named: "Wrong_png")
            questionLabel.isHidden = true
            answerResultImage.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [self] _ in
                trainingTestingModel.nextQuestion()
                trainingTestingModel.test(questionLabel: questionLabel, buttons: answersButtons, countLabel: questionsCountLabel)
                sender.backgroundColor = UIColor.indiMainBlue
                questionLabel.isHidden = false
                answerResultImage.isHidden = true
                rootView.isUserInteractionEnabled = true
            }
        }
    }
}
