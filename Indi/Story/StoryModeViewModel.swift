//
//  StoryModeViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 25.05.23.
//

import Foundation

protocol StoryModeViewModelProtocol {
    var examButtonsCompletion: ObservableObject<[String]> { get }
    var userName: String { get }
    var userAvatar: String { get }
    var isFinalExamCompleted: Bool { get }
    func setExamButtonAccess(for buttonTag: Int) -> Bool
    func setExamButtonCompletion(for buttonTag: Int) -> String
    func examName(for buttonTag: Int) -> String
    func saveSelectedStage(for buttonTag: Int) -> String
    func setFinalStudyStageButtonSelection(for buttonTag: Int) -> Bool
    func setFinalStudyStageButtonSelection(for buttonTag: Int) -> String
    func studyStageAccessControl(for senderTag: Int) -> Bool
    func viewModelForSettingAndStatistics() -> SettingsAndStatisticsViewModelProtocol?
    func viewModelForKitSelection(chosenStudyStage: Int) -> StoryModeKitSelectionViewModelData & StoryModeKitSelectionViewModelLogic
    func viewModelForExam(_ chosenExam: Int) -> StoryModeExamViewModelData & StoryModeExamViewModelLogic
}

final class StoryModeViewModel: StoryModeViewModelProtocol {
    //MARK: - Observable Objects
    var examButtonsCompletion: ObservableObject<[String]> = ObservableObject([])
    
    //MARK: - Private Method
    private func examAccessControl(for senderRawValue: Int) -> Bool {
        var result: Bool = true
                
        func isHigherThanSeventyFilter(for studyStages: [Int]) -> Bool {
            var output: Bool = true
            
            let kitNames = KitsManager.shared.getKitNamesForStudyStage(with: studyStages)
            var userResults: [Int] = []
            kitNames.forEach { name in
                userResults.append(UserDataManager.shared.getUserResult(for: name))
            }
            let filteredResult = userResults.filter { $0 >= 70 }
            
            output = filteredResult.count == userResults.count ? true : false
            return output
        }
        
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
    
    //MARK: - Public Variables
    var userName: String {
        return UserDataManager.shared.getUserName()
    }
    var userAvatar: String {
        return UserDataManager.shared.getUserAvatar()
    }
    var isFinalExamCompleted: Bool {
        return UserDataManager.shared.getUserResult(for: "Final exam") >= 50
    }
    
    //MARK: - Public Methods    
    func setExamButtonAccess(for buttonTag: Int) -> Bool {
        var output: Bool = true
        
        let restorationIdentifier = UserDataManager.shared.getExamCompletion(for: buttonTag)
        if restorationIdentifier == "Uncompleted" {
            if examAccessControl(for: buttonTag) {
                output = true
            } else {
                output = false
            }
        }
        
        return output
    }
    
    func setExamButtonCompletion(for buttonTag: Int) -> String {
        var output = ""
        
        if UserDataManager.shared.getUserResult(for: StudyStage.getExamName(studyStage: buttonTag)) >= 50 {
            UserDataManager.shared.saveExamCompletion(for: buttonTag)
        }
        output = UserDataManager.shared.getExamCompletion(for: buttonTag)
        
        return output
    }
    
    func examName(for buttonTag: Int) -> String {
        return StudyStage.getExamName(studyStage: buttonTag)
    }
    
    func saveSelectedStage(for buttonTag: Int) -> String {
        UserDataManager.shared.saveStageSelection(for: buttonTag)
        UserDataManager.shared.saveSelectedStages(for: buttonTag)
        return UserDataManager.shared.getStageSelection(for: buttonTag)
    }
    
    func setFinalStudyStageButtonSelection(for buttonTag: Int) -> Bool {
        var output: Bool = true
        
        let restorationIdentifier = UserDataManager.shared.getStageSelection(for: buttonTag)
        if restorationIdentifier == "Unselected" {
            output = true
        } else {
            output = false
        }
        
        return output
    }
    
    func setFinalStudyStageButtonSelection(for buttonTag: Int) -> String {
        return UserDataManager.shared.getStageSelection(for: buttonTag)
    }
    
    func studyStageAccessControl(for senderTag: Int) -> Bool {
        var result: Bool = true
        
        switch senderTag {
        case 0:
            result = true
        case 1:
            result = UserDataManager.shared.getUserResult(for: "Newborn exam") >= 50 ? true : false
        case 2:
            result = UserDataManager.shared.getUserResult(for: "Preschool exam") >= 50 ? true : false
        case 3,4:
            result = UserDataManager.shared.getUserResult(for: "Early school exam") >= 50 ? true : false
        default:
            result = UserDataManager.shared.getUserResult(for: "High school exam") >= 50 ? true : false
        }
        
        return result
    }
    
    func viewModelForSettingAndStatistics() -> SettingsAndStatisticsViewModelProtocol? {
        return SettingsAndStatisticsViewModel()
    }
    
    func viewModelForKitSelection(chosenStudyStage: Int) -> StoryModeKitSelectionViewModelData & StoryModeKitSelectionViewModelLogic {
        return StoryModeKitSelectionViewModel(chosenStudyStage: chosenStudyStage)
    }
    
    func viewModelForExam(_ chosenExam: Int) -> StoryModeExamViewModelData & StoryModeExamViewModelLogic {
        return StoryModeExamViewModel(soundManager: SoundManager(), chosenExam: chosenExam)
    }
}
