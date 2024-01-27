//
//  SettingsAndStatisticsViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import RxSwift
import RxCocoa

fileprivate extension CGFloat {
    static let avatarsBackgroundWidth: CGFloat = 130
    static let avatarsBackroundDoubleWidth: CGFloat = 260
}

final class SettingsAndStatisticsViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var leftAvatarImage: UIImageView!
    @IBOutlet var rightAvatarImage: UIImageView!
    @IBOutlet var middleAvatarImage: UIImageView!
    @IBOutlet var leftAvatarImageLeading: NSLayoutConstraint!
    @IBOutlet var leftAvatarImageTrailing: NSLayoutConstraint!
    @IBOutlet var rightAvatarImageLeading: NSLayoutConstraint!
    @IBOutlet var middleAvatarImageLeading: NSLayoutConstraint!
    @IBOutlet var middleAvatarImageTrailing: NSLayoutConstraint!
    @IBOutlet var statisticsBackground: UIView!
    @IBOutlet var statisticsPageControl: UIPageControl!
    
    private let disposeBag = DisposeBag()
    private let statisticsScrollView = UIScrollView()
    private let avatarSwipeAnimationDuration: TimeInterval = 0.5
    var viewModel: (SettingsAndStatisticsViewModelData & SettingsAndStatisticsViewModelLogic)!
    
    //MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
        tuneUI()
        createStatisticsPageControlAndScrollView()
        setupAvatarImages()
        setupPageControl()
    }
}

    // MARK: - Rx setup
extension SettingsAndStatisticsViewController {
    func setupAvatarImages() {
        viewModel.leftAvatarImage.bind(onNext: {
            self.leftAvatarImage.image = $0
        })
        .disposed(by: disposeBag)
        
        viewModel.middleAvatarImage.bind(onNext: {
            self.middleAvatarImage.image = $0
        })
        .disposed(by: disposeBag)
        
        viewModel.rightAvatarImage.bind(onNext: {
            self.rightAvatarImage.image = $0
        })
        .disposed(by: disposeBag)
    }
    
    func setupPageControl() {
        statisticsScrollView.rx.didScroll
            .map { _ in
                Int(self.statisticsScrollView.contentOffset.x / self.statisticsScrollView.frame.width)
            }
            .bind(to: statisticsPageControl.rx.currentPage)
            .disposed(by: disposeBag)
    }
}

    // MARK: - Functionality
extension SettingsAndStatisticsViewController {
    private func tuneUI() {
        let buttonAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.indiMainYellow,
            .font: UIFont(name: "GTWalsheimPro-Regular", size: 19)!
        ]
        let rightBarItem = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(applyChangesButtonIsPressed))
        rightBarItem.setTitleTextAttributes(buttonAttributes, for: .normal)
        rightBarItem.setTitleTextAttributes(buttonAttributes, for: .highlighted)
        navigationItem.rightBarButtonItem = rightBarItem
                        
        nameTextField.text = viewModel.userName
        nameTextField.delegate = self
    }
    
    private func createStatisticsPageControlAndScrollView() {
        statisticsScrollView.backgroundColor = UIColor.clear
        statisticsScrollView.contentSize = CGSize(width: Double(UIScreen.main.bounds.width) * Double(viewModel.userStatisticsCount), height: statisticsScrollView.frame.height)
        statisticsScrollView.isPagingEnabled = true
        statisticsScrollView.showsHorizontalScrollIndicator = false
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
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction private func changeAvatar(_ sender: UIButton) {
        viewModel.isUserClickedToChangeAvatar = true
        if sender.tag == 0 {
            UIView.animate(withDuration: avatarSwipeAnimationDuration, delay: 0, options: [.curveEaseInOut] , animations: {
                self.rightAvatarImageLeading.constant -= .avatarsBackgroundWidth
                self.middleAvatarImageLeading.constant -= .avatarsBackroundDoubleWidth
                self.view.layoutIfNeeded()
            }) { _ in
                self.viewModel.avatarSwipe(true)
                self.middleAvatarImageLeading.constant += .avatarsBackroundDoubleWidth
                self.rightAvatarImageLeading.constant += .avatarsBackgroundWidth
            }
        } else {
            UIView.animate(withDuration: avatarSwipeAnimationDuration, delay: 0, options: [.curveEaseInOut] , animations: {
                self.middleAvatarImageTrailing.constant -= .avatarsBackroundDoubleWidth
                self.leftAvatarImageTrailing.constant -= .avatarsBackroundDoubleWidth
                self.view.layoutIfNeeded()
            }) { _ in
                self.viewModel.avatarSwipe(false)
                self.middleAvatarImageTrailing.constant += .avatarsBackroundDoubleWidth
                self.leftAvatarImageTrailing.constant += .avatarsBackroundDoubleWidth
            }
        }
    }
    
    @IBAction private func resetAchievementsSwitchIsToggled(_ sender: UISwitch) {
        if sender.isOn {
            let alertController = UIAlertController(title: "Данное действие удалит ВСЕ ваши достижения и прохождение", message: "После нажатия кнопки 'Готово' данное действие отменить нельзя", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Отмена", style: .default) { _ in
                sender.isOn = false
                self.viewModel.isSetResetAchievements = false
            }
            let applyAction = UIAlertAction(title: "Ок", style: .destructive)
            
            alertController.addAction(cancelAction)
            alertController.addAction(applyAction)
            
            self.present(alertController, animated: true)
            viewModel.isSetResetAchievements = true
        }
    }
    
    @objc private func applyChangesButtonIsPressed() {
        do {
            try viewModel.applyChanges(for: nameTextField.text ?? "", and: middleAvatarImage.image?.imageAsset?.value(forKey: "assetName") as! String)
            navigationController?.popToRootViewController(animated: true)
        }
        catch let error as SettingsError {
            switch error {
            case .changesOverZero:
                presentBasicAlert(title: error.errorDescription, message: nil, actions: [.okAction]) { _ in
                    self.navigationController?.popToRootViewController(animated: true)
                }
            default:
                presentBasicAlert(title: error.errorDescription, message: nil, actions: [.okAction], completionHandler: nil)
            }
        }
        catch {
            presentBasicAlert(title: "Произошла ошибка", message: "\(error.localizedDescription)", actions: [.okAction], completionHandler: nil)
        }
    }
}

    //MARK: - UITextFieldDelegate
extension SettingsAndStatisticsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

