//
//  NetworkingTableViewCellViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 15.06.23.
//

import Foundation

final class NetworkTableViewCellViewModel {
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
    
    init(question: ObservableObject<Question>) {
        self.question = question
    }
}
