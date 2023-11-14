//
//  TrainingModeViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import RxSwift
import RxCocoa
import RxDataSources

final class TrainingModeViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet var tableView: UITableView!
    @IBOutlet var slider: UISlider!
    @IBOutlet var countOfQuestionsLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var sliderBackgroundView: UIView!
    
    var viewModel: (TrainingModeViewModelData & TrainingModeViewModelLogic)!
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, String>>!
    
    // MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tuneUI()
        addNotificationCenterObserver()
        addLongGesture()
        setupTableView()
        setupSlider()
        setupStartButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTableViewData()
    }
}

    // MARK: - Rx setup
extension TrainingModeViewController {
    private func setupTableView() {
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, String>>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: TrainingModeTableViewCell.identifier, for: indexPath) as! TrainingModeTableViewCell
                cell.configure(with: self.viewModel.cellViewModel(with: item))
                cell.selectionStyle = .none
                return cell
            }
        )
        
        viewModel.sectionsRelay
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { _ in
                guard let indexPaths = self.tableView.indexPathsForSelectedRows else { return }
                self.viewModel.setSliderMaximumValue(for: indexPaths)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeselected
            .subscribe(onNext: { _ in
                guard let indexPaths = self.tableView.indexPathsForSelectedRows else { return }
                self.viewModel.setSliderMaximumValue(for: indexPaths)
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
    
    private func setupStartButton() {
        startButton.rx.tap.bind(onNext: {
            if self.tableView.indexPathsForSelectedRows == nil {
                self.presentBasicAlert(title: "Пожалуйста, выберите хотя бы один набор слов", message: nil, actions: [.okAction], completionHandler: nil)
            }
            
            let sb = UIStoryboard(name: "Main", bundle: nil)
            if let trainingTestVC = sb.instantiateViewController(withIdentifier: "TrainingTestVC") as? TrainingModeTestingViewController,
               let indexPaths = self.tableView.indexPathsForSelectedRows {
                trainingTestVC.viewModel = self.viewModel.viewModelForTrainingModeTesting(kits: indexPaths, questions: Int(self.slider.value))
                trainingTestVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(trainingTestVC, animated: true)
            }
        })
        .disposed(by: disposeBag)
    }
    
    private func addLongGesture() {
        let longPressGesture = UILongPressGestureRecognizer()
        tableView.addGestureRecognizer(longPressGesture)
        
        longPressGesture.rx.event.bind(onNext: { gesture in
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            let location = gesture.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: location) {
                if self.viewModel.isBasicKitCheck(for: indexPath, for: indexPath.section) {
                    self.presentBasicAlert(title: "Базовые наборы слов удалять нельзя", message: nil, actions: [.okAction], completionHandler: nil)
                } else {
                    let alert = UIAlertController(title: "Вы действительно хотите удалить этот набор слов?", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ок", style: .destructive) { _ in
                        self.viewModel.deleteUserKit(for: indexPath, for: indexPath.section)
                        self.viewModel.fetchKitsNamesAndSections()
                    }
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                    alert.addAction(okAction)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true)
                }
            }
        })
        .disposed(by: disposeBag)
    }
}

    // MARK: - Functionality
extension TrainingModeViewController {
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
        tableView.sectionHeaderTopPadding = 0
        tableView.layer.borderWidth = 5
        tableView.layer.borderColor = UIColor.indiMainYellow.cgColor
    }
    
    private func addNotificationCenterObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewData), name: Notification.Name(rawValue: String.reloadTableView), object: nil)
    }
    
    @objc private func reloadTableViewData() {
        viewModel.fetchKitsNamesAndSections()
    }
}

    // MARK: - UITableViewDelegate
extension TrainingModeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        view.backgroundColor = UIColor.indiSaturatedPink
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 0, width: view.frame.width, height: 50))
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "GTWalsheimPro-Regular", size: 20)
        titleLabel.text = dataSource[section].model
        view.addSubview(titleLabel)
        return view
    }
}
