//
//  NetworkingViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 25.05.23.
//

import UIKit

class NetworkingViewController: UIViewController {
    @IBOutlet var background: UIView!
    @IBOutlet var networkBackground: UIView!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var newKitLabel: UILabel!
    @IBOutlet var newKitEditButton: UIButton!
    
    @IBOutlet var newKitStudyStageButton: UIButton!
    
    @IBOutlet var addNewKitButton: UIButton!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var noInternetImage: UIImageView!
    @IBOutlet var noInternetLabel: UILabel!
    
    private let networkingModel = NetworkingModel()
    
    private var questions: [Question] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tuneUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(noInternetConnectionAlert(_:)), name: Notification.Name(rawValue: noInternetConnectionNotificationKey), object: nil)
        
        networkingModel.retrieveQuestions { questions in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.questions = questions
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func noInternetConnectionAlert(_ notification: NSNotification) {
        DispatchQueue.main.async { [self] in
            let alert = UIAlertController(title: "Нет соединения с интернетом", message: "Пожалуйста, проверьте ваше подключение и попробуйте ещё раз", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(okAction)
            
            present(alert, animated: true)
            
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            noInternetImage.isHidden = false
            noInternetLabel.isHidden = false
        }
    }
    
    private func tuneUI() {
        background.backgroundColor = UIColor(red: 54 / 255, green: 63 / 255, blue: 242 / 255, alpha: 1)
        networkBackground.backgroundColor = UIColor(red: 1, green: 102 / 255, blue: 102 / 255, alpha: 1)
        networkBackground.layer.cornerRadius = 10
        
        newKitStudyStageButton.backgroundColor = UIColor(red: 1, green: 200 / 255, blue: 199 / 255, alpha: 1)
        newKitStudyStageButton.layer.cornerRadius = 10
        newKitStudyStageButton.tintColor = UIColor(red: 54 / 255, green: 63 / 255, blue: 242 / 255, alpha: 1)
        
        addNewKitButton.backgroundColor = UIColor(red: 1, green: 200 / 255, blue: 199 / 255, alpha: 1)
        addNewKitButton.layer.cornerRadius = 10
        addNewKitButton.tintColor = UIColor(red: 54 / 255, green: 63 / 255, blue: 242 / 255, alpha: 1)
        addNewKitButton.titleLabel?.numberOfLines = 3
        addNewKitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        addNewKitButton.titleLabel?.textAlignment = .center
        
        tableView.layer.cornerRadius = 20
        tableView.dataSource = self
        
        activityIndicator.startAnimating()
        noInternetImage.image = UIImage(named: "Dino-no-internet")
        noInternetImage.isHidden = true
        noInternetLabel.isHidden = true
    }
    
    @IBAction func nameKitButtonIsPressed(_ sender: UIButton) {
        let newKitNameAlert = UIAlertController(title: "Введите название нового набора слов:", message: nil, preferredStyle: .alert)
        newKitNameAlert.addTextField() { textField in
            textField.clearButtonMode = .whileEditing
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let continueAction = UIAlertAction(title: "Готово", style: .default) { _ in
            if newKitNameAlert.textFields?.first?.text == Optional("") {
                let emptyTextFieldAlert = UIAlertController(title: "Пожалуйста, введите название набора", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
                    self.present(newKitNameAlert, animated: true)
                }
                emptyTextFieldAlert.addAction(okAction)
                self.present(emptyTextFieldAlert, animated: true)
            } else if newKitNameAlert.textFields?.first?.text!.count ?? 0 > 15 {
                let extraLongNameAlert = UIAlertController(title: "Название набора не может быть длиннее 15 символов", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
                    self.present(newKitNameAlert, animated: true)
                }
                extraLongNameAlert.addAction(okAction)
                self.present(extraLongNameAlert, animated: true)
            } else {
                self.networkingModel.newNetworkKitName = newKitNameAlert.textFields?.first?.text
                self.newKitLabel.text = newKitNameAlert.textFields?.first?.text
            }
        }
        newKitNameAlert.addAction(cancelAction)
        newKitNameAlert.addAction(continueAction)
            
        self.present(newKitNameAlert, animated: true)
    }
    
    
    @IBAction func studyStageButtonIsPressed(_ sender: UIButton) {
        let newKitStudyStageAlert = UIAlertController(title: "Выберите стадию обучения, в которую нужно добавить набор", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let newbornAction = UIAlertAction(title: "\(StudyStage.newborn.getStudyStageName())", style: .default) {_ in
            self.networkingModel.newNetworkKitStudyStage = Int(StudyStage.newborn.rawValue)
            self.newKitStudyStageButton.setTitle("\(StudyStage.newborn.getStudyStageName())", for: .normal)
        }
        let preschoolAction = UIAlertAction(title: "\(StudyStage.preschool.getStudyStageName())", style: .default) {_ in
            self.networkingModel.newNetworkKitStudyStage = Int(StudyStage.preschool.rawValue)
            self.newKitStudyStageButton.setTitle("\(StudyStage.preschool.getStudyStageName())", for: .normal)
        }
        let earlySchoolAction = UIAlertAction(title: "\(StudyStage.earlySchool.getStudyStageName())", style: .default) {_ in
            self.networkingModel.newNetworkKitStudyStage = Int(StudyStage.earlySchool.rawValue)
            self.newKitStudyStageButton.setTitle("\(StudyStage.earlySchool.getStudyStageName())", for: .normal)
        }
        let highSchoolAction = UIAlertAction(title: "\(StudyStage.highSchool.getStudyStageName())", style: .default) {_ in
            self.networkingModel.newNetworkKitStudyStage = Int(StudyStage.highSchool.rawValue)
            self.newKitStudyStageButton.setTitle("\(StudyStage.highSchool.getStudyStageName())", for: .normal)
        }
        let lifeActivitiesAction = UIAlertAction(title: "\(StudyStage.lifeActivities.getStudyStageName())", style: .default) {_ in
            self.networkingModel.newNetworkKitStudyStage = Int(StudyStage.lifeActivities.rawValue)
            self.newKitStudyStageButton.setTitle("\(StudyStage.lifeActivities.getStudyStageName())", for: .normal)
        }
        let programmingUniversityAction = UIAlertAction(title: "\(StudyStage.programmingUniversity.getStudyStageName())", style: .default) {_ in
            self.networkingModel.newNetworkKitStudyStage = Int(StudyStage.programmingUniversity.rawValue)
            self.newKitStudyStageButton.setTitle("\(StudyStage.programmingUniversity.getStudyStageName()))", for: .normal)
        }
        let constructionUniversityAction = UIAlertAction(title: "\(StudyStage.constructionUniversity.getStudyStageName())", style: .default) {_ in
            self.networkingModel.newNetworkKitStudyStage = Int(StudyStage.constructionUniversity.rawValue)
            self.newKitStudyStageButton.setTitle("\(StudyStage.constructionUniversity.getStudyStageName())", for: .normal)
        }
        let sideJobAction = UIAlertAction(title: "\(StudyStage.sideJob.getStudyStageName()))", style: .default) {_ in
            self.networkingModel.newNetworkKitStudyStage = Int(StudyStage.sideJob.rawValue)
            self.newKitStudyStageButton.setTitle("\(StudyStage.sideJob.getStudyStageName())", for: .normal)
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
    
    
    @IBAction func addNetworkKitButtonIsPressed(_ sender: Any) {
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
        } else {
            networkingModel.createNewKit()
            let alert = UIAlertController(title: "Новый набор успешно создан!", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default) {_ in
                self.navigationController?.popToRootViewController(animated: true)
            }
            
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
}

extension NetworkingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NetworkingTableViewCell
        cell.questionLabel.text = questions[indexPath.row].question
        cell.correctAnswerLabel.text = questions[indexPath.row].correctAnswer
        cell.firstIncorrectAnswer.text = questions[indexPath.row].incorrectAnswers?[0]
        cell.secondIncorrectAnswer.text = questions[indexPath.row].incorrectAnswers?[1]
        cell.thirdIncorrectAnswer.text = questions[indexPath.row].incorrectAnswers?[2]
        
        return cell
    }
}
