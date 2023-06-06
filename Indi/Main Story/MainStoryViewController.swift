//
//  MainStoryViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 19.05.23.
//

import UIKit

class MainStoryViewController: UIViewController {
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var logoImage: UIImageView!
    
    @IBOutlet var studyStageButtons: [UIButton]!
    @IBOutlet var examButtons: [UIButton]!
    @IBOutlet var finalStudyStageButtons: [UIButton]!
    
    @IBOutlet var welcomeLabel: UILabel!
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userAvatarImage: UIImageView!
    
    @IBOutlet var toolbarItemsCollection: [UIBarButtonItem]!
    
    @IBOutlet var becomeIndigenousLabel: UILabel!
    @IBOutlet var gameCompletionLabel: UILabel!
    
    @IBOutlet var newbornToExamLine: UIView!
    @IBOutlet var newbornExamToPreschoolLine: UIView!
    @IBOutlet var preschoolToExamLine: UIView!
    @IBOutlet var preschoolExamToEarlySchoolLine: UIView!
    @IBOutlet var earlySchoolToExamLine: UIView!
    @IBOutlet var earlySchoolExamToHighAndLifeLine: UIImageView!
    @IBOutlet var highAndLifeToExamLine: UIImageView!
    @IBOutlet var highAndLifeExamToVariationsLine: UIImageView!
    @IBOutlet var variationsToProgrammingLine: UIView!
    @IBOutlet var variationsToConstructionLine: UIView!
    @IBOutlet var variationsToSideJobsLine: UIView!
    @IBOutlet var variationsToFinalExamLine: UIImageView!
    
    private let mainStoryModel = MainStoryModel()
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        
        backgroundView.backgroundColor = UIColor(red: 54 / 255, green: 63 / 255, blue: 242 / 255, alpha: 1)
        logoImage.image = UIImage(named: "AppIcon_noBackground")
                
        studyStageButtons.forEach { button in
            button.layer.cornerRadius = 20
            button.layer.borderWidth = 5
            button.layer.borderColor = UIColor.white.cgColor
            button.titleLabel?.textAlignment = .center
            button.tintColor = UIColor(red: 1, green: 200 / 255, blue: 199 / 255, alpha: 1)
        }
        
        examButtons.forEach { button in
            button.layer.cornerRadius = 20
            button.tintColor = .white
            button.backgroundColor = UIColor(red: 1, green: 102 / 255, blue: 102 / 255, alpha: 1)
            button.titleLabel?.textAlignment = .center
            button.setTitle(StudyStage.getExamName(studyStage: button.tag), for: .normal)
        }
        
        finalStudyStageButtons.forEach { button in
            button.layer.cornerRadius = 20
            button.layer.borderWidth = 5
            button.layer.borderColor = UIColor.white.cgColor
            button.titleLabel?.textAlignment = .center
            button.tintColor = UIColor(red: 1, green: 200 / 255, blue: 199 / 255, alpha: 1)
        }
        
        finalStudyStageButtons[0].titleLabel?.numberOfLines = 2
        finalStudyStageButtons[1].titleLabel?.numberOfLines = 2
        
        toolbarItemsCollection.forEach { item in
            item.width = backgroundView.frame.width / 5
        }
        
        welcomeLabel.layer.borderWidth = 2
        welcomeLabel.layer.cornerRadius = 5
        welcomeLabel.layer.borderColor = UIColor(red: 1, green: 102 / 255, blue: 102 / 255, alpha: 1).cgColor
        
        userNameLabel.text = UserData.shared.getUserName()
    }
    
    //MARK: - viewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        userAvatarImage.image = UIImage(named: UserData.shared.getUserAvatar())
        userNameLabel.text = UserData.shared.getUserName()
        userNameLabel.adjustsFontSizeToFitWidth = true
        
        examButtons.forEach { button in
            button.restorationIdentifier = UserData.shared.getExamCompletion(for: button.tag)
            if button.restorationIdentifier == "Uncompleted" {
                if mainStoryModel.examAccessControl(for: button.tag) {
                    button.alpha = 1
                    if UserData.shared.getUserResult(for: StudyStage.getExamName(studyStage: button.tag)) >= 50 {
                        UserData.shared.saveExamCompletion(for: button.tag)
                    }
                    button.restorationIdentifier = UserData.shared.getExamCompletion(for: button.tag)
                } else {
                    button.alpha = 0.5
                }
            }
        }
                
        studyStageButtons.forEach { button in
            if mainStoryModel.studyStageAccessControl(for: button.tag) {
                button.alpha = 1
            } else {
                button.alpha = 0.5
            }
        }
        
        finalStudyStageButtons.forEach { button in
            button.restorationIdentifier = UserData.shared.getStageSelection(for: button.tag)
            if button.restorationIdentifier == "Unselected" {
                if mainStoryModel.studyStageAccessControl(for: button.tag) {
                    button.backgroundColor = UIColor(red: 1, green: 200 / 255, blue: 199 / 255, alpha: 1)
                    button.tintColor = .black
                    button.alpha = 1
                } else {
                    button.alpha = 0.5
                    button.backgroundColor = .clear
                    button.tintColor = UIColor(red: 1, green: 200 / 255, blue: 199 / 255, alpha: 1)
                }
            } else {
                button.backgroundColor = .clear
                button.tintColor = UIColor(red: 1, green: 200 / 255, blue: 199 / 255, alpha: 1)
            }
        }
        
        if UserData.shared.getUserResult(for: "Final exam") >= 50 {
            becomeIndigenousLabel.isHidden = true
            gameCompletionLabel.isHidden = false
        } else {
            becomeIndigenousLabel.isHidden = false
            gameCompletionLabel.isHidden = true
        }
        
        tuneLinesUI()
    }
    
    //MARK: - viewWillDisappear
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - Tuninig UI of lines
    
    func tuneLinesUI() {
        if examButtons[0].alpha == 0.5 {
            newbornToExamLine.alpha = 0.5
        } else {
            newbornToExamLine.alpha = 1
        }
        if mainStoryModel.studyStageAccessControl(for: 1) {
            newbornExamToPreschoolLine.alpha = 1
        } else {
            newbornExamToPreschoolLine.alpha = 0.5
        }
        
        if examButtons[1].alpha == 0.5 {
            preschoolToExamLine.alpha = 0.5
        } else {
            preschoolToExamLine.alpha = 1
        }
        if mainStoryModel.studyStageAccessControl(for: 2) {
            preschoolExamToEarlySchoolLine.alpha = 1
        } else {
            preschoolExamToEarlySchoolLine.alpha = 0.5
        }
        
        if examButtons[2].alpha == 0.5 {
            earlySchoolToExamLine.alpha = 0.5
        } else {
            earlySchoolToExamLine.alpha = 1
        }
        if mainStoryModel.studyStageAccessControl(for: 3) && mainStoryModel.studyStageAccessControl(for: 4) {
            earlySchoolExamToHighAndLifeLine.alpha = 1
        } else {
            earlySchoolExamToHighAndLifeLine.alpha = 0.5
        }
        
        if examButtons[3].alpha == 0.5 {
            highAndLifeToExamLine.alpha = 0.5
        } else {
            highAndLifeToExamLine.alpha = 1
        }
        if mainStoryModel.studyStageAccessControl(for: 5) {
            highAndLifeExamToVariationsLine.alpha = 1
        } else {
            highAndLifeExamToVariationsLine.alpha = 0.5
        }
        
        if finalStudyStageButtons[0].restorationIdentifier == "Unselected" {
            variationsToProgrammingLine.alpha = 0.5
        } else {
            variationsToProgrammingLine.alpha = 1
        }
        if finalStudyStageButtons[1].restorationIdentifier == "Unselected" {
            variationsToConstructionLine.alpha = 0.5
        } else {
            variationsToConstructionLine.alpha = 1
        }
        if finalStudyStageButtons[2].restorationIdentifier == "Unselected" {
            variationsToSideJobsLine.alpha = 0.5
        } else {
            variationsToSideJobsLine.alpha = 1
        }
        
        if examButtons[4].alpha == 0.5 {
            variationsToFinalExamLine.alpha = 0.5
        } else {
            variationsToFinalExamLine.alpha = 1
        }
    }
    
    //MARK: - Casual tests and exams IBActions
    
    @IBAction func studyStageButtonIsPressed(_ sender: UIButton) {
        if sender.alpha == 0.5 {
            let alert = UIAlertController(title: "Доступ закрыт!", message: "Чтобы открыть доступ к данной стадии обучения, вы должны пройти экзамен предыдущего уровня не менее чем на 50%", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        } else {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            if let kitSelectionVC = sb.instantiateViewController(withIdentifier: "KitSelectionVC") as? KitSelectionViewController {
                kitSelectionVC.studyStageRawValue = sender.tag
                self.navigationController?.pushViewController(kitSelectionVC, animated: true)
            }
        }
    }
    
    @IBAction func examButtonIsPressed(_ sender: UIButton) {
        if sender.alpha == 0.5 {
            let alert = UIAlertController(title: "Доступ закрыт!", message: "Чтобы открыть доступ к экзамену, вы должны выполнить все тесты соответствующей стадии обучения более чем на 70%", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        } else {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            if let examVC = sb.instantiateViewController(withIdentifier: "ExamVC") as? ExamViewController {
                NotificationCenter.default.post(name: Notification.Name(rawValue: chosenExamNotificationKey), object: sender.tag)
                self.navigationController?.pushViewController(examVC, animated: true)
            }
        }
    }
    
    //MARK: - Final tests and exams with variability IBActions
    
    @IBAction func finalStudyStageButtonIsPressed(_ sender: UIButton) {
        if sender.alpha == 0.5 {
            let alert = UIAlertController(title: "Доступ закрыт!", message: "Чтобы открыть доступ к данной стадии обучения, вы должны пройти экзамен предыдущего уровня не менее чем на 50%", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        } else if sender.backgroundColor == UIColor(red: 1, green: 200 / 255, blue: 199 / 255, alpha: 1) {
            let alert = UIAlertController(title: "Пора выбирать!", message: "На этом этапе вы можете выбирать, что хотите учить. Открыть эту стадию обучения? (Вопросы из этой стадии появятся на финальном экзамене)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .cancel) { _ in
                UserData.shared.saveStageSelection(for: sender.tag)
                sender.restorationIdentifier = UserData.shared.getStageSelection(for: sender.tag)
                UserData.shared.saveSelectedStages(for: sender.tag)
                let sb = UIStoryboard(name: "Main", bundle: nil)
                if let kitSelectionVC = sb.instantiateViewController(withIdentifier: "KitSelectionVC") as? KitSelectionViewController {
                    kitSelectionVC.studyStageRawValue = sender.tag
                    self.navigationController?.pushViewController(kitSelectionVC, animated: true)
                }
            }
            let cancelAction = UIAlertAction(title: "Отмена", style: .default)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        } else {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            if let kitSelectionVC = sb.instantiateViewController(withIdentifier: "KitSelectionVC") as? KitSelectionViewController {
                kitSelectionVC.studyStageRawValue = sender.tag
                self.navigationController?.pushViewController(kitSelectionVC, animated: true)
            }
        }
    }
    
    //MARK: - Bar buttons IBActions
    
    @IBAction func barButtonItemIsPressed(_ sender: UIBarButtonItem) {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        switch sender.tag {
        case 0:
            if let settingsVC = sb.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsViewController {
                self.navigationController?.pushViewController(settingsVC, animated: true)
            }
        case 1:
            if let workoutVC = sb.instantiateViewController(withIdentifier: "WorkoutVC") as? WorkoutModeViewController {
                self.navigationController?.pushViewController(workoutVC, animated: true)
            }
        case 2:
            if let newKitVC = sb.instantiateViewController(withIdentifier: "NewKitVC") as? NewKitViewController {
                self.navigationController?.pushViewController(newKitVC, animated: true)
            }
        case 3:
            if let statisticsVC = sb.instantiateViewController(withIdentifier: "StatisticsVC") as? StatisticsViewController {
                self.navigationController?.pushViewController(statisticsVC, animated: true)
            }
        default:
            if let networkingVC = sb.instantiateViewController(withIdentifier: "NetworkingVC") as? NetworkingViewController {
                self.navigationController?.pushViewController(networkingVC, animated: true)
            }
        }
    }
}
