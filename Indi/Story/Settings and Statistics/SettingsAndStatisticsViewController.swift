//
//  SettingsAndStatisticsViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import UIKit

final class SettingsAndStatisticsViewController: UIViewController {
    //MARK: - Variables
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
    var viewModel: SettingsAndStatisticsViewModelProtocol!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
        tuneUI()
        createStatisticsPageControlAndScrollView()
    }
    
    //MARK: - Private Methods
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
    }
    
    private func createStatisticsPageControlAndScrollView() {
        statisticsPageControl.currentPageIndicatorTintColor = UIColor.indiSaturatedPink
        statisticsPageControl.tintColor = UIColor.indiLightPink

        statisticsScrollView.backgroundColor = UIColor.clear
        statisticsScrollView.contentSize = CGSize(width: Double(UIScreen.main.bounds.width) * Double(viewModel.userStatisticsCount), height: statisticsScrollView.frame.height)
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

        createContentForScrollView(for: viewModel.getUserStatisticsInfo(for: 0), and: 0)
        createContentForScrollView(for: viewModel.getUserStatisticsInfo(for: 1), and: 1)
        createContentForScrollView(for: viewModel.getUserStatisticsInfo(for: 2), and: 2)
        createContentForScrollView(for: viewModel.getUserStatisticsInfo(for: 3), and: 3)
        
        func createContentForScrollView(for userInfo: (String, String), and position: CGFloat) {
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
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction private func changeAvatar(_ sender: UIButton) {
        viewModel.isUserClickedToChangeAvatar = true
        if sender == leftAvatarButton {
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut] , animations: {
                self.rightAvatarImageLeading.constant -= 130
                self.middleAvatarImageLeading.constant -= 260
                self.view.layoutIfNeeded()
            }) { [weak self] _ in
                let images = self?.viewModel.avatarSwipe(true)
                self?.leftAvatarImage.image = images?.0
                self?.middleAvatarImage.image = images?.1
                self?.rightAvatarImage.image = images?.2
                self?.middleAvatarImageLeading.constant += 260
                self?.rightAvatarImageLeading.constant += 130
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut] , animations: {
                self.middleAvatarImageTrailing.constant -= 260
                self.leftAvatarImageTrailing.constant -= 260
                self.view.layoutIfNeeded()
            }) { [weak self] _ in
                let images = self?.viewModel.avatarSwipe(false)
                self?.leftAvatarImage.image = images?.0
                self?.middleAvatarImage.image = images?.1
                self?.rightAvatarImage.image = images?.2
                self?.middleAvatarImageTrailing.constant += 260
                self?.leftAvatarImageTrailing.constant += 260
            }
        }
    }
    
    @IBAction private func resetAchievementsSwitchIsToggled(_ sender: UISwitch) {
        if sender.isOn {
            let alertController = UIAlertController(title: "Данное действие удалит ВСЕ ваши достижения и прохождение", message: "После нажатия кнопки 'Готово' данное действие отменить нельзя", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Отмена", style: .default) { _ in
                sender.isOn = false
                self.viewModel.resetAchievements = false
            }
            let applyAction = UIAlertAction(title: "Ок", style: .destructive)
            
            alertController.addAction(cancelAction)
            alertController.addAction(applyAction)
            
            self.present(alertController, animated: true)
            viewModel.resetAchievements = true
        }
    }
    
    @objc private func applyChangesButtonIsPressed() {
        let applyChangesResult = viewModel.applyChanges(for: nameTextField.text ?? "", and: middleAvatarImage.image?.imageAsset?.value(forKey: "assetName") as! String)
        
        let emptyNameAlert = UIAlertController(title: "Пожалуйста, введите имя", message: nil, preferredStyle: .alert)
        let tooLongNameAlert = UIAlertController(title: "Имя не может быть длиннее 15 символов", message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ок", style: .default)
        emptyNameAlert.addAction(okAction)
        tooLongNameAlert.addAction(okAction)
        
        if applyChangesResult == "Empty name" {
            self.present(emptyNameAlert, animated: true)
        } else if applyChangesResult == "Too long name" {
            self.present(tooLongNameAlert, animated: true)
        }
        
        let changesAppliedAlert = UIAlertController(title: "Изменения успешно сохранены!", message: nil, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Ок", style: .default) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        changesAppliedAlert.addAction(okayAction)
        if applyChangesResult == "Changes saved" {
            self.present(changesAppliedAlert, animated: true)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}

//MARK: - ScrollView Delegate
extension SettingsAndStatisticsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        statisticsPageControl.currentPage = Int(statisticsScrollView.contentOffset.x / UIScreen.main.bounds.width)
    }
}

//MARK: - TextFieldDelegate
extension SettingsAndStatisticsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
