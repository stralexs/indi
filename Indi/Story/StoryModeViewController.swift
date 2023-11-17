//
//  StoryModeViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 19.05.23.
//

import RxSwift
import RxCocoa

final class StoryModeViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet var casualStudyStageButtons: [UIButton]!
    @IBOutlet var examButtons: [UIButton]!
    @IBOutlet var variabilityStudyStageButtons: [UIButton]!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userAvatarImage: UIImageView!
    @IBOutlet var becomeIndigenousLabel: UILabel!
    @IBOutlet var gameCompletionLabel: UILabel!
    @IBOutlet var scrollViewContentView: UIView!

    private let disposeBag = DisposeBag()
    private var casualStudyStageButtonsLines = [CAShapeLayer]()
    private var variabilityStudyStageButtonsLines = [CAShapeLayer]()
    private var examButtonsLines = [CAShapeLayer]()
    
    var viewModel: (StoryModeViewModelData & StoryModeViewModelLogic)!
    
    //MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createLines()
        tuneUI()
        viewModel.fetchData()
        setupUserData()
        setupCasualStudyStagesButtons()
        setupVariabilityStudyStagesButtons()
        setupExamButtons()
        setupFinalExamCompletion()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        drawCasualStudyStagesLines()
        drawVariabilityLines()
        drawExamLines()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchData()
        setNavigationBarHidden(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNavigationBarHidden(false)
    }
}

    // MARK: - Rx setup
extension StoryModeViewController {
    private func setupUserData() {
        viewModel.userName.bind {
            self.userNameLabel.text = $0
        }
        .disposed(by: disposeBag)
        
        viewModel.userAvatar.bind {
            self.userAvatarImage.image = UIImage(named: $0)
        }
        .disposed(by: disposeBag)
    }
    
    private func setupCasualStudyStagesButtons() {
        casualStudyStageButtons.forEach { button in
            viewModel.casualStudyStagesButtonsAccess
                .map { $0[button.tag] }
                .bind { accessProvided in
                    let alpha = accessProvided ? 1 : 0.5
                    button.alpha = alpha
                    self.casualStudyStageButtonsLines[button.tag].opacity = Float(alpha)
                }
                .disposed(by: disposeBag)
        }
    }
    
    private func setupVariabilityStudyStagesButtons() {
        variabilityStudyStageButtons.forEach { button in
            viewModel.variabilityStudyStagesButtonsAccess
                .map { $0[button.tag] }
                .bind { stageInfo in
                    let stageSelection = stageInfo.0
                    let access = stageInfo.1
                    if stageSelection == "Unselected" {
                        button.backgroundColor = access ? .indiLightPink : .clear
                        button.tintColor = access ? .black : .indiLightPink
                        button.alpha = access ? 1 : 0.5
                        self.variabilityStudyStageButtonsLines[button.tag].opacity = Float(0.5)
                    } else {
                        button.backgroundColor = .clear
                        button.tintColor = UIColor.indiLightPink
                        self.variabilityStudyStageButtonsLines[button.tag].opacity = Float(1)
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    private func setupExamButtons() {
        examButtons.forEach { button in
            viewModel.examButtonsAccess
                .map { $0[button.tag] }
                .bind { accessProvided in
                    let alpha = accessProvided ? 1 : 0.5
                    button.alpha = alpha
                    self.examButtonsLines[button.tag].opacity = Float(alpha)

                }
                .disposed(by: disposeBag)
        }
    }
    
    private func setupFinalExamCompletion() {
        viewModel.isFinalExamCompleted.bind { isCompleted in
            if isCompleted {
                self.becomeIndigenousLabel.isHidden = true
                self.gameCompletionLabel.isHidden = false
            }
        }
        .disposed(by: disposeBag)
    }
}

    // MARK: - Functionality
extension StoryModeViewController {
    private func setNavigationBarHidden(_ isHidden: Bool) {
        navigationController?.setNavigationBarHidden(isHidden, animated: false)
    }
    
    private func tuneUI() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .indiMainYellow

        casualStudyStageButtons.forEach {
            $0.layer.borderWidth = 5
            $0.layer.borderColor = UIColor.white.cgColor
        }
        variabilityStudyStageButtons.forEach {
            $0.layer.borderWidth = 5
            $0.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    //MARK: - Casual Tests and Exams
    @IBAction private func studyStageButtonIsPressed(_ sender: UIButton) {
        if sender.alpha == 0.5 {
            presentBasicAlert(title: "Доступ закрыт!", message: "Чтобы открыть доступ к данной стадии обучения, вы должны пройти экзамен предыдущего уровня не менее чем на 50%", actions: [.okAction], completionHandler: nil)
        } else {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            if let kitSelectionVC = sb.instantiateViewController(withIdentifier: "KitSelectionVC") as? StoryModeKitSelectionViewController {
                kitSelectionVC.viewModel = viewModel.viewModelForKitSelection(chosenStudyStage: sender.tag)
                kitSelectionVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(kitSelectionVC, animated: true)
            }
        }
    }
    
    @IBAction private func examButtonIsPressed(_ sender: UIButton) {
        if sender.alpha == 0.5 {
            presentBasicAlert(title: "Доступ закрыт!", message: "Чтобы открыть доступ к экзамену, вы должны выполнить все тесты соответствующей стадии обучения более чем на 70%", actions: [.okAction], completionHandler: nil)
        } else {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            if let examVC = sb.instantiateViewController(withIdentifier: "ExamVC") as? StoryModeExamViewController {
                examVC.viewModel = viewModel.viewModelForExam(sender.tag)
                examVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(examVC, animated: true)
            }
        }
    }
    
    //MARK: - Final Tests with Variability
    @IBAction private func finalStudyStageButtonIsPressed(_ sender: UIButton) {
        if sender.alpha == 0.5 {
            presentBasicAlert(title: "Доступ закрыт!", message: "Чтобы открыть доступ к данной стадии обучения, вы должны пройти экзамен предыдущего уровня не менее чем на 50%", actions: [.okAction], completionHandler: nil)
            
        } else if sender.backgroundColor == .indiLightPink {
            let alert = UIAlertController(title: "Пора выбирать!", message: "На этом этапе вы можете выбирать, что хотите учить. Открыть эту стадию обучения? (Вопросы из этой стадии появятся на финальном экзамене)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .cancel) { _ in
                sender.restorationIdentifier = self.viewModel.saveSelectedStage(for: sender.tag)
                let sb = UIStoryboard(name: "Main", bundle: nil)
                if let kitSelectionVC = sb.instantiateViewController(withIdentifier: "KitSelectionVC") as? StoryModeKitSelectionViewController {
                    kitSelectionVC.viewModel = self.viewModel.viewModelForKitSelection(chosenStudyStage: sender.tag)
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
                kitSelectionVC.viewModel = viewModel.viewModelForKitSelection(chosenStudyStage: sender.tag)
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
            settingsVC.viewModel = viewModel.viewModelForSettingAndStatistics()
            self.navigationController?.pushViewController(settingsVC, animated: true)
        }
    }
}

    // MARK: - Drawing lines
extension StoryModeViewController {
    private func createLines() {
        casualStudyStageButtonsLines = (0...5).map { _ in return CAShapeLayer() }
        variabilityStudyStageButtonsLines = (0...7).map { _ in return CAShapeLayer() }
        examButtonsLines = (0...4).map { _ in return CAShapeLayer() }
    }
    
    private func drawCasualStudyStagesLines() {
        // MARK: NewbornExamToPreschoolLine
        let newbornExamToPreschoolPath = UIBezierPath()
        newbornExamToPreschoolPath.move(to: CGPoint(x: examButtons[0].frame.midX,
                                         y: examButtons[0].frame.maxY))
        newbornExamToPreschoolPath.addLine(to: CGPoint(x: casualStudyStageButtons[1].frame.midX,
                                            y: casualStudyStageButtons[1].frame.minY))
        casualStudyStageButtonsLines[1].path = newbornExamToPreschoolPath.cgPath
        casualStudyStageButtonsLines[1].strokeColor = UIColor.white.cgColor
        casualStudyStageButtonsLines[1].lineWidth = 5
        scrollViewContentView.layer.addSublayer(casualStudyStageButtonsLines[1])
        
        // MARK: PreschoolExamToToEarlySchoolLine
        let preschoolExamToToEarlySchoolPath = UIBezierPath()
        preschoolExamToToEarlySchoolPath.move(to: CGPoint(x: examButtons[1].frame.midX,
                                         y: examButtons[1].frame.maxY))
        preschoolExamToToEarlySchoolPath.addLine(to: CGPoint(x: casualStudyStageButtons[2].frame.midX,
                                            y: casualStudyStageButtons[2].frame.minY))
        casualStudyStageButtonsLines[2].path = preschoolExamToToEarlySchoolPath.cgPath
        casualStudyStageButtonsLines[2].strokeColor = UIColor.white.cgColor
        casualStudyStageButtonsLines[2].lineWidth = 5
        scrollViewContentView.layer.addSublayer(casualStudyStageButtonsLines[2])
        
        // MARK: EarlySchoolExamToHighSchoolLine
        let earlySchoolExamToHighSchoolPath = UIBezierPath()
        earlySchoolExamToHighSchoolPath.move(to: CGPoint(x: casualStudyStageButtons[3].frame.midX,
                                                          y: casualStudyStageButtons[3].frame.minY + 2))
        earlySchoolExamToHighSchoolPath.addLine(to: CGPoint(x: examButtons[2].frame.midX,
                                                             y: examButtons[2].frame.maxY - 1))
        earlySchoolExamToHighSchoolPath.addLine(to: CGPoint(x: casualStudyStageButtons[4].frame.midX,
                                                             y: casualStudyStageButtons[4].frame.minY + 2))
        let earlySchoolExamToHighSchoolPathMask = CAShapeLayer()
        let earlySchoolExamToHighSchoolPathMaskPath = UIBezierPath(rect: CGRect(x: view.frame.minX,
                                                                             y: examButtons[2].frame.maxY,
                                                                             width: view.frame.width / 2,
                                                                             height: (casualStudyStageButtons[4].frame.minY - examButtons[2].frame.maxY)))
        earlySchoolExamToHighSchoolPathMask.path = earlySchoolExamToHighSchoolPathMaskPath.cgPath
        casualStudyStageButtonsLines[3].path = earlySchoolExamToHighSchoolPath.cgPath
        casualStudyStageButtonsLines[3].strokeColor = UIColor.white.cgColor
        casualStudyStageButtonsLines[3].lineWidth = 5
        casualStudyStageButtonsLines[3].fillColor = UIColor.indiMainBlue.cgColor
        casualStudyStageButtonsLines[3].mask = earlySchoolExamToHighSchoolPathMask
        scrollViewContentView.layer.addSublayer(casualStudyStageButtonsLines[3])
        
        // MARK: EarlySchoolExamToLifeActivitiesLine
        let earlySchoolExamToLifeActivitiesPath = UIBezierPath()
        earlySchoolExamToLifeActivitiesPath.move(to: CGPoint(x: casualStudyStageButtons[3].frame.midX,
                                                          y: casualStudyStageButtons[3].frame.minY + 2))
        earlySchoolExamToLifeActivitiesPath.addLine(to: CGPoint(x: examButtons[2].frame.midX,
                                                             y: examButtons[2].frame.maxY - 1))
        earlySchoolExamToLifeActivitiesPath.addLine(to: CGPoint(x: casualStudyStageButtons[4].frame.midX,
                                                             y: casualStudyStageButtons[4].frame.minY + 2))
        let earlySchoolExamToLifeActivitiesPathMask = CAShapeLayer()
        let earlySchoolExamToLifeActivitiesPathMaskPath = UIBezierPath(rect: CGRect(x: view.frame.midX,
                                                                             y: examButtons[2].frame.maxY,
                                                                             width: view.frame.width / 2,
                                                                             height: (casualStudyStageButtons[4].frame.minY - examButtons[2].frame.maxY)))
        earlySchoolExamToLifeActivitiesPathMask.path = earlySchoolExamToLifeActivitiesPathMaskPath.cgPath
        casualStudyStageButtonsLines[4].path = earlySchoolExamToLifeActivitiesPath.cgPath
        casualStudyStageButtonsLines[4].strokeColor = UIColor.white.cgColor
        casualStudyStageButtonsLines[4].lineWidth = 5
        casualStudyStageButtonsLines[4].fillColor = UIColor.indiMainBlue.cgColor
        casualStudyStageButtonsLines[4].mask = earlySchoolExamToLifeActivitiesPathMask
        scrollViewContentView.layer.addSublayer(casualStudyStageButtonsLines[4])
        
        // MARK: HighAndLifeExamToVariationsLine
        let highAndLifeExamToVariationsPath = UIBezierPath()
        highAndLifeExamToVariationsPath.move(to: CGPoint(x: examButtons[3].frame.midX,
                                                         y: examButtons[3].frame.maxY - 2))
        highAndLifeExamToVariationsPath.addLine(to: CGPoint(x: casualStudyStageButtons[3].frame.midX,
                                                            y: variabilityStudyStageButtons[0].frame.minY))
        highAndLifeExamToVariationsPath.addLine(to: CGPoint(x: casualStudyStageButtons[3].frame.midX,
                                                            y: variabilityStudyStageButtons[2].frame.maxY))
        let highAndLifeExamToVariationsMask = CAShapeLayer()
        let highAndLifeExamToVariationsMaskPath = UIBezierPath(rect: CGRect(x: view.frame.minX,
                                                                            y: examButtons[3].frame.maxY,
                                                                            width: view.frame.width,
                                                                            height: (variabilityStudyStageButtons[2].frame.maxY - examButtons[3].frame.maxY)))
        highAndLifeExamToVariationsMask.path = highAndLifeExamToVariationsMaskPath.cgPath
        casualStudyStageButtonsLines[5].path = highAndLifeExamToVariationsPath.cgPath
        casualStudyStageButtonsLines[5].strokeColor = UIColor.white.cgColor
        casualStudyStageButtonsLines[5].lineWidth = 6
        casualStudyStageButtonsLines[5].fillColor = UIColor.indiMainBlue.cgColor
        casualStudyStageButtonsLines[5].mask = highAndLifeExamToVariationsMask
        scrollViewContentView.layer.addSublayer(casualStudyStageButtonsLines[5])
    }
    
    private func drawVariabilityLines() {
        // MARK: VariationsToProgrammingLine
        let variationsToProgrammingPath = UIBezierPath()
        variationsToProgrammingPath.move(to: CGPoint(x: variabilityStudyStageButtons[0].frame.maxX,
                                                     y: variabilityStudyStageButtons[0].frame.midY))
        variationsToProgrammingPath.addLine(to: CGPoint(x: casualStudyStageButtons[3].frame.midX - 3,
                                                        y: variabilityStudyStageButtons[0].frame.midY))
        variabilityStudyStageButtonsLines[5].path = variationsToProgrammingPath.cgPath
        variabilityStudyStageButtonsLines[5].strokeColor = UIColor.white.cgColor
        variabilityStudyStageButtonsLines[5].lineWidth = 5
        scrollViewContentView.layer.addSublayer(variabilityStudyStageButtonsLines[5])
        
        // MARK: VariationsToConstructionLine
        let variationsToConstructionPath = UIBezierPath()
        variationsToConstructionPath.move(to: CGPoint(x: variabilityStudyStageButtons[1].frame.maxX,
                                                      y: variabilityStudyStageButtons[1].frame.midY))
        variationsToConstructionPath.addLine(to: CGPoint(x: casualStudyStageButtons[3].frame.midX - 3,
                                                         y: variabilityStudyStageButtons[1].frame.midY))
        variabilityStudyStageButtonsLines[6].path = variationsToConstructionPath.cgPath
        variabilityStudyStageButtonsLines[6].strokeColor = UIColor.white.cgColor
        variabilityStudyStageButtonsLines[6].lineWidth = 5
        scrollViewContentView.layer.addSublayer(variabilityStudyStageButtonsLines[6])
        
        // MARK: VariationsToSideJobsLine
        let variationsToSideJobsPath = UIBezierPath()
        variationsToSideJobsPath.move(to: CGPoint(x: variabilityStudyStageButtons[2].frame.maxX,
                                                  y: variabilityStudyStageButtons[2].frame.midY))
        variationsToSideJobsPath.addLine(to: CGPoint(x: casualStudyStageButtons[3].frame.midX - 3,
                                                     y: variabilityStudyStageButtons[2].frame.midY))
        variabilityStudyStageButtonsLines[7].path = variationsToSideJobsPath.cgPath
        variabilityStudyStageButtonsLines[7].strokeColor = UIColor.white.cgColor
        variabilityStudyStageButtonsLines[7].lineWidth = 5
        scrollViewContentView.layer.addSublayer(variabilityStudyStageButtonsLines[7])
    }
    
    private func drawExamLines() {
        // MARK: NewbornExamLine
        let newbornExamPath = UIBezierPath()
        newbornExamPath.move(to: CGPoint(x: casualStudyStageButtons[0].frame.midX,
                                         y: casualStudyStageButtons[0].frame.maxY))
        newbornExamPath.addLine(to: CGPoint(x: examButtons[0].frame.midX,
                                            y: examButtons[0].frame.minY))
        examButtonsLines[0].path = newbornExamPath.cgPath
        examButtonsLines[0].strokeColor = UIColor.white.cgColor
        examButtonsLines[0].lineWidth = 5
        scrollViewContentView.layer.addSublayer(examButtonsLines[0])
        
        // MARK: PreschoolExamLine
        let preschoolExamPath = UIBezierPath()
        preschoolExamPath.move(to: CGPoint(x: casualStudyStageButtons[1].frame.midX,
                                           y: casualStudyStageButtons[1].frame.maxY))
        preschoolExamPath.addLine(to: CGPoint(x: examButtons[1].frame.midX,
                                              y: examButtons[1].frame.minY))
        examButtonsLines[1].path = preschoolExamPath.cgPath
        examButtonsLines[1].strokeColor = UIColor.white.cgColor
        examButtonsLines[1].lineWidth = 5
        scrollViewContentView.layer.addSublayer(examButtonsLines[1])
        
        // MARK: EarlySchoolExamLine
        let earlySchoolExamPath = UIBezierPath()
        earlySchoolExamPath.move(to: CGPoint(x: casualStudyStageButtons[2].frame.midX,
                                             y: casualStudyStageButtons[2].frame.maxY))
        earlySchoolExamPath.addLine(to: CGPoint(x: examButtons[2].frame.midX,
                                                y: examButtons[2].frame.minY))
        examButtonsLines[2].path = earlySchoolExamPath.cgPath
        examButtonsLines[2].strokeColor = UIColor.white.cgColor
        examButtonsLines[2].lineWidth = 5
        scrollViewContentView.layer.addSublayer(examButtonsLines[2])
        
        // MARK: HighSchoolExamLine
        let highSchoolExamPath = UIBezierPath()
        highSchoolExamPath.move(to: CGPoint(x: casualStudyStageButtons[3].frame.midX,
                                            y: casualStudyStageButtons[3].frame.maxY - 2))
        highSchoolExamPath.addLine(to: CGPoint(x: examButtons[3].frame.midX,
                                               y: examButtons[3].frame.minY + 1))
        highSchoolExamPath.addLine(to: CGPoint(x: casualStudyStageButtons[4].frame.midX,
                                               y: casualStudyStageButtons[4].frame.maxY - 2))
        let highSchoolExamMask = CAShapeLayer()
        let highShoolExamMaskPath = UIBezierPath(rect: CGRect(x: casualStudyStageButtons[4].frame.minX,
                                                              y: casualStudyStageButtons[4].frame.maxY,
                                                              width: view.frame.width,
                                                              height: (examButtons[3].frame.minY - casualStudyStageButtons[4].frame.maxY)))
        highSchoolExamMask.path = highShoolExamMaskPath.cgPath
        examButtonsLines[3].path = highSchoolExamPath.cgPath
        examButtonsLines[3].strokeColor = UIColor.white.cgColor
        examButtonsLines[3].lineWidth = 6
        examButtonsLines[3].fillColor = UIColor.indiMainBlue.cgColor
        examButtonsLines[3].mask = highSchoolExamMask
        scrollViewContentView.layer.addSublayer(examButtonsLines[3])
        
        // MARK: FinalExamLine
        let finalExamPath = UIBezierPath()
        finalExamPath.move(to: CGPoint(x: casualStudyStageButtons[3].frame.midX + 3,
                                       y: variabilityStudyStageButtons[2].frame.maxY - 1))
        finalExamPath.addLine(to: CGPoint(x: examButtons[4].frame.midX,
                                          y: examButtons[4].frame.minY + 2))
        let finalExamMask = CAShapeLayer()
        let finalExamMaskPath = UIBezierPath(rect: CGRect(x: variabilityStudyStageButtons[2].frame.midX,
                                                          y: variabilityStudyStageButtons[2].frame.maxY,
                                                          width: view.frame.width,
                                                          height: (examButtons[4].frame.minY - variabilityStudyStageButtons[2].frame.maxY)))
        finalExamMask.path = finalExamMaskPath.cgPath
        examButtonsLines[4].path = finalExamPath.cgPath
        examButtonsLines[4].strokeColor = UIColor.white.cgColor
        examButtonsLines[4].lineWidth = 5
        examButtonsLines[4].mask = finalExamMask
        scrollViewContentView.layer.addSublayer(examButtonsLines[4])
    }
}
