//
//  UserNewKitViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import UIKit

class UserNewKitViewController: UIViewController {
    @IBOutlet var background: UIView!
    
    @IBOutlet var newKitLabel: UILabel!
    @IBOutlet var newKitEditButton: UIButton!
    
    @IBOutlet var newKitStudyStageButton: UIButton!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var addNewKitButton: UIButton!
    
    @IBOutlet var addQuestionButton: UIButton!
    private let newKitModel = UserNewKitModel()
    
    private var namesOfKitsOfSelectedStudyStage: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tuneUI()
    }
    
    private func tuneUI() {
        background.backgroundColor = UIColor.indiMainYellow
        
        newKitStudyStageButton.backgroundColor = UIColor.indiMainBlue
        newKitStudyStageButton.layer.cornerRadius = 10
        newKitStudyStageButton.tintColor = UIColor.white
        
        tableView.layer.cornerRadius = 20
        tableView.dataSource = self
        
        addNewKitButton.tintColor = UIColor.indiMainBlue
        newKitLabel.textColor = UIColor.indiMainBlue
        
        newKitEditButton.tintColor = UIColor.indiMainBlue
        
        addQuestionButton.backgroundColor = UIColor.indiMainBlue
        addQuestionButton.layer.cornerRadius = 10
    }
    
    @IBAction func newKitEditButtonIsPressed(_ sender: UIButton?) {
        let newKitNameAlert = UIAlertController(title: "Введите название нового набора слов:", message: nil, preferredStyle: .alert)
        newKitNameAlert.addTextField() { textField in
            textField.clearButtonMode = .whileEditing
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let continueAction = UIAlertAction(title: "Готово", style: .default) { _ in
            let textWithoutSpaces = self.newKitModel.removingSpaces(for: newKitNameAlert.textFields?.first?.text ?? "")
            
            if newKitNameAlert.textFields?.first?.text == Optional("") {
                let emptyTextFieldAlert = UIAlertController(title: "Пожалуйста, введите название набора", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
                    self.present(newKitNameAlert, animated: true)
                }
                emptyTextFieldAlert.addAction(okAction)
                self.present(emptyTextFieldAlert, animated: true)
            } else if textWithoutSpaces == "" {
                let emptyTextFieldAlert = UIAlertController(title: "Название набора не должно состоять только из пробелов", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
                    self.present(newKitNameAlert, animated: true)
                }
                emptyTextFieldAlert.addAction(okAction)
                self.present(emptyTextFieldAlert, animated: true)
            } else if textWithoutSpaces.count > 30 {
                let extraLongNameAlert = UIAlertController(title: "Название набора не может быть длиннее 30 символов", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
                    self.present(newKitNameAlert, animated: true)
                }
                extraLongNameAlert.addAction(okAction)
                self.present(extraLongNameAlert, animated: true)
            } else {
                self.newKitModel.newKitName = textWithoutSpaces
                self.newKitLabel.text = textWithoutSpaces
            }
        }
        newKitNameAlert.addAction(cancelAction)
        newKitNameAlert.addAction(continueAction)
            
        self.present(newKitNameAlert, animated: true)
    }
    
    @IBAction func newKitStudyStageButtonIsPressed(_ sender: UIButton) {
        let newKitStudyStageAlert = UIAlertController(title: "Выберите стадию обучения, в которую нужно добавить набор", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let newbornAction = UIAlertAction(title: "\(StudyStage.newborn.getStudyStageName())", style: .default) {_ in
            self.newKitModel.newKitStage = Int(StudyStage.newborn.rawValue)
            self.newKitStudyStageButton.setTitle("\(StudyStage.newborn.getStudyStageName())", for: .normal)
            self.namesOfKitsOfSelectedStudyStage = KitsManager.shared.getKitNamesForStudyStage(with: [0])
        }
        let preschoolAction = UIAlertAction(title: "\(StudyStage.preschool.getStudyStageName())", style: .default) {_ in
            self.newKitModel.newKitStage = Int(StudyStage.preschool.rawValue)
            self.newKitStudyStageButton.setTitle("\(StudyStage.preschool.getStudyStageName())", for: .normal)
            self.namesOfKitsOfSelectedStudyStage = KitsManager.shared.getKitNamesForStudyStage(with: [1])
        }
        let earlySchoolAction = UIAlertAction(title: "\(StudyStage.earlySchool.getStudyStageName())", style: .default) {_ in
            self.newKitModel.newKitStage = Int(StudyStage.earlySchool.rawValue)
            self.newKitStudyStageButton.setTitle("\(StudyStage.earlySchool.getStudyStageName())", for: .normal)
            self.namesOfKitsOfSelectedStudyStage = KitsManager.shared.getKitNamesForStudyStage(with: [2])
        }
        let highSchoolAction = UIAlertAction(title: "\(StudyStage.highSchool.getStudyStageName())", style: .default) {_ in
            self.newKitModel.newKitStage = Int(StudyStage.highSchool.rawValue)
            self.newKitStudyStageButton.setTitle("\(StudyStage.highSchool.getStudyStageName())", for: .normal)
            self.namesOfKitsOfSelectedStudyStage = KitsManager.shared.getKitNamesForStudyStage(with: [3])
        }
        let lifeActivitiesAction = UIAlertAction(title: "\(StudyStage.lifeActivities.getStudyStageName())", style: .default) {_ in
            self.newKitModel.newKitStage = Int(StudyStage.lifeActivities.rawValue)
            self.newKitStudyStageButton.setTitle("\(StudyStage.lifeActivities.getStudyStageName())", for: .normal)
            self.namesOfKitsOfSelectedStudyStage = KitsManager.shared.getKitNamesForStudyStage(with: [4])
        }
        let programmingUniversityAction = UIAlertAction(title: "\(StudyStage.programmingUniversity.getStudyStageName())", style: .default) {_ in
            self.newKitModel.newKitStage = Int(StudyStage.programmingUniversity.rawValue)
            self.newKitStudyStageButton.setTitle("\(StudyStage.programmingUniversity.getStudyStageName())", for: .normal)
            self.namesOfKitsOfSelectedStudyStage = KitsManager.shared.getKitNamesForStudyStage(with: [5])
        }
        let constructionUniversityAction = UIAlertAction(title: "\(StudyStage.constructionUniversity.getStudyStageName())", style: .default) {_ in
            self.newKitModel.newKitStage = Int(StudyStage.constructionUniversity.rawValue)
            self.newKitStudyStageButton.setTitle("\(StudyStage.constructionUniversity.getStudyStageName())", for: .normal)
            self.namesOfKitsOfSelectedStudyStage = KitsManager.shared.getKitNamesForStudyStage(with: [6])
        }
        let sideJobAction = UIAlertAction(title: "\(StudyStage.sideJob.getStudyStageName())", style: .default) {_ in
            self.newKitModel.newKitStage = Int(StudyStage.sideJob.rawValue)
            self.newKitStudyStageButton.setTitle("\(StudyStage.sideJob.getStudyStageName())", for: .normal)
            self.namesOfKitsOfSelectedStudyStage = KitsManager.shared.getKitNamesForStudyStage(with: [7])
        }
        
        newKitStudyStageAlert.addAction(cancelAction)
        newKitStudyStageAlert.addAction(newbornAction)
        newKitStudyStageAlert.addAction(preschoolAction)
        newKitStudyStageAlert.addAction(earlySchoolAction)
        newKitStudyStageAlert.addAction(highSchoolAction)
        newKitStudyStageAlert.addAction(lifeActivitiesAction)
        newKitStudyStageAlert.addAction(programmingUniversityAction)
        newKitStudyStageAlert.addAction(constructionUniversityAction)
        newKitStudyStageAlert.addAction(sideJobAction)
        
        self.present(newKitStudyStageAlert, animated: true)
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
        let addAction = UIAlertAction(title: "Добавить", style: .default) { _ in
            
            if alertController.textFields?[0].text == Optional("") || alertController.textFields?[1].text == Optional("") || alertController.textFields?[2].text == Optional("") {
                let emptyTextFieldsAlert = UIAlertController(title: "Пожалуйста, заполняйте все поля", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
                    self.present(alertController, animated: true)
                }
                emptyTextFieldsAlert.addAction(okAction)
                self.present(emptyTextFieldsAlert, animated: true)
                
            } else if self.newKitModel.removingSpaces(for: alertController.textFields?[0].text ?? "") == "" {
                let onlySpacesInQuestionAlert = UIAlertController(title: "Вопрос не может состоять только из пробелов", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
                    self.present(alertController, animated: true)
                }
                onlySpacesInQuestionAlert.addAction(okAction)
                self.present(onlySpacesInQuestionAlert, animated: true)
                
            } else if self.newKitModel.removingSpaces(for: alertController.textFields?[1].text ?? "") == "" {
                let onlySpacesInCorrectAnswerAlert = UIAlertController(title: "Правильный ответ не может состоять только из пробелов", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
                    self.present(alertController, animated: true)
                }
                onlySpacesInCorrectAnswerAlert.addAction(okAction)
                self.present(onlySpacesInCorrectAnswerAlert, animated: true)
                
            } else if self.newKitModel.splitOfIncorrectAnswers(alertController.textFields![2].text!) == ["", "", ""] {
                let onlySpacesInInorrectAnswerAlert = UIAlertController(title: "Неправильные ответы не могут состоять только из пробелов", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
                    self.present(alertController, animated: true)
                }
                onlySpacesInInorrectAnswerAlert.addAction(okAction)
                self.present(onlySpacesInInorrectAnswerAlert, animated: true)
                
            } else if self.newKitModel.splitOfIncorrectAnswers(alertController.textFields![2].text!).count > 3 {
                let wrongIncorrectAnswersNumberAlert = UIAlertController(title: "Число неправильных ответов должно быть от одного до трёх", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
                    self.present(alertController, animated: true)
                }
                wrongIncorrectAnswersNumberAlert.addAction(okAction)
                self.present(wrongIncorrectAnswersNumberAlert, animated: true)
                
            } else if self.newKitModel.splitOfIncorrectAnswers(alertController.textFields![2].text!).contains(alertController.textFields![1].text!) {
                let incorrectEqualsCorrectAlert = UIAlertController(title: "Неправильные ответы не могут содержать правильный ответ", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
                    self.present(alertController, animated: true)
                }
                incorrectEqualsCorrectAlert.addAction(okAction)
                self.present(incorrectEqualsCorrectAlert, animated: true)
                
            } else {
                self.newKitModel.addNewQuestion(self.newKitModel.removingSpaces(for: alertController.textFields![0].text!),
                                                self.newKitModel.removingSpaces(for: alertController.textFields![1].text!),
                                                self.newKitModel.splitOfIncorrectAnswers(alertController.textFields![2].text!))
                self.tableView.reloadData()
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addKit(_ sender: UIButton) {
        if newKitLabel.text == "Название набора" {
            let alert = UIAlertController(title: "Пожалуйста, введите название набора слов", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        } else if newKitStudyStageButton.titleLabel?.text == "Cтадия обучения" {
            let alert = UIAlertController(title: "Пожалуйста, выберите стадию обучения, в которую нужно добавить набор", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        } else if newKitModel.getQuestionsCount() == 0 {
            let alert = UIAlertController(title: "В наборе должен быть хотя бы один вопрос", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        } else if self.namesOfKitsOfSelectedStudyStage.contains(newKitLabel.text!) {
            let nameAlreadyExistsAlert = UIAlertController(title: "В выбранной стадии обучения уже существует набор с таким названием", message: "Выберите другое название", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default) {_ in
                self.newKitEditButtonIsPressed(nil)
            }
            nameAlreadyExistsAlert.addAction(okAction)
            self.present(nameAlreadyExistsAlert, animated: true)
        } else {
            newKitModel.createNewKit()
            let alert = UIAlertController(title: "Новый набор успешно создан!", message: "Удалить набор можно долгим нажатием", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default) {_ in
                self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func cancelButtonIsPressed(_ sender: UIButton) {
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

extension UserNewKitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newKitModel.getQuestionsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserNewKitTableViewCell
        cell.questionLabel.text = newKitModel.getQuestion(for: indexPath).question
        cell.correctAnswerLabel.text = newKitModel.getQuestion(for: indexPath).correctAnswer
        cell.firstIncorrectAnswer.text = newKitModel.getQuestion(for: indexPath).incorrectAnswers![0]
        cell.secondIncorrectAnswer.text = newKitModel.getQuestion(for: indexPath).incorrectAnswers![1]
        cell.thirdIncorrectAnswer.text = newKitModel.getQuestion(for: indexPath).incorrectAnswers![2]
        
        return cell
    }
}
