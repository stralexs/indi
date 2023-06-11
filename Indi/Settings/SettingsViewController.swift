//
//  SettingsViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet var settingsBackground: UIView!
    
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
    
    @IBOutlet var resetAchievementsBackground: UIView!
    @IBOutlet var resetAchievementsSwitch: UISwitch!
    
    @IBOutlet var applyChangesButton: UIButton!
    
    private let settingsModel = SettingsModel()
    private lazy var isUserClickedToChangeAvatar: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tuneUI()
    }
    
    private func tuneUI() {
        backgroundView.backgroundColor = UIColor(red: 54 / 255, green: 63 / 255, blue: 242 / 255, alpha: 1)
        settingsBackground.backgroundColor = UIColor(red: 1, green: 102 / 255, blue: 102 / 255, alpha: 1)
        settingsBackground.layer.cornerRadius = 30
        
        applyChangesButton.backgroundColor = UIColor(red: 1, green: 200 / 255, blue: 199 / 255, alpha: 1)
        applyChangesButton.layer.cornerRadius = 10
        applyChangesButton.tintColor = UIColor(red: 54 / 255, green: 63 / 255, blue: 242 / 255, alpha: 1)
        
        resetAchievementsBackground.backgroundColor = UIColor(red: 1, green: 200 / 255, blue: 199 / 255, alpha: 1)
        resetAchievementsBackground.layer.cornerRadius = 10
        
        avatarBackground.clipsToBounds = true
        leftAvatarImage.image = UIImage(named: "Woman_emoji")
        middleAvatarImage.image = UIImage(named: "Cat_emoji")
        rightAvatarImage.image = UIImage(named: "Dog_emoji")
        
        nameTextField.text = UserData.shared.getUserName()
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
            let alertController = UIAlertController(title: "Данное действие удалит ВСЕ ваши достижения", message: "После нажатия кнопки 'Применить изменения' данное действие отменить нельзя", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Отмена", style: .default) { _ in
                sender.isOn = false
            }
            let applyAction = UIAlertAction(title: "Ок", style: .destructive)
            
            alertController.addAction(cancelAction)
            alertController.addAction(applyAction)
            
            self.present(alertController, animated: true)
        }
    }
    
    @IBAction func applyChangesButtonIsPressed(_ sender: UIButton) {
        let emptyNameAlert = UIAlertController(title: "Пожалуйста, введите имя", message: nil, preferredStyle: .alert)
        let tooLongNameAlert = UIAlertController(title: "Имя не может быть длиннее 15 символов", message: nil, preferredStyle: .alert)
        let onlySpacesInNameAlert = UIAlertController(title: "Имя не может содержать только пробелы", message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ок", style: .default)
        emptyNameAlert.addAction(okAction)
        tooLongNameAlert.addAction(okAction)
        onlySpacesInNameAlert.addAction(okAction)
        
        let nameWithoutSpaces = settingsModel.removingSpaces(for: nameTextField.text ?? "")
        
        if nameTextField.text == Optional("") {
            self.present(emptyNameAlert, animated: true)
        } else if nameTextField.text!.count > 15 {
            self.present(tooLongNameAlert, animated: true)
        } else if nameWithoutSpaces == "" {
            self.present(onlySpacesInNameAlert, animated: true)
        } else {
            UserData.shared.saveUserName(for: nameWithoutSpaces)
        }
        
        if resetAchievementsSwitch.isOn {
            UserData.shared.resetAchievements()
        }
        
        let middleImageName = middleAvatarImage.image?.imageAsset?.value(forKey: "assetName") as! String
        let currentUserAvatar = UserData.shared.getUserAvatar()
        if isUserClickedToChangeAvatar && middleImageName != currentUserAvatar {
            UserData.shared.saveUserAvatar(for: middleImageName)
        }
        
        let alertController = UIAlertController(title: "Изменения успешно сохранены!", message: nil, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Ок", style: .default) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        alertController.addAction(okayAction)
        
        self.present(alertController, animated: true)
    }
}
