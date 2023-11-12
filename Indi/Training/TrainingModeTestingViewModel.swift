//
//  TrainingModeTestingViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 22.05.23.
//

import RxSwift
import RxCocoa

protocol TrainingModeTestingViewModelData {
    var questions: BehaviorSubject<[RandomAnswersQuestion]> { get }
    var testingProgress: BehaviorRelay<Float> { get }
    var answerResult: PublishRelay<Bool> { get }
    var trainingResult: PublishRelay<(Int, Int)> { get }
    var questionsCount: BehaviorRelay<String> { get }
    init(soundManager: SoundManagerLogic, selectedKits: [IndexPath], selectedQuestionsCount: Int)
}

protocol TrainingModeTestingViewModelLogic {
    func test(titleLabel text: String?)
    func nextQuestion()
    func anotherTest()
    func playSound(_ isAnswerCorrect: Bool)
}

    // MARK: - TrainingModeTestingViewModelData
final class TrainingModeTestingViewModel: TrainingModeTestingViewModelData {
    private var totalQuestionsCountForProgress: Int
    private var totalCorrectAnswersCountForProgress = 0
    private var totalQuestionsCount = 0
    private var correctAnswersCount = 0
    private var incorrectAnswers = [RandomAnswersQuestion]()
    private let soundManager: SoundManagerLogic
    
    let questions: BehaviorSubject<[RandomAnswersQuestion]> = BehaviorSubject(value: [])
    let answerResult = PublishRelay<Bool>()
    let trainingResult = PublishRelay<(Int, Int)>()
    let testingProgress: BehaviorRelay<Float> = BehaviorRelay(value: 0)
    let questionsCount: BehaviorRelay<String> = BehaviorRelay(value: "")

    required init(soundManager: SoundManagerLogic, selectedKits: [IndexPath], selectedQuestionsCount: Int) {
        self.soundManager = soundManager
        self.totalQuestionsCountForProgress = selectedQuestionsCount
        self.testStart(selectedKits: selectedKits, selectedQuestionsCount: selectedQuestionsCount)
        self.countQuestions()
    }
}

    // MARK: - TrainingModeTestingViewModelLogic
extension TrainingModeTestingViewModel: TrainingModeTestingViewModelLogic {
    private func testStart(selectedKits: [IndexPath], selectedQuestionsCount: Int) {
        let questionsSequence = selectedKits.map { KitsManager.shared.getKitForTesting(for: $0[0], and: $0[1]) }
            .flatMap { $0 }
            .shuffled()
            .prefix(selectedQuestionsCount)
        
        let questionsWithRandomAnswers: [RandomAnswersQuestion] = questionsSequence.map {
            var incorrectAnswers = $0.incorrectAnswers ?? []
            incorrectAnswers.append($0.correctAnswer ?? "")
            return RandomAnswersQuestion(question: $0.question ?? "",
                                         correctAnswer: $0.correctAnswer ?? "",
                                         randomAnswers: incorrectAnswers.shuffled())
        }
        
        questions.onNext(questionsWithRandomAnswers)
        totalQuestionsCount = questionsWithRandomAnswers.count
    }
    
    private func countProgress() {
        totalCorrectAnswersCountForProgress += 1
        let progress = Float(totalCorrectAnswersCountForProgress) / Float(totalQuestionsCountForProgress)
        testingProgress.accept(progress)
    }
    
    private func countQuestions() {
        guard let questionsCount = try? questions.value().count else { return }
        let questionsCountText = "\(totalQuestionsCount - questionsCount + 1)/\(totalQuestionsCount)"
        self.questionsCount.accept(questionsCountText)
    }
    
    func test(titleLabel text: String?) {
        guard let text = text,
              let correctAnswer = try? questions.value().first?.correctAnswer else { return }
        
        if text == correctAnswer {
            answerResult.accept(true)
            correctAnswersCount += 1
            countProgress()
        } else {
            answerResult.accept(false)
            if let incorrectAnswer = try? questions.value().first {
                incorrectAnswers.append(incorrectAnswer)
            }
        }
    }
    
    func nextQuestion() {
        guard var questions = try? questions.value() else { return }
        questions.removeFirst()
        
        if testingProgress.value == 1 {
            self.questions.onCompleted()
        } else if questions.isEmpty {
            trainingResult.accept((correctAnswersCount, totalQuestionsCount))
        } else {
            self.questions.onNext(questions)
            countQuestions()
        }
    }
    
    func anotherTest() {
        questions.onNext(incorrectAnswers)
        totalQuestionsCount = incorrectAnswers.count
        correctAnswersCount = 0
        incorrectAnswers = []
        countQuestions()
    }
    
    func playSound(_ isAnswerCorrect: Bool) {
        isAnswerCorrect ? soundManager.playCorrectSound() : soundManager.playWrongSound()
    }
}
