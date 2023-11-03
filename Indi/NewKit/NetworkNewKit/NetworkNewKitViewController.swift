//
//  NetworkNewKitViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 25.05.23.
//

import RxSwift
import RxCocoa

final class NetworkNewKitViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet var tableView: UITableView!
    @IBOutlet var newKitLabel: UILabel!
    @IBOutlet var newKitStudyStageButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var noInternetImage: UIImageView!
    @IBOutlet var noInternetLabel: UILabel!
    
    private var viewModel: NetworkNewKitViewModelData & NetworkNewKitViewModelLogic
    private let disposeBag = DisposeBag()
    
    //MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinders()
        setupTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reloadTableViewOfTrainingMode()
    }
    
    // MARK: - Initialization
    init?(coder: NSCoder, viewModel: NetworkNewKitViewModelData & NetworkNewKitViewModelLogic) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - Rx Setup
extension NetworkNewKitViewController {
    private func setupBinders() {
        viewModel.newKitName.bind { self.newKitLabel.text = $0 }
        .disposed(by: disposeBag)
        
        viewModel.newKitStudyStageName.bind { self.newKitStudyStageButton.setTitle($0, for: .normal) }
        .disposed(by: disposeBag)
        
        viewModel.questions.bind { _ in
            self.viewModel.retrieveQuestions {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.tableView.reloadData()
                }
            }
        }
        .disposed(by: disposeBag)
        
        viewModel.isConnectedToInternet.bind { isConnected in
            guard let isConnected = isConnected else { return }
            if !isConnected {
                self.presentNoInternetConnectionAlert()
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        viewModel.questions
            .bind(to: tableView
                .rx
                .items(cellIdentifier: NewKitTableViewCell.identifier,
                       cellType: NewKitTableViewCell.self)) { row, question, cell in
                cell.configure(with: self.viewModel.cellViewModel(for: row))
            }
        .disposed(by: disposeBag)
    }
}

// MARK: - Functionality
extension NetworkNewKitViewController {
    private func reloadTableViewOfTrainingMode() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: String.reloadTableView), object: nil)
    }
    
    @IBAction private func nameKitButtonIsPressed(_ sender: UIButton?) {
        let newKitNameAlert = UIAlertController(title: "Введите название нового набора слов:", message: nil, preferredStyle: .alert)
        newKitNameAlert.addTextField() { $0.clearButtonMode = .whileEditing }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let continueAction = UIAlertAction(title: "Готово", style: .default) { _ in
            do {
                try self.viewModel.newKitName(newKitNameAlert.textFields?.first?.text ?? "")
            }
            catch let error {
                switch error as! KitNameError {
                case .empty:
                    self.presentBasicAlert(title: "Пожалуйста, введите корректное название набора", message: nil, actions: [.okAction]) { _ in
                        self.present(newKitNameAlert, animated: true)
                    }
                case .tooLong:
                    self.presentBasicAlert(title: "Название набора не может быть длиннее 30 символов", message: nil, actions: [.okAction]) { _ in
                        self.present(newKitNameAlert, animated: true)
                    }
                }
            }
        }
        newKitNameAlert.addAction(cancelAction)
        newKitNameAlert.addAction(continueAction)
            
        self.present(newKitNameAlert, animated: true)
    }
    
    @IBAction private func studyStageButtonIsPressed(_ sender: UIButton) {
        let newKitStudyStageAlert = UIAlertController(title: "Выберите стадию обучения, в которую нужно добавить набор", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        let completionHandler = { (action: UIAlertAction) -> Void in
            if let index = newKitStudyStageAlert.actions.firstIndex(where: { $0 == action} ) {
                self.viewModel.newKitStudyStage.accept(index - 1)
            }
        }
        
        let newbornAction = UIAlertAction(title: "Newborn", style: .default, handler: completionHandler)
        let preschoolAction = UIAlertAction(title: "Preschool", style: .default, handler: completionHandler)
        let earlySchoolAction = UIAlertAction(title: "Early school", style: .default, handler: completionHandler)
        let highSchoolAction = UIAlertAction(title: "High school", style: .default, handler: completionHandler)
        let lifeActivitiesAction = UIAlertAction(title: "Life activities", style: .default, handler: completionHandler)
        let programmingUniversityAction = UIAlertAction(title: "Programming university", style: .default, handler: completionHandler)
        let constructionUniversityAction = UIAlertAction(title: "Construction university", style: .default, handler: completionHandler)
        let sideJobAction = UIAlertAction(title: "Side jobs", style: .default, handler: completionHandler)
        
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
    
    @IBAction private func addNewKit(_ sender: UIButton) {
        do {
            try viewModel.createNewKit()
            presentBasicAlert(title: "Новый набор успешно создан!", message: "Удалить набор можно долгим нажатием", actions: [.okAction]) { _ in
                self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
            }
        }
        catch let error {
            switch error as! KitCreationError {
            case .noQuestions:
                presentBasicAlert(title: "В наборе должен быть хотя бы один вопрос", message: nil, actions: [.okAction], completionHandler: nil)
            case .noKitName:
                presentBasicAlert(title: "Пожалуйста, введите название набора слов", message: nil, actions: [.okAction], completionHandler: nil)
            case .noStudyStage:
                presentBasicAlert(title: "Пожалуйста, выберите стадию обучения, в которую нужно добавить набор", message: nil, actions: [.okAction], completionHandler: nil)
            case .nameAlreadyExists:
                presentBasicAlert(title: "В выбранной стадии обучения уже существует набор с таким названием", message: "Выберите другое название", actions: [.okAction]) { _ in
                    self.nameKitButtonIsPressed(nil)
                }
            }
        }
    }
    
    @IBAction private func cancelButtonIsPressed(_ sender: UIButton) {
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func presentNoInternetConnectionAlert() {
        DispatchQueue.main.async {
            self.presentBasicAlert(title: "Нет соединения с интернетом", message: "Пожалуйста, проверьте ваше подключение и попробуйте ещё раз", actions: [.okAction], completionHandler: nil)
            
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.noInternetImage.isHidden = false
            self.noInternetLabel.isHidden = false
        }
    }
}
