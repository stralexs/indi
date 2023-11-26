//
//  StoryModeViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 25.05.23.
//

import RxSwift
import RxCocoa

protocol StoryModeViewModelData {
    var userName: BehaviorRelay<String> { get }
    var userAvatar: BehaviorRelay<String> { get }
    var casualStudyStagesButtonsAccess: BehaviorRelay<[Bool]> { get }
    var variabilityStudyStagesButtonsAccess: BehaviorRelay<[Bool]> { get }
    var variabilityStudyStagesButtonsSelection: BehaviorRelay<[String]> { get }
    var examButtonsAccess: BehaviorRelay<[Bool]> { get }
    var isFinalExamCompleted: PublishRelay<Bool> { get }
}

protocol StoryModeViewModelLogic {
    func saveSelectedStage(for buttonTag: Int)
    func viewModelForSettingAndStatistics() -> SettingsAndStatisticsViewModelData & SettingsAndStatisticsViewModelLogic
    func viewModelForKitSelection(chosenStudyStage: Int) -> StoryModeKitSelectionViewModelData & StoryModeKitSelectionViewModelLogic
    func viewModelForExam(_ chosenExam: Int) -> StoryModeExamViewModelData & StoryModeExamViewModelLogic
}

final class StoryModeViewModel: StoryModeViewModelData {
    private let disposeBag = DisposeBag()
    
    let userName = BehaviorRelay<String>(value: "")
    let userAvatar = BehaviorRelay<String>(value: "")
    let casualStudyStagesButtonsAccess = BehaviorRelay<[Bool]>(value: [])
    let variabilityStudyStagesButtonsAccess = BehaviorRelay<[Bool]>(value: [])
    let variabilityStudyStagesButtonsSelection = BehaviorRelay<[String]>(value: [])
    let examButtonsAccess = BehaviorRelay<[Bool]>(value: [])
    let isFinalExamCompleted = PublishRelay<Bool>()
    
    init() {
        setupUserNameAndAvatar()
        setupCasualStudyStagesButtonsAccess()
        setupVariabilityStudyStagesButtons()
        setupExamAccess()
        setupFinalExamCompletion()
    }
}

extension StoryModeViewModel: StoryModeViewModelLogic {
    func saveSelectedStage(for buttonTag: Int) {
        UserDataManager.shared.saveStageSelection(for: buttonTag)
    }
    
    func viewModelForSettingAndStatistics() -> SettingsAndStatisticsViewModelData & SettingsAndStatisticsViewModelLogic {
        return SettingsAndStatisticsViewModel()
    }
    
    func viewModelForKitSelection(chosenStudyStage: Int) -> StoryModeKitSelectionViewModelData & StoryModeKitSelectionViewModelLogic {
        return StoryModeKitSelectionViewModel(chosenStudyStage: chosenStudyStage)
    }
    
    func viewModelForExam(_ chosenExam: Int) -> StoryModeExamViewModelData & StoryModeExamViewModelLogic {
        return StoryModeExamViewModel(soundManager: SoundManager(), chosenExam: chosenExam)
    }
}

    // MARK: -  Rx setup
extension StoryModeViewModel {
    private func setupUserNameAndAvatar() {
        UserDataManager.shared.userNameAndAvatar
            .bind { results in
                let userName = results["UserName"] ?? "Username"
                let userAvatar = results["UserAvatar"] ?? "Cat_emoji"
                self.userName.accept(userName)
                self.userAvatar.accept(userAvatar)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupCasualStudyStagesButtonsAccess() {
        UserDataManager.shared.userResults
            .bind { results in
                let buttonsAccess = [
                    true,
                    results["Newborn exam"] ?? 0 >= 50,
                    results["Preschool exam"] ?? 0 >= 50,
                    results["Early school exam"] ?? 0 >= 50,
                    results["Early school exam"] ?? 0 >= 50,
                    results["High school exam"] ?? 0 >= 50
                ]
                self.casualStudyStagesButtonsAccess.accept(buttonsAccess)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupVariabilityStudyStagesButtons() {
        UserDataManager.shared.stagesCompletionAndSelection
            .bind { selection in
                let buttonsSelection = [
                    "", "", "", "", "",
                    selection["5"] ?? "Unselected",
                    selection["6"] ?? "Unselected",
                    selection["7"] ?? "Unselected"
                ]
                self.variabilityStudyStagesButtonsSelection.accept(buttonsSelection)
            }
            .disposed(by: disposeBag)
        
        UserDataManager.shared.userResults
            .bind { results in
                let buttonsAccess = [
                    false, false, false, false, false,
                    results["High school exam"] ?? 0 >= 50,
                    results["High school exam"] ?? 0 >= 50,
                    results["High school exam"] ?? 0 >= 50
                ]
                self.variabilityStudyStagesButtonsAccess.accept(buttonsAccess)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupExamAccess() {
        UserDataManager.shared.userResults
            .bind { result in
                let examButtonsAccess = (0...4).map {
                        let examCompletion = UserDataManager.shared.stagesCompletionAndSelection.value["\($0)"] ?? "Uncompleted"
                        
                        var output = true
                        if examCompletion == "Uncompleted" {
                            if self.examAccessControl(for: $0) {
                                output = true
                            } else {
                                output = false
                            }
                        }
                        return output
                    }
                self.examButtonsAccess.accept(examButtonsAccess)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupFinalExamCompletion() {
        UserDataManager.shared.userResults
            .bind { results in
                let completion = results["Final exam"] ?? 0 >= 50
                self.isFinalExamCompleted.accept(completion)
            }
            .disposed(by: disposeBag)
    }
}

    // MARK: - Exam logic
extension StoryModeViewModel {
    private func isHigherThanSeventyFilter(for studyStages: [Int]) -> Bool {
        let kitsNames = studyStages.map { studyStage in
            return KitsManager.shared.kits.value.filter { $0.studyStage == studyStage }
        }
            .flatMap { $0 }
            .map { $0.name ?? "" }
        
        let userResults = kitsNames.map { UserDataManager.shared.userResults.value[$0] ?? 0 }
        let filteredResult = userResults.filter { $0 >= 70 }
        
        let output = filteredResult.count == userResults.count ? true : false
        return output
    }
    
    private func examAccessControl(for examInt: Int) -> Bool {
        var result = Bool()
        switch examInt {
        case 0:
            result = isHigherThanSeventyFilter(for: [0])
        case 1:
            result = isHigherThanSeventyFilter(for: [1])
        case 2:
            result = isHigherThanSeventyFilter(for: [2])
        case 3:
            result = isHigherThanSeventyFilter(for: [3,4])
        case 4:
            if UserDataManager.shared.getSelectedStages() == [] {
                result = isHigherThanSeventyFilter(for: [5,6,7])
            } else {
                result = isHigherThanSeventyFilter(for: UserDataManager.shared.getSelectedStages())
            }
        default:
            break
        }
        
        return result
    }
}
