//
//  NetworkingViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 25.05.23.
//

import UIKit

final class NetworkViewController: UIViewController {
    //MARK: - Variables
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
                
    private var viewModel: NetworkViewModel!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = NetworkViewModel()
        tuneUI()
        setupBinders()
        noInternetConnectionAlert()
    }
    
    //MARK: - Private Functions
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
    
    private func noInternetConnectionAlert() {
        if viewModel.isConnectedToInternet == false {
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
    }
    
    private func setupBinders() {
        viewModel.newNetworkKitName.bind { [weak self] newNetworkKitName in
            self?.newKitLabel.text = newNetworkKitName
        }
        viewModel.questions.bind { [weak self] _ in
            self?.viewModel.retrieveQuestions {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.isHidden = true
                    self?.tableView.reloadData()
                }
            }
        }
        viewModel.newNetworkKitStudyStageName.bind { [weak self] name in
            self?.newKitStudyStageButton.setTitle(name, for: .normal)
        }
    }
    
    //MARK: - Alert Controllers
    @IBAction func nameKitButtonIsPressed(_ sender: UIButton?) {
        let newKitNameAlert = UIAlertController(title: "Введите название нового набора слов:", message: nil, preferredStyle: .alert)
        newKitNameAlert.addTextField() { textField in
            textField.clearButtonMode = .whileEditing
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let continueAction = UIAlertAction(title: "Готово", style: .default) { _ in
            let newNameResult = self.viewModel.newKitName(newKitNameAlert.textFields?.first?.text ?? "")
            
            if newNameResult == "Empty" {
                let emptyTextFieldAlert = UIAlertController(title: "Пожалуйста, введите корректное название набора", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
                    self.present(newKitNameAlert, animated: true)
                }
                emptyTextFieldAlert.addAction(okAction)
                self.present(emptyTextFieldAlert, animated: true)
                
            } else if newNameResult == "Too long" {
                let extraLongNameAlert = UIAlertController(title: "Название набора не может быть длиннее 30 символов", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
                    self.present(newKitNameAlert, animated: true)
                }
                extraLongNameAlert.addAction(okAction)
                self.present(extraLongNameAlert, animated: true)
            }
        }
        newKitNameAlert.addAction(cancelAction)
        newKitNameAlert.addAction(continueAction)
            
        self.present(newKitNameAlert, animated: true)
    }
    
    @IBAction func studyStageButtonIsPressed(_ sender: UIButton) {
        let newKitStudyStageAlert = UIAlertController(title: "Выберите стадию обучения, в которую нужно добавить набор", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        let completionHandler = { (action: UIAlertAction) -> Void in
            if let index = newKitStudyStageAlert.actions.firstIndex(where: { $0 == action} ) {
                self.viewModel.newNetworkKitStudyStage = index - 1
            }
        }
        
        let newbornAction = UIAlertAction(title: "Newborn", style: .default, handler: completionHandler)
        let preschoolAction = UIAlertAction(title: "Preschool", style: .default, handler: completionHandler)
        let earlySchoolAction = UIAlertAction(title: "Early school", style: .default, handler: completionHandler)
        let highSchoolAction = UIAlertAction(title: "High school", style: .default, handler: completionHandler)
        let lifeActivitiesAction = UIAlertAction(title: "Life activities", style: .default, handler: completionHandler)
        let programmingUniversityAction = UIAlertAction(title: "Programming university", style: .default, handler: completionHandler)
        let constructionUniversityAction = UIAlertAction(title: "Construction university", style: .default, handler: completionHandler)
        let sideJobAction = UIAlertAction(title: "Side jobs)", style: .default, handler: completionHandler)
        
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
        let newKitResult = viewModel.createNewKit()
        
        if newKitResult == "No kit name" {
            let alert = UIAlertController(title: "Пожалуйста, введите название набора слов", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
            
        } else if newKitResult == "No study stage" {
            let alert = UIAlertController(title: "Пожалуйста, выберите стадию обучения, в которую нужно добавить набор", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
            
        } else if newKitResult == "Name already exists" {
            let nameAlreadyExistsAlert = UIAlertController(title: "В выбранной стадии обучения уже существует набор с таким названием", message: "Выберите другое название", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default) {_ in
                self.nameKitButtonIsPressed(nil)
            }
            nameAlreadyExistsAlert.addAction(okAction)
            self.present(nameAlreadyExistsAlert, animated: true)
            
        } else if newKitResult == "Questions not loaded" {
            let questionsNotLoadedAlert = UIAlertController(title: "Вопросы не были загружены", message: "Проверьте подключение и повторите попытку", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default)
            questionsNotLoadedAlert.addAction(okAction)
            self.present(questionsNotLoadedAlert, animated: true)
            
        } else {
            let alert = UIAlertController(title: "Новый набор успешно создан!", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default) {_ in
                self.navigationController?.popToRootViewController(animated: true)
            }
            
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
}

//MARK: - TableView Data Source
extension NetworkViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NetworkTableViewCell
        let cellViewModel = viewModel.cellViewModel(for: indexPath)
        cell.viewModel = cellViewModel
        return cell
    }
}
