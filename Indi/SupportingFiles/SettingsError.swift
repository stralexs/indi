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
