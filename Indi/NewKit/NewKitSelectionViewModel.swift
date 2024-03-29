//
//  NewKitSelectionViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 11.08.23.
//

import Foundation

protocol NewKitSelectionViewModelLogic {
    func viewModelForNetworkNewKit() -> NetworkNewKitViewModelData & NetworkNewKitViewModelLogic
    func viewModelForUserNewKit() -> UserNewKitViewModelData & UserNewKitViewModelLogic
}

class NewKitSelectionViewModel: NewKitSelectionViewModelLogic {
    func viewModelForNetworkNewKit() -> NetworkNewKitViewModelData & NetworkNewKitViewModelLogic {
        return NetworkNewKitViewModel(networkManager: NetworkManager())
    }
    func viewModelForUserNewKit() -> UserNewKitViewModelData & UserNewKitViewModelLogic {
        return UserNewKitViewModel()
    }
}
