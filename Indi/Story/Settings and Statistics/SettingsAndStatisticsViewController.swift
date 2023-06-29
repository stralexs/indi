//
//  SettingsAndStatisticsViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import UIKit

class SettingsAndStatisticsViewController: UIViewController {
    @IBOutlet var nameTextField: UITextField!
    
    @IBOutlet var leftAvatarButton: UIButton!
    @IBOutlet var rightAvatarButton: UIButton!
    @IBOutlet var avatarBackground: UIView!
    @IBOutlet var leftAvatarImage: UIImageView!
    @IBOutlet var rightAvatarImage: UIImageView!
    @IBOutlet var middleAvatarImage: UIImageView!
    @IBOutlet var leftAvatarImageLeading: NSLayoutConstraint!
    @IBOutlet var leftAvatarImageTrailing: NSLayoutConstraint!
    @IBOutlet var rightAvatarImageLeading: NSLayoutConstraint!
    @IBOutlet var middleAvatarImageLeading: NSLayoutConstraint!
    @IBOutlet var middleAvatarImageTrailing: NSLayoutConstraint!
    
    @IBOutlet var settingsBackground: UIView!
    @IBOutlet var statisticsBackground: UIView!
    
    @IBOutlet var resetAchievementsSwitch: UISwitch!
    @IBOutlet var resetAchievementsBackground: UIView!
    @IBOutlet var statisticsPageControl: UIPageControl!
    
    private var statisticsScrollView = UIScrollView()
    
    private let settingsModel = SettingsAndStatisticsModel()
    private lazy var isUserClickedToChangeAvatar: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tuneUI()
    }
    
    private func tuneUI() {
        let buttonAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.indiMainYellow,
            .font: UIFont(name: "GTWalsheimPro-Regular", size: 19)!
        ]
        let rightBarItem = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(applyChangesButtonIsPressed))
        rightBarItem.setTitleTextAttributes(buttonAttributes, for: .normal)
        rightBarItem.setTitleTextAttributes(buttonAttributes, for: .highlighted)
        navigationItem.rightBarButtonItem = rightBarItem
        
        settingsBackground.backgroundColor = UIColor.indiMainBlue
        settingsBackground.layer.cornerRadius = 40
        
        resetAchievementsBackground.layer.cornerRadius = 40
        
        avatarBackground.clipsToBounds = true
        leftAvatarImage.image = UIImage(named: "Woman_emoji")
        middleAvatarImage.image = UIImage(named: "Cat_emoji")
        rightAvatarImage.image = UIImage(named: "Dog_emoji")
        
        nameTextField.text = UserDataManager.shared.getUserName()
        nameTextField.returnKeyType = .done
        nameTextField.delegate = self
        
        statisticsPageControl.currentPageIndicatorTintColor = UIColor.indiSaturatedPink
        statisticsPageControl.tintColor = UIColor.indiLightPink

        statisticsScrollView.backgroundColor = UIColor.clear
        statisticsScrollView.contentSize = CGSize(width: Double(UIScreen.main.bounds.width) * Double(settingsModel.getUserStatisticsCount()), height: statisticsScrollView.frame.height)
        statisticsScrollView.isPagingEnabled = true
        statisticsScrollView.showsHorizontalScrollIndicator = false
        statisticsScrollView.delegate = self
        statisticsScrollView.frame = CGRect(x: 0, y: 0, width: statisticsBackground.frame.maxX - statisticsBackground.frame.minX, height: UIScreen.main.bounds.height * 0.29)
        
        statisticsBackground.addSubview(statisticsScrollView)
        
        statisticsScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statisticsScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statisticsScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statisticsScrollView.topAnchor.constraint(equalTo: statisticsBackground.topAnchor),
            statisticsScrollView.bottomAnchor.constraint(equalTo: statisticsPageControl.topAnchor)
        ])

        createContentForScrollView(for: settingsModel.getUserStatisticsInfo(for: 0), and: 0)
        createContentForScrollView(for: settingsModel.getUserStatisticsInfo(for: 1), and: 1)
        createContentForScrollView(for: settingsModel.getUserStatisticsInfo(for: 2), and: 2)
        createContentForScrollView(for: settingsModel.getUserStatisticsInfo(for: 3), and: 3)
    }
    
    private func createContentForScrollView(for userInfo: (String, String), and position: CGFloat) {
        let statisticsDescription = UILabel()
        statisticsDescription.text = userInfo.0
        statisticsDescription.font = UIFont(name: "GTWalsheimPro-Regular", size: 20)
        statisticsDescription.textAlignment = .center
        statisticsDescription.textColor = UIColor.indiMainBlue
        
        let screenWidth = UIScreen.main.bounds.width
        statisticsDescription.frame = CGRect(x: screenWidth * position, y: 0, width: screenWidth, height: statisticsScrollView.frame.height * 0.3)
        
        let statisticsUserResult = UILabel()
        statisticsUserResult.text = userInfo.1
        statisticsUserResult.font = UIFont(name: "GTWalsheimPro-Regular", size: 85)
        statisticsUserResult.textAlignment = .center
        statisticsUserResult.textColor = UIColor.indiMainBlue
        statisticsUserResult.frame = CGRect(x: screenWidth * position, y: statisticsDescription.frame.maxY, width: screenWidth, height: statisticsScrollView.frame.height * 0.7)

        statisticsScrollView.addSubview(statisticsDescription)
        statisticsScrollView.addSubview(statisticsUserResult)
    }
    
    @IBAction func changeAvatar(_ sender: UIButton) {
        isUserClickedToChangeAvatar = true
        if sender == leftAvatarButton {
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut] , animations: { self.rightAvatarImageLeading.constant -= 130
                self.middleAvatarImageLeading.constant -= 260
                self.view.layoutIfNeeded()
            }) { [self ]_ in
                middleAvatarImage.image = settingsModel.avatarSelection(true, with: .middle)
                rightAvatarImage.image = settingsModel.avatarSelection(true, with: .right)
                leftAvatarImage.image = settingsModel.avatarSelection(true, with: .left)
                middleAvatarImageLeading.constant += 260
                rightAvatarImageLeading.constant += 130
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut] , animations: {
                self.middleAvatarImageTrailing.constant -= 260
                self.leftAvatarImageTrailing.constant -= 260
                self.view.layoutIfNeeded()
            }) { [self] _  in
                middleAvatarImage.image = settingsModel.avatarSelection(false, with: .middle)
                leftAvatarImage.image = settingsModel.avatarSelection(false, with: .left)
                rightAvatarImage.image = settingsModel.avatarSelection(false, with: .right)
                middleAvatarImageTrailing.constant += 260
                leftAvatarImageTrailing.constant += 260
            }
        }
    }
    
    @IBAction func resetAchievementsSwitchIsToggled(_ sender: UISwitch) {
        if sender.isOn {
            let alertController = UIAlertController(title: "Данное действие удалит ВСЕ ваши достижения и прохождение", message: "После нажатия кнопки 'Готово' данное действие отменить нельзя", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Отмена", style: .default) { _ in
                sender.isOn = false
            }
            let applyAction = UIAlertAction(title: "Ок", style: .destructive)
            
            alertController.addAction(cancelAction)
            alertController.addAction(applyAction)
            
            self.present(alertController, animated: true)
        }
    }
    
    @objc private func applyChangesButtonIsPressed() {
        let emptyNameAlert = UIAlertController(title: "Пожалуйста, введите имя", message: nil, preferredStyle: .alert)
        let tooLongNameAlert = UIAlertController(title: "Имя не может быть длиннее 15 символов", message: nil, preferredStyle: .alert)
        let onlySpacesInNameAlert = UIAlertController(title: "Имя не может содержать только пробелы", message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ок", style: .default)
        emptyNameAlert.addAction(okAction)
        tooLongNameAlert.addAction(okAction)
        onlySpacesInNameAlert.addAction(okAction)
        
        let nameWithoutSpaces = settingsModel.removingSpaces(for: nameTextField.text ?? "")
        
        var countOfChanges = 0
        
        if nameTextField.text == Optional("") {
            self.present(emptyNameAlert, animated: true)
        } else if nameTextField.text!.count > 15 {
            self.present(tooLongNameAlert, animated: true)
        } else if nameWithoutSpaces == "" {
            self.present(onlySpacesInNameAlert, animated: true)
        } else if UserDataManager.shared.getUserName() != nameWithoutSpaces {
            UserDataManager.shared.saveUserName(for: nameWithoutSpaces)
            countOfChanges += 1
        }
                
        if resetAchievementsSwitch.isOn {
            UserDataManager.shared.resetAchievements()
            countOfChanges += 1
        }
        
        let middleImageName = middleAvatarImage.image?.imageAsset?.value(forKey: "assetName") as! String
        let currentUserAvatar = UserDataManager.shared.getUserAvatar()
        if isUserClickedToChangeAvatar && middleImageName != currentUserAvatar {
            UserDataManager.shared.saveUserAvatar(for: middleImageName)
            countOfChanges += 1
        }
        
        let alertController = UIAlertController(title: "Изменения успешно сохранены!", message: nil, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Ок", style: .default) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        alertController.addAction(okayAction)
        if countOfChanges != 0 {
            self.present(alertController, animated: true)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}

extension SettingsAndStatisticsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        statisticsPageControl.currentPage = Int(statisticsScrollView.contentOffset.x / UIScreen.main.bounds.width)
    }
}

extension SettingsAndStatisticsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
