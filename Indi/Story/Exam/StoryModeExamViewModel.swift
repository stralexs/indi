//
//  StoryModeExamViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 20.05.23.
//

import RxSwift
import RxCocoa

protocol StoryModeExamViewModelData {
    var questions: BehaviorRelay<[Question]> { get }
    var answerResult: PublishRelay<Bool> { get }
    var examResult: PublishRelay<Int> { get }
    var questionsCount: BehaviorRelay<String> { get }
    var userExamResults: BehaviorRelay<Int> { get }
    init(soundManager: SoundManagerLogic, chosenExam: Int)
}

protocol StoryModeExamViewModelLogic {
    func examStart()
    func exam(textField text: String?)
    func nextQuestion()
    func playSound(_ isAnswerCorrect: Bool)
}

final class StoryModeExamViewModel: StoryModeExamViewModelData {
    private let chosenExam: Int
    private var examName = String()
    private var examQuestions = [Question]()
    private var totalQuestionsCount: Int = 10
    private var correctAnswersCount: Int = 0
    private var soundManager: SoundManagerLogic
    
    let questions: BehaviorRelay<[Question]> = BehaviorRelay(value: [])
    let answerResult = PublishRelay<Bool>()
    let examResult = PublishRelay<Int>()
    let questionsCount: BehaviorRelay<String> = BehaviorRelay(value: "")
    let userExamResults: BehaviorRelay<Int> = BehaviorRelay(value: 0)
        
    required init(soundManager: SoundManagerLogic, chosenExam: Int) {
        self.chosenExam = chosenExam
        self.soundManager = soundManager
        examStart()
        countQuestions()
        getUserExamResults()
    }
}

extension StoryModeExamViewModel: StoryModeExamViewModelLogic {
    private func countQuestions() {
        let questionsCount = questions.value.count
        let questionsCountText = "\(totalQuestionsCount - questionsCount + 1)/\(totalQuestionsCount)"
        self.questionsCount.accept(questionsCountText)
    }
    
    private func getUserExamResults() {
        let result = UserDataManager.shared.getUserResult(for: examName)
        userExamResults.accept(result)
    }
    
    func examStart() {
        var kitsForExam = [Int]()
        
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
        
        let questionsSequence = KitsManager.shared.getKitsForExam(with: kitsForExam)
            .shuffled()
            .prefix(10)
        
        questions.accept(Array(questionsSequence))
    }
    
    func exam(textField text: String?) {
        guard let text = text,
              let correctAnswer = questions.value.first?.correctAnswer else { return }
        
        let trimmedAnswer = correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedAnswer.capitalized == text.capitalized {
            correctAnswersCount += 1
            answerResult.accept(true)
        } else {
            answerResult.accept(false)
        }
    }
    
    func nextQuestion() {
        var questions = questions.value
        questions.removeFirst()
        
        if questions.isEmpty {
            let testResult = Int(round(Double(correctAnswersCount) / Double(totalQuestionsCount) * 100))
            examResult.accept(testResult)
            
            UserDataManager.shared.saveUserResult(newResult: testResult,
                                           kitName: examName,
                                           completedTests: 0,
                                           completedExams: 1,
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
