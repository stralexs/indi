//
//  SettingsError.swift
//  Indi
//
//  Created by Alexander Sivko on 14.11.23.
//

import Foundation

enum SettingsError: Error {
    case emptyName
    case tooLongName
    case changesOverZero
}

extension SettingsError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Пожалуйста, введите имя"
        case .tooLongName:
            return "Имя не может быть длиннее 15 символов"
        case .changesOverZero:
            return "Изменения успешно сохранены!"
        }
    }
}
