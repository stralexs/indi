//
//  WorkoutModeViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import UIKit

class WorkoutModeViewController: UIViewController {
    @IBOutlet var background: UIView!
    @IBOutlet var workoutBackground: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var slider: UISlider!
    @IBOutlet var countOfQuestionsLabel: UILabel!
    @IBOutlet var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tuneUI()
    }
    
    private func tuneUI() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(red: 54 / 255, green: 63 / 255, blue: 242 / 255, alpha: 1)
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = UIColor(red: 54 / 255, green: 63 / 255, blue: 242 / 255, alpha: 1)
        self.navigationController?.navigationBar.standardAppearance = standardAppearance
        
        background.backgroundColor = UIColor(red: 54 / 255, green: 63 / 255, blue: 242 / 255, alpha: 1)
        workoutBackground.backgroundColor = UIColor(red: 1, green: 102 / 255, blue: 102 / 255, alpha: 1)
        workoutBackground.layer.cornerRadius = 30
        
        startButton.backgroundColor = UIColor(red: 1, green: 200 / 255, blue: 199 / 255, alpha: 1)
        startButton.layer.cornerRadius = 10
        startButton.tintColor = UIColor(red: 54 / 255, green: 63 / 255, blue: 242 / 255, alpha: 1)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 30
        tableView.sectionHeaderTopPadding = 0
        tableView.allowsMultipleSelection = true
        
        slider.maximumTrackTintColor = UIColor(red: 1, green: 102 / 255, blue: 102 / 255, alpha: 1)
        slider.minimumTrackTintColor = .white
        slider.minimumValue = 1
        slider.maximumValue = 10
        slider.value = slider.minimumValue
        
        countOfQuestionsLabel.text = "0"
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGestureAction(_:)))
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func longGestureAction(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: location) {
            if KitsLibrary.shared.isBasicKitCheck(for: indexPath, for: indexPath.section) {
                let alert = UIAlertController(title: "Базовые наборы слов удалять нельзя", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .default)
                alert.addAction(okAction)
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "Вы действительно хотите удалить этот набор слов?", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ок", style: .destructive) { _ in
                    KitsLibrary.shared.deleteUserKit(for: indexPath, for: indexPath.section)
                    self.tableView.reloadData()
                }
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func sliderAction(_ sender: UISlider) {
        countOfQuestionsLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func startButtonIsPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Пожалуйста, выберите хотя бы один набор слов", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(okAction)
        if tableView.indexPathsForSelectedRows == nil {
            self.present(alert, animated: true)
        }
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let workoutTestVC = sb.instantiateViewController(withIdentifier: "WorkoutTestVC") as? WorkoutTestingViewController,
           let indexPaths = tableView.indexPathsForSelectedRows {
            NotificationCenter.default.post(name: Notification.Name(rawValue: chosenWorkoutNotificationKey), object: (indexPaths, Int(slider.value)))
            self.navigationController?.pushViewController(workoutTestVC, animated: true)
        }
    }
}

extension WorkoutModeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return StudyStage.countOfStudyStages()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return KitsLibrary.shared.countOfKits(for: section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var value: Int = 0
        
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        for index in indexPaths {
            value += KitsLibrary.shared.getKitForTesting(for: index[0], and: index[1]).count
        }
        
        slider.maximumValue = Float(value)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        var value: Int = 0
        
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        for index in indexPaths {
            value += KitsLibrary.shared.getKitForTesting(for: index[0], and: index[1]).count
        }
        
        slider.maximumValue = Float(value)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        view.backgroundColor = UIColor(red: 1, green: 102 / 255, blue: 102 / 255, alpha: 1)
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 0, width: view.frame.width, height: 50))
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "GTWalsheimPro", size: 20)
        titleLabel.text = StudyStage.getStudyStageName(studyStage: section)
        view.addSubview(titleLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WorkoutTableViewCell
        cell.label.text = KitsLibrary.shared.getKitName(for: indexPath.section, with: indexPath)
        cell.selectionStyle = .none
        
        return cell
    }
}
