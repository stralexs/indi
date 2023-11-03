//
//  NewKitErrors.swift
//  Indi
//
//  Created by Alexander Sivko on 2.11.23.
//

import Foundation

enum KitCreationError: Error {
    case noQuestions
    case noKitName
    case noStudyStage
    case nameAlreadyExists
}

enum KitNameError: Error {
    case empty
    case tooLong
}

enum CreateQuestionError: Error {
    case emptyFields
    case tooManyIncorrect
    case incorrectContainsCorrect
}
