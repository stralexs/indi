//
//  TestingViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 1.05.23.
//

import UIKit

final class StoryModeTestingViewController: UIViewController {
    //MARK: - Variables
    @IBOutlet var rootView: UIView!
    @IBOutlet var questionBackground: UIView!
    @IBOutlet var answersButtons: [UIButton]!
    @IBOutlet var questionsCountLabel: UILabel!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var answerResultImage: UIImageView!
    
    var viewModel: StoryModeTestingViewModelProtocol!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tuneUI()
        viewModel.testStart()
        viewModel.test(questionLabel: questionLabel, buttons: answersButtons, countLabel: questionsCountLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentResult(_:)), name: Notification.Name(rawValue: testNotificationKey), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.resetResults()
    }
    
    //MARK: - Methods
    @objc private func presentResult(_ notification: NSNotification) {
        if let result = notification.object {
            let alert = UIAlertController(title: "Ваш результат: \(result)%", message: nil, preferredStyle: .alert)
            
            let backAction = UIAlertAction(title: "К выбору тестов", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            let onceAgainAction = UIAlertAction(title: "Попробовать ещё раз", style: .cancel) {_ in
                self.viewModel.testStart()
                self.viewModel.test(questionLabel: self.questionLabel, buttons: self.answersButtons, countLabel: self.questionsCountLabel)
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
        viewModel.userAnswer = sender.titleLabel?.text
        rootView.isUserInteractionEnabled = false
        if viewModel.isRightAnswerCheck() {
            SoundManager.shared.playCorrectSound()
            questionLabel.isHidden = true
            answerResultImage.image = UIImage(named: "Right_png")
            answerResultImage.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                self?.viewModel.nextQuestion()
                self?.viewModel.test(questionLabel: self?.questionLabel, buttons: self?.answersButtons, countLabel: self?.questionsCountLabel)
                sender.backgroundColor = UIColor.indiMainBlue
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
                self?.viewModel.test(questionLabel: self?.questionLabel, buttons: self?.answersButtons, countLabel: self?.questionsCountLabel)
                sender.backgroundColor = UIColor.indiMainBlue
                self?.answerResultImage.isHidden = true
                self?.questionLabel.isHidden = false
                self?.rootView.isUserInteractionEnabled = true
            }
        }
    }
}
