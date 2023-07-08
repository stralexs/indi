//
//  UserNewKitViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import UIKit

final class UserNewKitViewController: NewKitViewController {
    @IBOutlet var addQuestionButton: UIButton!
            
    override func viewDidLoad() {
        viewModel = UserNewKitViewModel()
        super.viewDidLoad()
        tuneUI()
    }
    
    override func tuneUI() {
        super.tuneUI()
        addQuestionButton.backgroundColor = UIColor.indiMainBlue
        addQuestionButton.layer.cornerRadius = 10
    }
    
    @IBAction func addQuestion(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Добавить новый вопрос", message: nil, preferredStyle: .alert)
        alertController.addTextField() { textField in
            textField.placeholder = "Вопрос"
            textField.clearButtonMode = .whileEditing
        }
        alertController.addTextField() { textField in
            textField.placeholder = "Правильный ответ"
            textField.clearButtonMode = .whileEditing
        }
        alertController.addTextField(){ textField in
            textField.placeholder = "Неправильные через запятую"
            textField.clearButtonMode = .whileEditing
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let addAction = UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
            if let viewModel = self?.viewModel as? UserNewKitViewModel {
                let newQuestionResult = viewModel.createNewQuestion(alertController.textFields?[0].text ?? "", alertController.textFields?[1].text ?? "", alertController.textFields?[2].text ?? "")
                
                if newQuestionResult == "Empty fields" {
                    let emptyTextFieldsAlert = UIAlertController(title: "Пожалуйста, заполняйте все поля", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
                        self?.present(alertController, animated: true)
                    }
                    emptyTextFieldsAlert.addAction(okAction)
                    self?.present(emptyTextFieldsAlert, animated: true)
                    
                } else if newQuestionResult == "Too many incorrect" {
                    let wrongIncorrectAnswersNumberAlert = UIAlertController(title: "Число неправильных ответов должно быть от одного до трёх", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
                        self?.present(alertController, animated: true)
                    }
                    wrongIncorrectAnswersNumberAlert.addAction(okAction)
                    self?.present(wrongIncorrectAnswersNumberAlert, animated: true)
                    
                } else if newQuestionResult == "Incorrect contain correct" {
                    let incorrectEqualsCorrectAlert = UIAlertController(title: "Неправильные ответы не могут содержать правильный ответ", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
                        self?.present(alertController, animated: true)
                    }
                    incorrectEqualsCorrectAlert.addAction(okAction)
                    self?.present(incorrectEqualsCorrectAlert, animated: true)
                    
                }
                self?.tableView.reloadData()
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
