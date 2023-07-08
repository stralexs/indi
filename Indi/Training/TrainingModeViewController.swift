//
//  TrainingModeViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import UIKit

final class TrainingModeViewController: UIViewController {
    //MARK: - Variables
    @IBOutlet var background: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var slider: UISlider!
    @IBOutlet var countOfQuestionsLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var sliderBackgroundView: UIView!
    
    private var viewModel = TrainingModeViewModel()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tuneUI()
        addNotificationCenterObserver()
        addLongGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //MARK: - Private Methods
    private func tuneUI() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor.indiMainBlue
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.shadowColor = UIColor.white
        standardAppearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = standardAppearance
        
        background.backgroundColor = UIColor.white
        
        startButton.tintColor = UIColor.indiMainBlue
        
        sliderBackgroundView.backgroundColor = UIColor.indiMainBlue
        sliderBackgroundView.layer.cornerRadius = 30
        sliderBackgroundView.layer.borderWidth = 5
        sliderBackgroundView.layer.borderColor = UIColor.indiMainYellow.cgColor
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 30
        tableView.sectionHeaderTopPadding = 0
        tableView.allowsMultipleSelection = true
        tableView.layer.borderWidth = 5
        tableView.layer.borderColor = UIColor.indiMainYellow.cgColor
        
        slider.maximumTrackTintColor = UIColor.indiLightPink
        slider.minimumTrackTintColor = UIColor.indiSaturatedPink
        slider.minimumValue = 1
        slider.maximumValue = 10
        slider.value = slider.minimumValue
        
        countOfQuestionsLabel.text = "1"
        countOfQuestionsLabel.textColor = UIColor.white
    }
    
    private func addNotificationCenterObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewData), name: Notification.Name(rawValue: trainingModeReloadTableViewNotificationKey), object: nil)
    }
    
    @objc private func reloadTableViewData() {
        self.tableView.reloadData()
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
                let alert = UIAlertController(title: "Базовые наборы слов удалять нельзя", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default)
                alert.addAction(okAction)
                self.present(alert, animated: true)
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
    
    @IBAction private func sliderAction(_ sender: UISlider) {
        countOfQuestionsLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction private func startButtonIsPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Пожалуйста, выберите хотя бы один набор слов", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(okAction)
        if tableView.indexPathsForSelectedRows == nil {
            self.present(alert, animated: true)
        }
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let trainingTestVC = sb.instantiateViewController(withIdentifier: "TrainingTestVC") as? TrainingModeTestingViewController,
           let indexPaths = tableView.indexPathsForSelectedRows {
            viewModel.userSettingsForTraining = (indexPaths, Int(slider.value))
            trainingTestVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(trainingTestVC, animated: true)
        }
    }
}

//MARK: - TableView Data Source and Delegate
extension TrainingModeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(for: section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        slider.maximumValue = viewModel.sliderMaximumValue(for: indexPaths)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        slider.maximumValue = viewModel.sliderMaximumValue(for: indexPaths)
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
