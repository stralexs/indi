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

extension KitCreationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noQuestions:
            return "В наборе должен быть хотя бы один вопрос"
        case .noKitName:
            return "Пожалуйста, введите название набора слов"
        case .noStudyStage:
            return "Пожалуйста, выберите стадию обучения, в которую нужно добавить набор"
        case .nameAlreadyExists:
            return "В выбранной стадии обучения уже существует набор с таким названием. Выберите другое название"
        }
    }
}

enum KitNameError: Error {
    case empty
    case tooLong
}

extension KitNameError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .empty:
            return "Пожалуйста, введите корректное название набора"
        case .tooLong:
            return "Название набора не может быть длиннее 30 символов"
        }
    }
}

enum CreateQuestionError: Error {
    case emptyFields
    case tooManyIncorrect
    case incorrectContainsCorrect
}

extension CreateQuestionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyFields:
            return "Пожалуйста, заполняйте все поля"
        case .tooManyIncorrect:
            return "Число неправильных ответов должно быть от одного до трёх"
        case .incorrectContainsCorrect:
            return "Неправильные ответы не могут содержать правильный ответ"
        }
    }
}
