//
//  NetworkNewKitTableViewCellViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 15.06.23.
//

import Foundation

protocol NewKitTableViewCellViewModelProtocol {
    var question: ObservableObject<Question> { get set }
    var questionText: String? { get }
    var correctAnswerText: String? { get }
    var firstIncorrectAnswerText: String? { get }
    var secondIncorrectAnswerText: String? { get }
    var thirdIncorrectAnswerText: String? { get }
    init(question: ObservableObject<Question>)
}

final class NewKitTableViewCellViewModel: NewKitTableViewCellViewModelProtocol {
    var question: ObservableObject<Question>

    var questionText: String? {
        return question.value.question
    }
    var correctAnswerText: String? {
        return question.value.correctAnswer
    }
    var firstIncorrectAnswerText: String? {
        return question.value.incorrectAnswers?[0]
    }
    var secondIncorrectAnswerText: String? {
        return question.value.incorrectAnswers?[1]
    }
    var thirdIncorrectAnswerText: String? {
        return question.value.incorrectAnswers?[2]
    }
    
    required init(question: ObservableObject<Question>) {
        self.question = question
    }
}
