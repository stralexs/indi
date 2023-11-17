//
//  StoryModeViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 25.05.23.
//

import RxSwift
import RxCocoa

protocol StoryModeViewModelData {
    var userName: PublishRelay<String> { get }
    var userAvatar: PublishRelay<String> { get }
    var casualStudyStagesButtonsAccess: PublishRelay<[Bool]> { get }
    var variabilityStudyStagesButtonsAccess: PublishRelay<[(String, Bool)]> { get }
    var examButtonsAccess: PublishRelay<[Bool]> { get }
    var isFinalExamCompleted: PublishRelay<Bool> { get }
}

protocol StoryModeViewModelLogic {
    func saveSelectedStage(for buttonTag: Int) -> String
    func fetchData()
    func viewModelForSettingAndStatistics() -> SettingsAndStatisticsViewModelData & SettingsAndStatisticsViewModelLogic
    func viewModelForKitSelection(chosenStudyStage: Int) -> StoryModeKitSelectionViewModelData & StoryModeKitSelectionViewModelLogic
    func viewModelForExam(_ chosenExam: Int) -> StoryModeExamViewModelData & StoryModeExamViewModelLogic
}

final class StoryModeViewModel: StoryModeViewModelData {
    let userName = PublishRelay<String>()
    let userAvatar = PublishRelay<String>()
    let casualStudyStagesButtonsAccess = PublishRelay<[Bool]>()
    let variabilityStudyStagesButtonsAccess = PublishRelay<[(String, Bool)]>()
    let examButtonsAccess = PublishRelay<[Bool]>()
    let isFinalExamCompleted = PublishRelay<Bool>()
}

extension StoryModeViewModel: StoryModeViewModelLogic {
    private func fetchUserNameAndAvatar() {
        let name = UserDataManager.shared.getUserName()
        let avatar = UserDataManager.shared.getUserAvatar()
        userName.accept(name)
        userAvatar.accept(avatar)
    }
    
    // MARK: - Exam methods
    private func isHigherThanSeventyFilter(for studyStages: [Int]) -> Bool {
        let kitNames = KitsManager.shared.getKitNamesForStudyStage(with: studyStages)
        let userResults = kitNames.map { UserDataManager.shared.getUserResult(for: $0) }
        let filteredResult = userResults.filter { $0 >= 70 }
        
        let output = filteredResult.count == userResults.count ? true : false
        return output
    }
    
    private func examAccessControl(for senderRawValue: Int) -> Bool {
        var result = Bool()
        switch senderRawValue {
        case 0:
            result = isHigherThanSeventyFilter(for: [0])
        case 1:
            result = isHigherThanSeventyFilter(for: [1])
        case 2:
            result = isHigherThanSeventyFilter(for: [2])
        case 3:
            result = isHigherThanSeventyFilter(for: [3,4])
        default:
            if UserDataManager.shared.getSelectedStages() == [] {
                result = isHigherThanSeventyFilter(for: [5,6,7])
            } else {
                result = isHigherThanSeventyFilter(for: UserDataManager.shared.getSelectedStages())
            }
        }
        
        return result
    }
    
    private func fetchExamAccess() {
        let examButtonsAccess = (0...4).map {
            let examCompletion = UserDataManager.shared.getExamCompletion(for: $0)
            let examRusult = UserDataManager.shared.getUserResult(for: StudyStage.getExamName(studyStage: $0))
            
            if examRusult >= 50 {
                UserDataManager.shared.saveExamCompletion(for: $0)
            }
            
            var output = true
            if examCompletion == "Uncompleted" {
                if examAccessControl(for: $0) {
                    output = true
                } else {
                    output = false
                }
            }
            return output
        }
        self.examButtonsAccess.accept(examButtonsAccess)
    }
    
    private func fetchFinalExamCompletion() {
        let completion = UserDataManager.shared.getUserResult(for: "Final exam") >= 50
        isFinalExamCompleted.accept(completion)
    }
    
    // MARK: - Study Stage buttons methods
    private func studyStageAccessControl(for senderTag: Int) -> Bool {
        switch senderTag {
        case 0:
            return true
        case 1:
            return UserDataManager.shared.getUserResult(for: "Newborn exam") >= 50 ? true : false
        case 2:
            return UserDataManager.shared.getUserResult(for: "Preschool exam") >= 50 ? true : false
        case 3,4:
            return UserDataManager.shared.getUserResult(for: "Early school exam") >= 50 ? true : false
        default:
            return UserDataManager.shared.getUserResult(for: "High school exam") >= 50 ? true : false
        }
    }
    
    private func fetchCasualStudyStagesButtonsAccess() {
        let buttonsAccess = (0...5).map {
            return studyStageAccessControl(for: $0)
        }
        casualStudyStagesButtonsAccess.accept(buttonsAccess)
    }
    
    private func fetchVariabilityStudyStagesButtonsSelection() {
        let buttonsAccess = (0...7).map {
            let stageSelection = UserDataManager.shared.getStageSelection(for: $0)
            let access = studyStageAccessControl(for: $0)
            return (stageSelection, access)
        }
        variabilityStudyStagesButtonsAccess.accept(buttonsAccess)
    }
    
    func saveSelectedStage(for buttonTag: Int) -> String {
        UserDataManager.shared.saveStageSelection(for: buttonTag)
        UserDataManager.shared.saveSelectedStages(for: buttonTag)
        return UserDataManager.shared.getStageSelection(for: buttonTag)
    }
    
    // MARK: - General method
    func fetchData() {
        fetchUserNameAndAvatar()
        fetchExamAccess()
        fetchFinalExamCompletion()
        fetchCasualStudyStagesButtonsAccess()
        fetchVariabilityStudyStagesButtonsSelection()
    }

    // MARK: - ViewModels methods
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
