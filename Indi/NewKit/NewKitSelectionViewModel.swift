//
//  NewKitSelectionViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 11.08.23.
//

import Foundation

protocol NewKitSelectionViewModelProtocol {
    func viewModelForNetworkNewKit() -> NetworkNewKitViewModelProtocol?
    func viewModelForUserNewKit() -> UserNewKitViewModelProtocol?
}

class NewKitSelectionViewModel: NewKitSelectionViewModelProtocol {
    func viewModelForNetworkNewKit() -> NetworkNewKitViewModelProtocol? {
        return NetworkNewKitViewModel()
    }
    func viewModelForUserNewKit() -> UserNewKitViewModelProtocol? {
        return UserNewKitViewModel()
    }
}
