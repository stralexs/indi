//
//  TrainingModeViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import RxSwift
import RxCocoa

final class TrainingModeViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet var tableView: UITableView!
    @IBOutlet var slider: UISlider!
    @IBOutlet var countOfQuestionsLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var sliderBackgroundView: UIView!
    
    var viewModel: TrainingModeViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    // MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tuneUI()
        addNotificationCenterObserver()
        addLongGesture()
        setupTableView()
        setupSlider()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Rx setup
    private func setupTableView() {
        tableView.rx.itemSelected
            .subscribe(onNext: { _ in
                guard let indexPaths = self.tableView.indexPathsForSelectedRows else { return }
                self.viewModel.sliderMaximumValue(for: indexPaths)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeselected
            .subscribe(onNext: { _ in
                guard let indexPaths = self.tableView.indexPathsForSelectedRows else { return }
                self.viewModel.sliderMaximumValue(for: indexPaths)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupSlider() {
        viewModel.sliderMaximumValue
            .bind(to: slider.rx.maximumValue)
            .disposed(by: disposeBag)
        
        let sliderValueObservable = slider.rx.value.asObservable()
        
        sliderValueObservable
            .map { "\(Int($0))" }
            .bind(to: countOfQuestionsLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func tuneUI() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .indiMainBlue
        
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.shadowColor = UIColor.white
        standardAppearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = standardAppearance
                        
        sliderBackgroundView.layer.borderWidth = 5
        sliderBackgroundView.layer.borderColor = UIColor.indiMainYellow.cgColor
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 30
        tableView.sectionHeaderTopPadding = 0
        tableView.allowsMultipleSelection = true
        tableView.layer.borderWidth = 5
        tableView.layer.borderColor = UIColor.indiMainYellow.cgColor
    }
    
    private func addNotificationCenterObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewData), name: Notification.Name(rawValue: String.reloadTableView), object: nil)
    }
    
    @objc private func reloadTableViewData() {
        self.tableView.reloadData() // скорее всего можно будет убрать, когда добавится реактивное добавление таблицы
    }
    
    private func addLongGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGestureAction(_:)))
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func longGestureAction(_ gesture: UITapGestureRecognizer) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        let location = gesture.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: location) {
            if viewModel.isBasicKitCheck(for: indexPath, for: indexPath.section) {
                presentBasicAlert(title: "Базовые наборы слов удалять нельзя", message: nil, actions: [.okAction], completionHandler: nil)
            } else {
                let alert = UIAlertController(title: "Вы действительно хотите удалить этот набор слов?", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .destructive) { [weak self] _ in
                    self?.viewModel.deleteUserKit(for: indexPath, for: indexPath.section)
                    self?.tableView.reloadData()
                }
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction private func startButtonIsPressed(_ sender: UIButton) {
        if tableView.indexPathsForSelectedRows == nil {
            presentBasicAlert(title: "Пожалуйста, выберите хотя бы один набор слов", message: nil, actions: [.okAction], completionHandler: nil)
        }
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let trainingTestVC = sb.instantiateViewController(withIdentifier: "TrainingTestVC") as? TrainingModeTestingViewController,
           let indexPaths = tableView.indexPathsForSelectedRows {
            trainingTestVC.viewModel = viewModel.viewModelForTrainingModeTesting()
            viewModel.userSettingsForTraining = (indexPaths, Int(slider.value))
            trainingTestVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(trainingTestVC, animated: true)
        }
    }
}

    // MARK: - TableView Data Source and Delegate
extension TrainingModeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(for: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        view.backgroundColor = UIColor.indiSaturatedPink
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 0, width: view.frame.width, height: 50))
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "GTWalsheimPro-Regular", size: 20)
        titleLabel.text = viewModel.headerInSectionName(for: section)
        view.addSubview(titleLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TrainingModeTableViewCell
        let cellViewModel = viewModel.cellViewModel(for: indexPath.section, and: indexPath)
        cell.viewModel = cellViewModel
        cell.selectionStyle = .none
        return cell
    }
}
