//
//  NetworkNewKitViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 15.06.23.
//

import Foundation

protocol NetworkNewKitViewModelProtocol: NewKitViewModelProtocol {
    var isConnectedToInternet: Bool { get set }
    func retrieveQuestions(completion: @escaping () -> Void)
}

final class NetworkNewKitViewModel: NewKitViewModel, NetworkNewKitViewModelProtocol {
    private var networkingManager = NetworkManager()
    private func setupBinder() {
        networkingManager.isConnectedToInternet.bind {  [weak self] isConnected in
            self?.isConnectedToInternet = isConnected
        }
    }
    var isConnectedToInternet: Bool = true
    
    func retrieveQuestions(completion: @escaping () -> Void) {
        networkingManager.retrieveQuestions { [weak self] questions in
            self?.questions.value = questions
            completion()
        }
    }
    
    override init() {
        super.init()
        setupBinder()
    }
}
