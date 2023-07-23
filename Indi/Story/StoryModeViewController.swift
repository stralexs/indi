//
//  StoryModeViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 19.05.23.
//

import UIKit

final class StoryModeViewController: UIViewController {
    //MARK: - Variables
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var studyStageButtons: [UIButton]!
    @IBOutlet var examButtons: [UIButton]!
    @IBOutlet var finalStudyStageButtons: [UIButton]!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userAvatarImage: UIImageView!
    @IBOutlet var becomeIndigenousLabel: UILabel!
    @IBOutlet var gameCompletionLabel: UILabel!
    @IBOutlet var userInfoBackground: UIView!
    
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
    
    private var viewModel = StoryModeViewModel()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        
        backgroundView.backgroundColor = UIColor.indiMainBlue
        userInfoBackground.backgroundColor = UIColor.indiLightPink
        userInfoBackground.layer.cornerRadius = 20
        studyStageButtons.forEach { button in
            button.layer.cornerRadius = 20
            button.layer.borderWidth = 5
            button.layer.borderColor = UIColor.white.cgColor
            button.titleLabel?.textAlignment = .center
        }
        examButtons.forEach { button in
            button.layer.cornerRadius = 20
            button.tintColor = .white
            button.backgroundColor = UIColor.indiSaturatedPink
            button.titleLabel?.textAlignment = .center
            button.setTitle(viewModel.examName(for: button.tag), for: .normal)
        }
        finalStudyStageButtons.forEach { button in
            button.layer.cornerRadius = 20
            button.layer.borderWidth = 5
            button.layer.borderColor = UIColor.white.cgColor
            button.titleLabel?.textAlignment = .center
            button.tintColor = UIColor.indiLightPink
        }
        finalStudyStageButtons[0].titleLabel?.numberOfLines = 2
        finalStudyStageButtons[1].titleLabel?.numberOfLines = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationItem.backBarButtonItem?.tintColor = UIColor.indiMainYellow
        
        userAvatarImage.image = UIImage(named: viewModel.userAvatar)
        userNameLabel.text = viewModel.userName
        userNameLabel.adjustsFontSizeToFitWidth = true
        
        examButtons.forEach { button in
            button.restorationIdentifier = viewModel.setExamButtonCompletion(for: button.tag)
            if viewModel.setExamButtonAccess(for: button.tag) {
                button.alpha = 1
                button.restorationIdentifier = viewModel.setExamButtonCompletion(for: button.tag)
            } else {
                button.alpha = 0.5
            }
        }
                
        studyStageButtons.forEach { button in
            if viewModel.studyStageAccessControl(for: button.tag) {
                button.alpha = 1
            } else {
                button.alpha = 0.5
            }
        }
        
        finalStudyStageButtons.forEach { button in
            button.restorationIdentifier = viewModel.setFinalStudyStageButtonSelection(for: button.tag)
            if viewModel.setFinalStudyStageButtonSelection(for: button.tag) {
                if viewModel.studyStageAccessControl(for: button.tag) {
                    button.backgroundColor = UIColor.indiLightPink
                    button.tintColor = .black
                    button.alpha = 1
                } else {
                    button.alpha = 0.5
                    button.backgroundColor = .clear
                    button.tintColor = UIColor.indiLightPink
                }
            } else {
                button.backgroundColor = .clear
                button.tintColor = UIColor.indiLightPink
            }
        }
        
        if viewModel.isFinalExamCompleted {
            becomeIndigenousLabel.isHidden = true
            gameCompletionLabel.isHidden = false
        } else {
            becomeIndigenousLabel.isHidden = false
            gameCompletionLabel.isHidden = true
        }
        
        tuneLinesUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - Tuninig UI of Lines
    private func tuneLinesUI() {
        if examButtons[0].alpha == 0.5 {
            newbornToExamLine.alpha = 0.5
        } else {
            newbornToExamLine.alpha = 1
        }
        if viewModel.studyStageAccessControl(for: 1) {
            newbornExamToPreschoolLine.alpha = 1
        } else {
            newbornExamToPreschoolLine.alpha = 0.5
        }
        
        if examButtons[1].alpha == 0.5 {
            preschoolToExamLine.alpha = 0.5
        } else {
            preschoolToExamLine.alpha = 1
        }
        if viewModel.studyStageAccessControl(for: 2) {
            preschoolExamToEarlySchoolLine.alpha = 1
        } else {
            preschoolExamToEarlySchoolLine.alpha = 0.5
        }
        
        if examButtons[2].alpha == 0.5 {
            earlySchoolToExamLine.alpha = 0.5
        } else {
            earlySchoolToExamLine.alpha = 1
        }
        if viewModel.studyStageAccessControl(for: 3) && viewModel.studyStageAccessControl(for: 4) {
            earlySchoolExamToHighAndLifeLine.alpha = 1
        } else {
            earlySchoolExamToHighAndLifeLine.alpha = 0.5
        }
        
        if examButtons[3].alpha == 0.5 {
            highAndLifeToExamLine.alpha = 0.5
        } else {
            highAndLifeToExamLine.alpha = 1
        }
        if viewModel.studyStageAccessControl(for: 5) {
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
    
    //MARK: - Casual Tests and Exams
    @IBAction private func studyStageButtonIsPressed(_ sender: UIButton) {
        if sender.alpha == 0.5 {
            let alert = UIAlertController(title: "Доступ закрыт!", message: "Чтобы открыть доступ к данной стадии обучения, вы должны пройти экзамен предыдущего уровня не менее чем на 50%", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        } else {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            if let kitSelectionVC = sb.instantiateViewController(withIdentifier: "KitSelectionVC") as? StoryModeKitSelectionViewController {
                NotificationCenter.default.post(name: Notification.Name(rawValue: chosenStudyStageNotificationKey), object: sender.tag)
                kitSelectionVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(kitSelectionVC, animated: true)
            }
        }
    }
    
    @IBAction private func examButtonIsPressed(_ sender: UIButton) {
        if sender.alpha == 0.5 {
            let alert = UIAlertController(title: "Доступ закрыт!", message: "Чтобы открыть доступ к экзамену, вы должны выполнить все тесты соответствующей стадии обучения более чем на 70%", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        } else {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            if let examVC = sb.instantiateViewController(withIdentifier: "ExamVC") as? StoryModeExamViewController {
                NotificationCenter.default.post(name: Notification.Name(rawValue: chosenExamNotificationKey), object: sender.tag)
                examVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(examVC, animated: true)
            }
        }
    }
    
    //MARK: - Final Tests with Variability
    @IBAction private func finalStudyStageButtonIsPressed(_ sender: UIButton) {
        if sender.alpha == 0.5 {
            let alert = UIAlertController(title: "Доступ закрыт!", message: "Чтобы открыть доступ к данной стадии обучения, вы должны пройти экзамен предыдущего уровня не менее чем на 50%", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
            
        } else if sender.backgroundColor == UIColor.indiLightPink {
            let alert = UIAlertController(title: "Пора выбирать!", message: "На этом этапе вы можете выбирать, что хотите учить. Открыть эту стадию обучения? (Вопросы из этой стадии появятся на финальном экзамене)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .cancel) { _ in
                sender.restorationIdentifier = self.viewModel.saveSelectedStage(for: sender.tag)
                let sb = UIStoryboard(name: "Main", bundle: nil)
                if let kitSelectionVC = sb.instantiateViewController(withIdentifier: "KitSelectionVC") as? StoryModeKitSelectionViewController {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: chosenStudyStageNotificationKey), object: sender.tag)
                    kitSelectionVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(kitSelectionVC, animated: true)
                }
            }
            let cancelAction = UIAlertAction(title: "Отмена", style: .default)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
            
        } else {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            if let kitSelectionVC = sb.instantiateViewController(withIdentifier: "KitSelectionVC") as? StoryModeKitSelectionViewController {
                NotificationCenter.default.post(name: Notification.Name(rawValue: chosenStudyStageNotificationKey), object: sender.tag)
                kitSelectionVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(kitSelectionVC, animated: true)
            }
        }
    }
    
    //MARK: - Settings and Statistics
    @IBAction private func settingsButtonIsPressed(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let settingsVC = sb.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsAndStatisticsViewController {
            settingsVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(settingsVC, animated: true)
        }
    }
}
