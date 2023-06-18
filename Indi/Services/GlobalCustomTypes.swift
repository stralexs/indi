//
//  GlobalCustomTypes.swift
//  Indi
//
//  Created by Alexander Sivko on 30.05.23.
//

import Foundation
import UIKit

protocol Testing {
    var userAnswer: String? { get set }
    
    func testStart()
    func test(questionLabel UILabel: UILabel?, buttons UIButtons: [UIButton]?, countLabel UILabel: UILabel?)
    func isRightAnswerCheck() -> Bool
    func nextQuestion()
    func resetResults()
}


//MARK: - Notification Center keys

let chosenExamNotificationKey = "com.indi.chosenExam.notificationKey"
let chosenTestNotificationKey = "com.indi.chosenTest.notificationKey"
let testNotificationKey = "com.indi.testResult.notificationKey"
let examResultNotificationKey = "com.indi.examResult.notificationKey"
let chosenWorkoutNotificationKey = "com.indi.workoutResult.notificationKey"
let workoutResultNotificationKey = "com.indi.workoutResult.notificationKey"
let workoutIsDoneNotificationKey = "com.indi.workoutIsDone.notificationKey"
