//
//  ExamModel.swift
//  Indi
//
//  Created by Alexander Sivko on 20.05.23.
//

import Foundation
import UIKit

class ExamModel: Testing {
    private func createNotificationCenterObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(createKitsForExam(_:)), name: Notification.Name(rawValue: chosenExamNotificationKey), object: nil)
    }
    
    @objc private func createKitsForExam(_ notification: NSNotification) {
        if let chosenExam = notification.object as? Int {
            switch chosenExam {
            case 0:
                kitsForExam = [0]
                examName = "Newborn exam"
            case 1:
                kitsForExam = [1]
                examName = "Preschool exam"
            case 2:
                kitsForExam = [2]
                examName = "Early school exam"
            case 3:
                kitsForExam = [3,4]
                examName = "High school exam"
            default:
                kitsForExam = UserDataManager.shared.getSelectedStages()
                examName = "Final exam"
            }
        }
    }
    
    var examName: String = ""
    private var kitsForExam: [Int] = []
    private var examQuestions: [Question] = []
    private var totalQuestionsCount: Int = 0
    private var correctAnswersCount: Int = 0
    
    var userAnswer: String?
    
    func testStart() {
        var allExamQuestions = KitsManager.shared.getKitsForExam(with: kitsForExam).shuffled()
        var mediumArr: [Question] = []
        (1...10).forEach { _ in
            mediumArr.append(allExamQuestions.first!)
            allExamQuestions.remove(at: 0)
        }
        examQuestions = mediumArr
        totalQuestionsCount = examQuestions.count
    }
    
    func test(questionLabel: UILabel?, buttons: [UIButton]?, countLabel: UILabel?) {
        guard examQuestions.isEmpty == false,
              let question = examQuestions[0].question else { return }
        
        questionLabel?.text = question
        
        countLabel?.text = "\(totalQuestionsCount - examQuestions.count + 1)/\(totalQuestionsCount)"
    }
    
    func isRightAnswerCheck() -> Bool {
        guard examQuestions.isEmpty == false else { return false }
        var enteredText = userAnswer
        while enteredText?.first == " " {
            enteredText?.removeFirst()
        }
        while enteredText?.last == " " {
            enteredText?.removeLast()
        }
        
        let result: Bool = enteredText?.capitalized == examQuestions[0].correctAnswer?.capitalized
        if result {
            correctAnswersCount += 1
        }
        return result
    }
    
    func nextQuestion() {
        guard examQuestions.isEmpty == false else { return }
        examQuestions.removeFirst()
        if examQuestions.count < 1 {
            let testResult = Int(round(Double(correctAnswersCount) / Double(totalQuestionsCount) * 100))
            NotificationCenter.default.post(name: Notification.Name(rawValue: examResultNotificationKey), object: testResult)
            
            UserDataManager.shared.saveUserResult(newResult: testResult,
                                           kitName: examName,
                                           completedTests: 0,
                                           completedExams: 1,
                                           correctAnswers: correctAnswersCount,
                                           totalQuestions: totalQuestionsCount)
            resetResults()
        }
    }
    
    func resetResults() {
        correctAnswersCount = 0
        totalQuestionsCount = 0
        examQuestions = []
    }

    init() {
        createNotificationCenterObserver()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
