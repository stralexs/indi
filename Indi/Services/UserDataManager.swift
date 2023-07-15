//
//  UserDataManager.swift
//  Indi
//
//  Created by Alexander Sivko on 24.05.23.
//

import Foundation

final class UserDataManager {
    static let shared = UserDataManager()
    
    //MARK: - Property Wrapper
    @propertyWrapper
    private struct Storage<T> {
        let key: String
        let defaultValue: T

        var wrappedValue: T {
            get {
                return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
            }
            set {
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }
    
    //MARK: - Basic User Data
    @Storage(key: "Basic colors", defaultValue: 0)
    private var basicColors: Int
    @Storage(key: "Basic words", defaultValue: 0)
    private var basicWords: Int
    @Storage(key: "Farm animals", defaultValue: 0)
    private var farmAnimals: Int
    @Storage(key: "Basic alphabet", defaultValue: 0)
    private var basicAlphabet: Int
    @Storage(key: "Body parts", defaultValue: 0)
    private var bodyParts: Int
    @Storage(key: "Basic English grammar", defaultValue: 0)
    private var basicEnglishGrammar: Int
    @Storage(key: "Maths", defaultValue: 0)
    private var maths: Int
    @Storage(key: "Advanced English grammar", defaultValue: 0)
    private var advancedEnglishGrammar: Int
    @Storage(key: "Biology", defaultValue: 0)
    private var biology: Int
    @Storage(key: "Geography", defaultValue: 0)
    private var geography: Int
    @Storage(key: "Entertainment and media", defaultValue: 0)
    private var entertainmentAndMedia: Int
    @Storage(key: "Shopping", defaultValue: 0)
    private var shopping: Int
    @Storage(key: "Sports", defaultValue: 0)
    private var sports: Int
    @Storage(key: "Computer", defaultValue: 0)
    private var computer: Int
    @Storage(key: "Swift", defaultValue: 0)
    private var swift: Int
    @Storage(key: "Construction materials", defaultValue: 0)
    private var constructionMaterials: Int
    @Storage(key: "Construction participants", defaultValue: 0)
    private var constructionParticipants: Int
    @Storage(key: "Courier", defaultValue: 0)
    private var courier: Int
    @Storage(key: "Taxi driver", defaultValue: 0)
    private var taxiDriver: Int
    @Storage(key: "Waiter", defaultValue: 0)
    private var waiter: Int
    
    @Storage(key: "Newborn exam", defaultValue: 0)
    private var newbornExamResult: Int
    @Storage(key: "Preschool exam", defaultValue: 0)
    private var preschoolExamResult: Int
    @Storage(key: "Early school exam", defaultValue: 0)
    private var earlySchoolExamResult: Int
    @Storage(key: "High school exam", defaultValue: 0)
    private var highSchoolExamResult: Int
    @Storage(key: "Final exam", defaultValue: 0)
    private var finalExamResult: Int
    
    @Storage(key: "Completed exams count", defaultValue: 0)
    private var completedExamsCount: Int
    @Storage(key: "Completed tests count", defaultValue: 0)
    private var completedTestsCount: Int
    @Storage(key: "Correct answers count", defaultValue: 0)
    private var correctAnswersCount: Int
    @Storage(key: "Total questions count", defaultValue: 0)
    private var totalQuestionsCount: Int
    
    @Storage(key: "0", defaultValue: "Uncompleted")
    private var newbornExamCompletion: String
    @Storage(key: "1", defaultValue: "Uncompleted")
    private var preschoolExamCompletion: String
    @Storage(key: "2", defaultValue: "Uncompleted")
    private var earlySchoolExamCompletion: String
    @Storage(key: "3", defaultValue: "Uncompleted")
    private var highSchoolExamCompletion: String
    @Storage(key: "4", defaultValue: "Uncompleted")
    private var finalExamCompletion: String
    @Storage(key: "5", defaultValue: "Unselected")
    private var programmingUniversitySelectionIdentifier: String
    @Storage(key: "6", defaultValue: "Unselected")
    private var constructionUniversitySelectionIdentifier: String
    @Storage(key: "7", defaultValue: "Unselected")
    private var sideJobsSelectionIdentifier: String
    @Storage(key: "Programming university selection", defaultValue: false)
    private var programmingUniversitySelection: Bool
    @Storage(key: "Construction university selection", defaultValue: false)
    private var constructionUniversitySelection: Bool
    @Storage(key: "Side jobs selection", defaultValue: false)
    private var sideJobsSelection: Bool
    
    @Storage(key: "UserName", defaultValue: "Username")
    private var userName: String
    @Storage(key: "UserAvatar", defaultValue: "Cat_emoji")
    private var userAvatar: String
    
    //MARK: - User's Results and Achievements
    func createNewUserData(for newKitName: String) {
        UserDefaults.standard.set(0, forKey: newKitName)
    }
    
    func resetAchievements() {
        KitsManager.shared.getAllKitsNames().forEach { name in
            UserDefaults.standard.removeObject(forKey: name)
        }
        
        newbornExamResult = 0
        preschoolExamResult = 0
        earlySchoolExamResult = 0
        highSchoolExamResult = 0
        finalExamResult = 0
        completedExamsCount = 0
        completedTestsCount = 0
        correctAnswersCount = 0
        totalQuestionsCount = 0
        
        newbornExamCompletion = "Uncompleted"
        preschoolExamCompletion = "Uncompleted"
        earlySchoolExamCompletion = "Uncompleted"
        highSchoolExamCompletion = "Uncompleted"
        finalExamCompletion = "Uncompleted"
        programmingUniversitySelectionIdentifier = "Unselected"
        constructionUniversitySelectionIdentifier = "Unselected"
        sideJobsSelectionIdentifier = "Unselected"
        
        programmingUniversitySelection = false
        constructionUniversitySelection = false
        sideJobsSelection = false
    }
    
    func saveUserResult(newResult: Int, kitName: String, completedTests: Int, completedExams: Int, correctAnswers: Int, totalQuestions: Int) {
        let previousResult = UserDefaults.standard.integer(forKey: kitName)
        if newResult > previousResult {
            UserDefaults.standard.set(newResult, forKey: kitName)
        }
        
        completedTestsCount += completedTests
        completedExamsCount += completedExams
        correctAnswersCount += correctAnswers
        totalQuestionsCount += totalQuestions
    }
    
    func getUserStatistics() -> (tests: Int, exams: Int, correct: Int, percentage: Double) {
        var percentage: Double = 0
        if totalQuestionsCount != 0 {
            percentage = Double(correctAnswersCount) / Double(totalQuestionsCount) * 100
            percentage = round(100 * percentage) / 100
        }
                
        return (completedTestsCount, completedExamsCount, correctAnswersCount, percentage)
    }
    
    
    func getUserResult(for keyName: String) -> Int {
        return UserDefaults.standard.integer(forKey: keyName)
    }
    
    //MARK: - User's Name and User's Avatar
    func saveUserName(for newName: String) {
        userName = newName
    }
    
    func saveUserAvatar(for newAvatar: String) {
        userAvatar = newAvatar
    }
    
    func getUserName() -> String {
        return userName
    }
    
    func getUserAvatar() -> String {
        return userAvatar
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
            programmingUniversitySelection = true
        case 6:
            constructionUniversitySelection = true
        default:
            sideJobsSelection = true
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
        
        if programmingUniversitySelection {
            output.append(5)
        }
        if constructionUniversitySelection {
            output.append(6)
        }
        if sideJobsSelection {
            output.append(7)
        }
        
        return output
    }
}
