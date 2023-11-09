//
//  TrainingModeTestingViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 22.05.23.
//

import UIKit

protocol TrainingModeTestingViewModelProtocol {
    var testingProgress: Double { get }
    var userAnswer: String? { get set }
    func testStart()
    func test(questionLabel UILabel: UILabel?, buttons UIButtons: [UIButton]?, countLabel UILabel: UILabel?)
    func isRightAnswerCheck() -> Bool
    func nextQuestion()
    func resetResults()
    func anotherTest()
    func playCorrectSound()
    func playWrongSound()
    init(soundManager: SoundManagerProtocol, selectedKits: [IndexPath], selectedQuestionsCount: Int)
}

final class TrainingModeTestingViewModel: TrainingModeTestingViewModelProtocol {
    //MARK: - Private Variables
    private let selectedKits: [IndexPath]
    private let selectedQuestionsCount: Int
    private var totalQuestionsCountForProgress: Int = 0
    private var totalCorrectAnswersCountForProgress: Int = 0
    private var testingQuestions: [Question] = []
    private var totalQuestionsCount: Int = 0
    private var correctAnswersCount: Int = 0
    private var incorrectAnswers: [Question] = []
    private var soundManager: SoundManagerProtocol
    
    //MARK: - Public Variables
    var testingProgress: Double {
        var testResult: Double = 0
        testResult = Double(totalCorrectAnswersCountForProgress) / Double(totalQuestionsCountForProgress)
        return testResult
    }
    var userAnswer: String?
    
    //MARK: - Public Methods
    func testStart() {
        totalQuestionsCountForProgress = 0
        totalCorrectAnswersCountForProgress = 0
        
        var mediumQuestions: [Question] = []
        var secondMeduimQuestions: [Question] = []
        
        selectedKits.forEach { kit in
            mediumQuestions.append(contentsOf: KitsManager.shared.getKitForTesting(for: kit[0], and: kit[1]))
        }
        mediumQuestions = mediumQuestions.shuffled()
        (1...selectedQuestionsCount).forEach { _ in
            secondMeduimQuestions.append(mediumQuestions.first!)
            mediumQuestions.remove(at: 0)
        }
        testingQuestions = secondMeduimQuestions
        totalQuestionsCount = testingQuestions.count
        
        totalQuestionsCountForProgress = testingQuestions.count
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
            totalCorrectAnswersCountForProgress += 1
        } else {
            incorrectAnswers.append(testingQuestions[0])
        }
        return result
    }
    
    func nextQuestion() {
        guard testingQuestions.isEmpty == false else { return }
        testingQuestions.removeFirst()
        if testingProgress == 1 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "com.indi.trainingIsDone.notificationKey"), object: nil)
        }
        if testingQuestions.count < 1 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "com.indi.trainingResult.notificationKey"), object: [correctAnswersCount, totalQuestionsCount])
            correctAnswersCount = 0
        }
    }
    
    func resetResults() {
        correctAnswersCount = 0
        totalQuestionsCount = 0
        testingQuestions = []
        incorrectAnswers = []
    }
    
    func anotherTest() {
        testingQuestions = incorrectAnswers
        totalQuestionsCount = testingQuestions.count
        incorrectAnswers = []
    }
    
    func playCorrectSound() {
        soundManager.playCorrectSound()
    }
    
    func playWrongSound() {
        soundManager.playWrongSound()
    }
    
    //MARK: - Initialization
    required init(soundManager: SoundManagerProtocol, selectedKits: [IndexPath], selectedQuestionsCount: Int) {
        self.soundManager = soundManager
        self.selectedKits = selectedKits
        self.selectedQuestionsCount = selectedQuestionsCount
    }
}
