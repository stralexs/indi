//
//  StoryModeTestingViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 19.05.23.
//

import RxSwift
import RxCocoa

protocol StoryModeTestingViewModelData {
    var questions: BehaviorRelay<[RandomAnswersQuestion]> { get }
    var answerResult: PublishRelay<Bool> { get }
    var testingResult: PublishRelay<Int> { get }
    var questionsCount: BehaviorRelay<String> { get }
    init(soundManager: SoundManagerLogic, selectedKit: IndexPath, studyStage: Int)
}

protocol StoryModeTestingViewModelLogic {
    func testStart()
    func test(titleLabel text: String?)
    func nextQuestion()
    func playSound(_ isAnswerCorrect: Bool)
}

    // MARK: - StoryModeTestingViewModelData
final class StoryModeTestingViewModel: StoryModeTestingViewModelData {
    private let selectedStudyStage: Int
    private let selectedKit: Int
    private let selectedKitName: String
    private let totalQuestionsCount: Int
    private var correctAnswersCount: Int = 0
    private var soundManager: SoundManagerLogic
    
    let questions: BehaviorRelay<[RandomAnswersQuestion]> = BehaviorRelay(value: [])
    let answerResult = PublishRelay<Bool>()
    let testingResult = PublishRelay<Int>()
    let questionsCount: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    required init(soundManager: SoundManagerLogic, selectedKit: IndexPath, studyStage: Int) {
        self.soundManager = soundManager
        self.selectedStudyStage = studyStage
        self.selectedKit = selectedKit.row
        self.selectedKitName = KitsManager.shared.getKitName(for: studyStage, with: selectedKit)
        self.totalQuestionsCount = KitsManager.shared.getKitForTesting(for: selectedStudyStage, and: self.selectedKit).count
        testStart()
        countQuestions()
    }
}

    // MARK: - StoryModeTestingViewModelLogic
extension StoryModeTestingViewModel: StoryModeTestingViewModelLogic {
    private func countQuestions() {
        let questionsCount = questions.value.count
        let questionsCountText = "\(totalQuestionsCount - questionsCount + 1)/\(totalQuestionsCount)"
        self.questionsCount.accept(questionsCountText)
    }
    
    func testStart() {
        let questions = KitsManager.shared.getKitForTesting(for: selectedStudyStage, and: selectedKit).shuffled()
        
        let questionsWithRandomAnswers: [RandomAnswersQuestion] = questions.map {
            var incorrectAnswers = $0.incorrectAnswers ?? []
            incorrectAnswers.append($0.correctAnswer ?? "")
            return RandomAnswersQuestion(question: $0.question ?? "",
                                         correctAnswer: $0.correctAnswer ?? "",
                                         randomAnswers: incorrectAnswers.shuffled())
        }
        
        self.questions.accept(questionsWithRandomAnswers)
    }
    
    func test(titleLabel text: String?) {
        guard let text = text,
              let correctAnswer = questions.value.first?.correctAnswer else { return }
        
        if text == correctAnswer {
            answerResult.accept(true)
            correctAnswersCount += 1
        } else {
            answerResult.accept(false)
        }
    }
    
    func nextQuestion() {
        var questions = questions.value
        questions.removeFirst()
        
        if questions.isEmpty {
            let testResult = Int(round(Double(correctAnswersCount) / Double(totalQuestionsCount) * 100))
            testingResult.accept(testResult)
            
            UserDataManager.shared.saveUserResult(newResult: testResult,
                                           kitName: selectedKitName,
                                           completedTests: 1,
                                           completedExams: 0,
                                           correctAnswers: correctAnswersCount,
                                           totalQuestions: totalQuestionsCount)
            
            correctAnswersCount = 0
        } else {
            self.questions.accept(questions)
            countQuestions()
        }
    }
    
    func playSound(_ isAnswerCorrect: Bool) {
        isAnswerCorrect ? soundManager.playCorrectSound() : soundManager.playWrongSound()
    }
}
