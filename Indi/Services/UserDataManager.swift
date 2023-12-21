//
//  UserDataManager.swift
//  Indi
//
//  Created by Alexander Sivko on 24.05.23.
//

import RxSwift
import RxCocoa

protocol UserDataManagerData {
    var userResults: BehaviorRelay<[String: Int]> { get }
    var stagesCompletionAndSelection: BehaviorRelay<[String: String]> { get }
    var variabilityStagesSelection: BehaviorRelay<[String: Bool]> { get }
    var userNameAndAvatar: BehaviorRelay<[String: String]> { get }
}

protocol UserDataManagerLogic {
    func createNewUserData(for newKitName: String)
    func resetAchievements()
    func saveUserResult(newResult: Int, kitName: String, completedTests: Int, completedExams: Int, correctAnswers: Int, totalQuestions: Int)
    func getUserStatistics() -> (tests: Int, exams: Int, correct: Int, percentage: Double)
    func saveUserName(for newName: String)
    func saveUserAvatar(for newAvatar: String)
    func saveExamCompletion(for examName: String)
    func saveStageSelection(for buttonTag: Int)
    func getSelectedStages() -> [Int]
}

fileprivate extension String {
    static let newbornExam = "Newborn exam"
    static let preschoolExam = "Preschool exam"
    static let earlySchoolExam = "Early school exam"
    static let highSchoolExam = "High school exam"
    static let finalExam = "Final exam"
    
    static let completedExamsCount = "Completed exams count"
    static let completedTestsCount = "Completed tests count"
    static let correctAnswersCount = "Correct answers count"
    static let totalQuestionsCount = "Total questions count"
    
    static let completed = "Completed"
    static let uncompleted = "Uncompleted"
    static let selected = "Selected"
    static let unselected = "Unselected"
    
    static let programmingUniversitySelection = "Programming university selection"
    static let constructionUniversitySelection = "Construction university selection"
    static let sideJobsSelection = "Side jobs selection"
    
    static let userName = "UserName"
    static let userAvatar = "UserAvatar"
}

final class UserDataManager: UserDataManagerData {
    static let shared = UserDataManager()
    private init() { fetchUserData() }
    
    private let disposeBag = DisposeBag()
    let userResults: BehaviorRelay<[String: Int]> = BehaviorRelay(value: [:])
    let stagesCompletionAndSelection: BehaviorRelay<[String: String]> = BehaviorRelay(value: [:])
    let variabilityStagesSelection: BehaviorRelay<[String: Bool]> = BehaviorRelay(value: [:])
    let userNameAndAvatar: BehaviorRelay<[String: String]> = BehaviorRelay(value: [:])
}

extension UserDataManager: UserDataManagerLogic {
    func createNewUserData(for newKitName: String) {
        UserDefaults.standard.set(0, forKey: newKitName)
        var userResults = userResults.value
        userResults[newKitName] = 0
        self.userResults.accept(userResults)
    }
    
    func resetAchievements() {
        let allKitsNames = KitsManager.shared.kits.value.map { $0.name ?? "" }
        let _ = allKitsNames.map { UserDefaults.standard.removeObject(forKey: $0) }
        
        UserDefaults.standard.setValue(0, forKey: String.newbornExam)
        UserDefaults.standard.setValue(0, forKey: String.preschoolExam)
        UserDefaults.standard.setValue(0, forKey: String.earlySchoolExam)
        UserDefaults.standard.setValue(0, forKey: String.highSchoolExam)
        UserDefaults.standard.setValue(0, forKey: String.finalExam)
        UserDefaults.standard.setValue(0, forKey: String.completedExamsCount)
        UserDefaults.standard.setValue(0, forKey: String.completedTestsCount)
        UserDefaults.standard.setValue(0, forKey: String.correctAnswersCount)
        UserDefaults.standard.setValue(0, forKey: String.totalQuestionsCount)
        
        UserDefaults.standard.setValue(String.uncompleted, forKey: "0")
        UserDefaults.standard.setValue(String.uncompleted, forKey: "1")
        UserDefaults.standard.setValue(String.uncompleted, forKey: "2")
        UserDefaults.standard.setValue(String.uncompleted, forKey: "3")
        UserDefaults.standard.setValue(String.uncompleted, forKey: "4")
        UserDefaults.standard.setValue(String.unselected, forKey: "5")
        UserDefaults.standard.setValue(String.unselected, forKey: "6")
        UserDefaults.standard.setValue(String.unselected, forKey: "7")
        
        UserDefaults.standard.setValue(false, forKey: String.programmingUniversitySelection)
        UserDefaults.standard.setValue(false, forKey: String.constructionUniversitySelection)
        UserDefaults.standard.setValue(false, forKey: String.sideJobsSelection)
        
        fetchUserData()
    }
    
    func saveUserResult(newResult: Int, kitName: String, completedTests: Int, completedExams: Int, correctAnswers: Int, totalQuestions: Int) {
        let previousResult = UserDefaults.standard.integer(forKey: kitName)
        if newResult > previousResult {
            UserDefaults.standard.set(newResult, forKey: kitName)
            var userResults = userResults.value
            userResults[kitName] = newResult
            self.userResults.accept(userResults)
        }
        
        var userResults = userResults.value
        
        var completedTestsCount = userResults[String.completedTestsCount] ?? 0
        completedTestsCount += completedTests
        userResults[String.completedTestsCount] = completedTestsCount
        UserDefaults.standard.set(completedTestsCount, forKey: String.completedTestsCount)
        
        var completedExamsCount = userResults[String.completedExamsCount] ?? 0
        completedExamsCount += completedExams
        userResults[String.completedExamsCount] = completedExamsCount
        UserDefaults.standard.set(completedExamsCount, forKey: String.completedExamsCount)
        
        var correctAnswersCount = userResults[String.correctAnswersCount] ?? 0
        correctAnswersCount += correctAnswers
        userResults[String.correctAnswersCount] = correctAnswersCount
        UserDefaults.standard.set(correctAnswersCount, forKey: String.correctAnswersCount)
        
        var totalQuestionsCount = userResults[String.totalQuestionsCount] ?? 0
        totalQuestionsCount += totalQuestions
        userResults[String.totalQuestionsCount] = totalQuestionsCount
        UserDefaults.standard.set(totalQuestionsCount, forKey: String.totalQuestionsCount)
        
        self.userResults.accept(userResults)
    }
    
    func getUserStatistics() -> (tests: Int, exams: Int, correct: Int, percentage: Double) {
        var percentage: Double = 0
        if userResults.value[String.totalQuestionsCount] != 0 {
            percentage = Double(userResults.value[String.correctAnswersCount] ?? 0) / Double(userResults.value[String.totalQuestionsCount] ?? 0) * 100
            percentage = round(100 * percentage) / 100
        }
                
        return (userResults.value[String.completedTestsCount] ?? 0,
                userResults.value[String.completedExamsCount] ?? 0,
                userResults.value[String.correctAnswersCount] ?? 0,
                percentage)
    }
    
    func saveUserName(for newName: String) {
        var userNameAndAvatar = userNameAndAvatar.value
        userNameAndAvatar[String.userName] = newName
        self.userNameAndAvatar.accept(userNameAndAvatar)
        UserDefaults.standard.setValue(newName, forKey: String.userName)
    }
    
    func saveUserAvatar(for newAvatar: String) {
        var userNameAndAvatar = userNameAndAvatar.value
        userNameAndAvatar[String.userAvatar] = newAvatar
        self.userNameAndAvatar.accept(userNameAndAvatar)
        UserDefaults.standard.setValue(newAvatar, forKey: String.userAvatar)
    }
    
    func saveExamCompletion(for examName: String) {
        var stagesCompletionAndSelection = stagesCompletionAndSelection.value
        switch examName {
        case "Newborn exam":
            UserDefaults.standard.set(String.completed, forKey: "0")
            stagesCompletionAndSelection["0"] = String.completed
        case "Preschool exam":
            UserDefaults.standard.set(String.completed, forKey: "1")
            stagesCompletionAndSelection["1"] = String.completed
        case "Early school exam":
            UserDefaults.standard.set(String.completed, forKey: "2")
            stagesCompletionAndSelection["2"] = String.completed
        case "High school exam":
            UserDefaults.standard.set(String.completed, forKey: "3")
            stagesCompletionAndSelection["3"] = String.completed
        case "Final exam":
            UserDefaults.standard.set(String.completed, forKey: "4")
            stagesCompletionAndSelection["4"] = String.completed
        default:
            break
        }
        self.stagesCompletionAndSelection.accept(stagesCompletionAndSelection)
    }
    
    func saveStageSelection(for buttonTag: Int) {
        var variabilityStagesSelection = self.variabilityStagesSelection.value
        var stagesCompletionAndSelection = self.stagesCompletionAndSelection.value
        switch buttonTag {
        case 5:
            UserDefaults.standard.setValue(true, forKey: String.programmingUniversitySelection)
            variabilityStagesSelection[String.programmingUniversitySelection] = true
            UserDefaults.standard.set(String.selected, forKey: "5")
            stagesCompletionAndSelection["5"] = String.selected
        case 6:
            UserDefaults.standard.setValue(true, forKey: String.constructionUniversitySelection)
            variabilityStagesSelection[String.constructionUniversitySelection] = true
            UserDefaults.standard.set(String.selected, forKey: "6")
            stagesCompletionAndSelection["6"] = String.selected
        case 7:
            UserDefaults.standard.setValue(true, forKey: String.sideJobsSelection)
            variabilityStagesSelection[String.sideJobsSelection] = true
            UserDefaults.standard.set(String.selected, forKey: "7")
            stagesCompletionAndSelection["7"] = String.selected
        default:
            break
        }
        self.variabilityStagesSelection.accept(variabilityStagesSelection)
        self.stagesCompletionAndSelection.accept(stagesCompletionAndSelection)
    }
        
    func getSelectedStages() -> [Int] {
        var output = [Int]()
        
        if UserDefaults.standard.bool(forKey: String.programmingUniversitySelection) {
            output.append(5)
        }
        if UserDefaults.standard.bool(forKey: String.constructionUniversitySelection) {
            output.append(6)
        }
        if UserDefaults.standard.bool(forKey: String.sideJobsSelection) {
            output.append(7)
        }
        
        return output
    }
}

extension UserDataManager {
    private func fetchUserData() {
        KitsManager.shared.kits
            .bind { kits in
                var userResults = [String: Int]()
                kits.forEach { userResults[$0.name ?? ""] = UserDefaults.standard.integer(forKey: $0.name ?? "") }
                
                userResults[String.newbornExam] = UserDefaults.standard.integer(forKey: String.newbornExam)
                userResults[String.preschoolExam] = UserDefaults.standard.integer(forKey: String.preschoolExam)
                userResults[String.earlySchoolExam] = UserDefaults.standard.integer(forKey: String.earlySchoolExam)
                userResults[String.highSchoolExam] = UserDefaults.standard.integer(forKey: String.highSchoolExam)
                userResults[String.finalExam] = UserDefaults.standard.integer(forKey: String.finalExam)
                userResults[String.completedExamsCount] = UserDefaults.standard.integer(forKey: String.completedExamsCount)
                userResults[String.completedTestsCount] = UserDefaults.standard.integer(forKey: String.completedTestsCount)
                userResults[String.correctAnswersCount] = UserDefaults.standard.integer(forKey: String.correctAnswersCount)
                userResults[String.totalQuestionsCount] = UserDefaults.standard.integer(forKey: String.totalQuestionsCount)
                
                self.userResults.accept(userResults)
            }
            .disposed(by: disposeBag)
        
        let stagesCompletionAndSelection = [
            "0": UserDefaults.standard.string(forKey: "0") ?? String.uncompleted,
            "1": UserDefaults.standard.string(forKey: "1") ?? String.uncompleted,
            "2": UserDefaults.standard.string(forKey: "2") ?? String.uncompleted,
            "3": UserDefaults.standard.string(forKey: "3") ?? String.uncompleted,
            "4": UserDefaults.standard.string(forKey: "4") ?? String.uncompleted,
            "5": UserDefaults.standard.string(forKey: "5") ?? String.unselected,
            "6": UserDefaults.standard.string(forKey: "6") ?? String.unselected,
            "7": UserDefaults.standard.string(forKey: "7") ?? String.unselected,
        ]
        self.stagesCompletionAndSelection.accept(stagesCompletionAndSelection)
        
        let variabilityStagesSelection = [
            String.programmingUniversitySelection: UserDefaults.standard.bool(forKey: String.programmingUniversitySelection),
            String.constructionUniversitySelection: UserDefaults.standard.bool(forKey: String.constructionUniversitySelection),
            String.sideJobsSelection: UserDefaults.standard.bool(forKey: String.sideJobsSelection)
        ]
        self.variabilityStagesSelection.accept(variabilityStagesSelection)
        
        let userNameAndAvatar = [
            String.userName: UserDefaults.standard.string(forKey: String.userName) ?? String.userName,
            String.userAvatar: UserDefaults.standard.string(forKey: String.userAvatar) ?? "Cat_emoji"
        ]
        self.userNameAndAvatar.accept(userNameAndAvatar)
    }
}
