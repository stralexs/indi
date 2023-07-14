//
//  NewKitViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 1.07.23.
//

import UIKit

class NewKitViewController: UIViewController {
    //MARK: - Variables
    @IBOutlet var background: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var newKitLabel: UILabel!
    @IBOutlet var newKitEditButton: UIButton!
    @IBOutlet var newKitStudyStageButton: UIButton!
    @IBOutlet var addNewKitButton: UIButton!
                
    var viewModel: NewKitViewModel!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tuneUI()
        setupBinders()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: Notification.Name(rawValue: trainingModeReloadTableViewNotificationKey), object: nil)
    }
    
    //MARK: - Public Methods
    func tuneUI() {
        background.backgroundColor = UIColor.indiMainYellow
        
        newKitStudyStageButton.backgroundColor = UIColor.indiMainBlue
        newKitStudyStageButton.layer.cornerRadius = 10
        newKitStudyStageButton.tintColor = UIColor.white
        
        addNewKitButton.tintColor = UIColor.indiMainBlue
        newKitLabel.textColor = UIColor.indiMainBlue
        newKitEditButton.tintColor = UIColor.indiMainBlue
        
        tableView.layer.cornerRadius = 20
        tableView.dataSource = self
    }
    
    func setupBinders() {
        viewModel.newKitName.bind { [weak self] newNetworkKitName in
            self?.newKitLabel.text = newNetworkKitName
        }
        viewModel.newKitStudyStageName.bind { [weak self] name in
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
                self.viewModel.newKitStudyStage = index - 1
            }
        }
        
        let newbornAction = UIAlertAction(title: viewModel.studyStageTitleName(for: 0), style: .default, handler: completionHandler)
        let preschoolAction = UIAlertAction(title: viewModel.studyStageTitleName(for: 1), style: .default, handler: completionHandler)
        let earlySchoolAction = UIAlertAction(title: viewModel.studyStageTitleName(for: 2), style: .default, handler: completionHandler)
        let highSchoolAction = UIAlertAction(title: viewModel.studyStageTitleName(for: 3), style: .default, handler: completionHandler)
        let lifeActivitiesAction = UIAlertAction(title: viewModel.studyStageTitleName(for: 4), style: .default, handler: completionHandler)
        let programmingUniversityAction = UIAlertAction(title: viewModel.studyStageTitleName(for: 5), style: .default, handler: completionHandler)
        let constructionUniversityAction = UIAlertAction(title: viewModel.studyStageTitleName(for: 6), style: .default, handler: completionHandler)
        let sideJobAction = UIAlertAction(title: viewModel.studyStageTitleName(for: 7), style: .default, handler: completionHandler)
        
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
    
    @IBAction func addNewKit(_ sender: UIButton) {
        let newKitResult = viewModel.createNewKit()
        
        if newKitResult == "No questions" {
            let alert = UIAlertController(title: "В наборе должен быть хотя бы один вопрос", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        } else if newKitResult == "No kit name" {
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
            let okAction = UIAlertAction(title: "Ок", style: .default) { [weak self] _ in
                self?.nameKitButtonIsPressed(nil)
            }
            nameAlreadyExistsAlert.addAction(okAction)
            self.present(nameAlreadyExistsAlert, animated: true)
            
        } else {
            let kitCreatedAlert = UIAlertController(title: "Новый набор успешно создан!", message: "Удалить набор можно долгим нажатием", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default) { [weak self] _ in
                self?.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
            }
            kitCreatedAlert.addAction(okAction)
            self.present(kitCreatedAlert, animated: true)
        }
    }
    
    @IBAction func cancelButtonIsPressed(_ sender: UIButton) {
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

//MARK: - TableView Data Source
extension NewKitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewKitTableViewCell
        let cellViewModel = viewModel.cellViewModel(for: indexPath)
        cell.viewModel = cellViewModel
        return cell
    }
}
