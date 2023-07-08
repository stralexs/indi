//
//  UserDataManager.swift
//  Indi
//
//  Created by Alexander Sivko on 24.05.23.
//

import Foundation

final class UserDataManager {
    static let shared = UserDataManager()
    
    private func createBasicUserData() {
        let _: Int = UserDefaults.standard.integer(forKey: "Basic colors")
        let _: Int = UserDefaults.standard.integer(forKey: "Basic words")
        let _: Int = UserDefaults.standard.integer(forKey: "Farm animals")
        
        let _: Int = UserDefaults.standard.integer(forKey: "Basic alphabet")
        let _: Int = UserDefaults.standard.integer(forKey: "Body parts")
        
        let _: Int = UserDefaults.standard.integer(forKey: "Basic English grammar")
        let _: Int = UserDefaults.standard.integer(forKey: "Maths")
        
        let _: Int = UserDefaults.standard.integer(forKey: "Advanced English grammar")
        let _: Int = UserDefaults.standard.integer(forKey: "Biology")
        let _: Int = UserDefaults.standard.integer(forKey: "Geography")
        
        let _: Int = UserDefaults.standard.integer(forKey: "Entertainment and media")
        let _: Int = UserDefaults.standard.integer(forKey: "Shopping")
        let _: Int = UserDefaults.standard.integer(forKey: "Sports")
        
        let _: Int = UserDefaults.standard.integer(forKey: "Computer")
        let _: Int = UserDefaults.standard.integer(forKey: "Swift")
        
        let _: Int = UserDefaults.standard.integer(forKey: "Construction materials")
        let _: Int = UserDefaults.standard.integer(forKey: "Construction participants")
        
        let _: Int = UserDefaults.standard.integer(forKey: "Courier")
        let _: Int = UserDefaults.standard.integer(forKey: "Taxi driver")
        let _: Int = UserDefaults.standard.integer(forKey: "Waiter")
        
        let _: Int = UserDefaults.standard.integer(forKey: "Newborn exam")
        let _: Int = UserDefaults.standard.integer(forKey: "Preschool exam")
        let _: Int = UserDefaults.standard.integer(forKey: "Early school exam")
        let _: Int = UserDefaults.standard.integer(forKey: "High school exam")
        let _: Int = UserDefaults.standard.integer(forKey: "Final exam")
        
        let _: Int = UserDefaults.standard.integer(forKey: "Completed exams count")
        let _: Int = UserDefaults.standard.integer(forKey: "Completed tests count")
        let _: Int = UserDefaults.standard.integer(forKey: "Correct answers count")
        let _: Int = UserDefaults.standard.integer(forKey: "Total questions count")

        let _: String = UserDefaults.standard.string(forKey: "0") ?? "Uncompleted"
        let _: String = UserDefaults.standard.string(forKey: "1") ?? "Uncompleted"
        let _: String = UserDefaults.standard.string(forKey: "2") ?? "Uncompleted"
        let _: String = UserDefaults.standard.string(forKey: "3") ?? "Uncompleted"
        let _: String = UserDefaults.standard.string(forKey: "4") ?? "Uncompleted"
        
        let _: String = UserDefaults.standard.string(forKey: "5") ?? "Unselected"
        let _: String = UserDefaults.standard.string(forKey: "6") ?? "Unselected"
        let _: String = UserDefaults.standard.string(forKey: "7") ?? "Unselected"
        
        let _: Bool = UserDefaults.standard.bool(forKey: "Programming university selection")
        let _: Bool = UserDefaults.standard.bool(forKey: "Construction university selection")
        let _: Bool = UserDefaults.standard.bool(forKey: "Side jobs selection")
                
        let _: String = UserDefaults.standard.string(forKey: "UserName") ?? "Userame"
        let _: String = UserDefaults.standard.string(forKey: "UserAvatar") ?? "Cat_emoji"
    }
    
    //MARK: - User's Results and Achievements
    func createNewUserData(for newKitName: String) {
        UserDefaults.standard.set(0, forKey: newKitName)
    }
    
    func resetAchievements() {
        KitsManager.shared.getAllKitsNames().forEach { name in
            UserDefaults.standard.removeObject(forKey: name)
        }
        UserDefaults.standard.removeObject(forKey: "Newborn exam")
        UserDefaults.standard.removeObject(forKey: "Preschool exam")
        UserDefaults.standard.removeObject(forKey: "Early school exam")
        UserDefaults.standard.removeObject(forKey: "High school exam")
        UserDefaults.standard.removeObject(forKey: "Final exam")
        
        UserDefaults.standard.removeObject(forKey: "Completed exams count")
        UserDefaults.standard.removeObject(forKey: "Completed tests count")
        UserDefaults.standard.removeObject(forKey: "Correct answers count")
        UserDefaults.standard.removeObject(forKey: "Total questions count")
        
        UserDefaults.standard.set("Uncompleted", forKey: "0")
        UserDefaults.standard.set("Uncompleted", forKey: "1")
        UserDefaults.standard.set("Uncompleted", forKey: "2")
        UserDefaults.standard.set("Uncompleted", forKey: "3")
        UserDefaults.standard.set("Uncompleted", forKey: "4")
        UserDefaults.standard.set("Unselected", forKey: "5")
        UserDefaults.standard.set("Unselected", forKey: "6")
        UserDefaults.standard.set("Unselected", forKey: "7")
        
        UserDefaults.standard.set(false, forKey: "Programming university selection")
        UserDefaults.standard.set(false, forKey: "Construction university selection")
        UserDefaults.standard.set(false, forKey: "Side jobs selection")
    }
    
    func saveUserResult(newResult: Int, kitName: String, completedTests: Int, completedExams: Int, correctAnswers: Int, totalQuestions: Int) {
        let previousResult = UserDefaults.standard.integer(forKey: kitName)
        if newResult > previousResult {
            UserDefaults.standard.set(newResult, forKey: kitName)
        }
        
        var completedTestsCount = UserDefaults.standard.integer(forKey: "Completed tests count")
        completedTestsCount += completedTests
        UserDefaults.standard.set(completedTestsCount, forKey: "Completed tests count")
        
        var completedExamsCount = UserDefaults.standard.integer(forKey: "Completed exams count")
        completedExamsCount += completedExams
        UserDefaults.standard.set(completedExamsCount, forKey: "Completed exams count")
        
        var correctAnswersCount = UserDefaults.standard.integer(forKey: "Correct answers count")
        correctAnswersCount += correctAnswers
        UserDefaults.standard.set(correctAnswersCount, forKey: "Correct answers count")
        
        var totalQuestionsCount = UserDefaults.standard.integer(forKey: "Total questions count")
        totalQuestionsCount += totalQuestions
        UserDefaults.standard.set(totalQuestionsCount, forKey: "Total questions count")
    }
    
    func getUserStatistics() -> (tests: Int, exams: Int, correct: Int, percentage: Double) {
        let tests = UserDefaults.standard.integer(forKey: "Completed tests count")
        let exams = UserDefaults.standard.integer(forKey: "Completed exams count")
        let correctAnswers = UserDefaults.standard.integer(forKey: "Correct answers count")
        let totalQuestions = UserDefaults.standard.integer(forKey: "Total questions count")

        var percentage: Double = 0
        if totalQuestions != 0 {
            percentage = Double(correctAnswers) / Double(totalQuestions) * 100
            percentage = round(100 * percentage) / 100
        }
                
        return (tests, exams, correctAnswers, percentage)
    }
    
    
    func getUserResult(for keyName: String) -> Int {
        return UserDefaults.standard.integer(forKey: keyName)
    }
    
    //MARK: - User's Name and User's Avatar
    func saveUserName(for newName: String) {
        UserDefaults.standard.set(newName, forKey: "UserName")
    }
    
    func saveUserAvatar(for newAvatar: String) {
        UserDefaults.standard.set(newAvatar, forKey: "UserAvatar")
    }
    
    func getUserName() -> String {
        return UserDefaults.standard.string(forKey: "UserName") ?? "Username"
    }
    
    func getUserAvatar() -> String {
        return UserDefaults.standard.string(forKey: "UserAvatar") ?? "Cat_emoji"
    }
    
    //MARK: - Exam Completion
    func getExamCompletion(for buttonTag: Int) -> String {
        return UserDefaults.standard.string(forKey: String(buttonTag)) ?? "Uncompleted"
    }
    
    func saveExamCompletion(for buttonTag: Int) {
        UserDefaults.standard.set("Completed", forKey: String(buttonTag))
    }
    
    //MARK: - Final Study Stages Selection
    func saveStageSelection(for buttonTag: Int) {
        switch buttonTag {
        case 5:
            UserDefaults.standard.set(true, forKey: "Programming university selection")
        case 6:
            UserDefaults.standard.set(true, forKey: "Construction university selection")
        default:
            UserDefaults.standard.set(true, forKey: "Side jobs selection")
        }
    }
    
    func saveSelectedStages(for buttonTag: Int) {
        UserDefaults.standard.set("Selected", forKey: String(buttonTag))
    }
    
    func getStageSelection(for buttonTag: Int) -> String {
        return UserDefaults.standard.string(forKey: String(buttonTag)) ?? "Unselected"
    }
    
    func getSelectedStages() -> [Int] {
        var output: [Int] = []
        
        if UserDefaults.standard.bool(forKey: "Programming university selection") {
            output.append(5)
        }
        if UserDefaults.standard.bool(forKey: "Construction university selection") {
            output.append(6)
        }
        if UserDefaults.standard.bool(forKey: "Side jobs selection") {
            output.append(7)
        }
        
        return output
    }

    //MARK: - Initialization
    private init() {
        createBasicUserData()
    }
}
