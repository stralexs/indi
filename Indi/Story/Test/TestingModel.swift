//
//  TestingModel.swift
//  Indi
//
//  Created by Alexander Sivko on 19.05.23.
//

import Foundation
import UIKit

class TestingModel: Testing {
    private func createNotificationCenterObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(setSelectedKit(_:)), name: Notification.Name(rawValue: chosenTestNotificationKey), object: nil)
    }
    
    @objc private func setSelectedKit(_ notification: NSNotification) {
        if let selectedKitInfo = notification.object as? (indexPath: IndexPath, studyStageRawValue: Int) {
            selectedStudyStage = selectedKitInfo.studyStageRawValue
            selectedKit = selectedKitInfo.indexPath.row
            selectedKitName = KitsManager.shared.getKitName(for: selectedKitInfo.studyStageRawValue, with: selectedKitInfo.indexPath)
        }
    }
    
    private var selectedStudyStage: Int?
    private var selectedKit: Int?
    private var selectedKitName: String?
    
    private var testingQuestions: [Question] = []
    private var totalQuestionsCount: Int = 0
    private var correctAnswersCount: Int = 0
    
    var userAnswer: String?
    
    func testStart() {
        guard let selectedStudyStage = selectedStudyStage,
              let selectedKit = selectedKit else { return }
        testingQuestions = KitsManager.shared.getKitForTesting(for: selectedStudyStage, and: selectedKit)
        testingQuestions = testingQuestions.shuffled()
        totalQuestionsCount = testingQuestions.count
    }
    
    func test(questionLabel: UILabel?, buttons: [UIButton]?, countLabel: UILabel?) {
        guard testingQuestions.isEmpty == false,
              let question = testingQuestions[0].question,
              let correctAnswer = testingQuestions[0].correctAnswer,
              let incorrectAnswers = testingQuestions[0].incorrectAnswers else { return }
        
        questionLabel?.text = question
        var answersArr = incorrectAnswers
        answersArr.append(correctAnswer)
        for button in buttons! {
            let randomElement = answersArr.randomElement()
            button.setTitle(randomElement!, for: .normal)
            answersArr.remove(at: answersArr.firstIndex(of: randomElement!)!)
        }
        countLabel?.text = "\(totalQuestionsCount - testingQuestions.count + 1)/\(totalQuestionsCount)"
    }
        
    func isRightAnswerCheck() -> Bool {
        guard testingQuestions.isEmpty == false else { return false }
        let result: Bool = userAnswer == testingQuestions[0].correctAnswer
        if result {
            correctAnswersCount += 1
        }
        return result
    }
    
    func nextQuestion() {
        guard testingQuestions.isEmpty == false else { return }
        testingQuestions.removeFirst()
        if testingQuestions.count < 1 {
            let testResult = Int(round(Double(correctAnswersCount) / Double(totalQuestionsCount) * 100))
            NotificationCenter.default.post(name: Notification.Name(rawValue: testNotificationKey), object: testResult)
            
            UserDataManager.shared.saveUserResult(newResult: testResult,
                                           kitName: selectedKitName!,
                                           completedTests: 1,
                                           completedExams: 0,
                                           correctAnswers: correctAnswersCount,
                                           totalQuestions: totalQuestionsCount)
            resetResults()
        }
    }
    
    func resetResults() {
        correctAnswersCount = 0
        totalQuestionsCount = 0
        testingQuestions = []
    }
    
    init() {
        createNotificationCenterObserver()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
