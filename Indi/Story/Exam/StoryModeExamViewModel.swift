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
        UserDataManager.shared.userResults
            .bind { results in
                let result = results[self.examName] ?? 0
                self.userExamResults.accept(result)
            }
            .disposed(by: DisposeBag())
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
                
        let questionsForExam = kitsForExam.map { kitForExam in
            let studyStageKits = KitsManager.shared.kits.value.filter { $0.studyStage == kitForExam }
            let studyStageQuestions = studyStageKits.map { $0.questions?.allObjects as! [Question] }
                .flatMap { $0 }
            return studyStageQuestions
        }
        
        let questionsSequence = questionsForExam.flatMap { $0 }
            .shuffled()
            .prefix(10)
        
        questions.accept(Array(questionsSequence))
        countQuestions()
        getUserExamResults()
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
            let examResult = Int(round(Double(correctAnswersCount) / Double(totalQuestionsCount) * 100))
            self.examResult.accept(examResult)
            
            UserDataManager.shared.saveUserResult(newResult: examResult,
                                           kitName: examName,
                                           completedTests: 0,
                                           completedExams: 1,
                                           correctAnswers: correctAnswersCount,
                                           totalQuestions: totalQuestionsCount)
            
            if examResult >= 50 {
                UserDataManager.shared.saveExamCompletion(for: examName)
            }
            
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
