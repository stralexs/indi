//
//  NetworkNewKitViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 15.06.23.
//

import Foundation

final class NetworkNewKitViewModel {
    //MARK: - Observable Objects
    var questions: ObservableObject<[Question]> = ObservableObject([])
    var newNetworkKitName: ObservableObject<String?> = ObservableObject("Название набора")
    var newNetworkKitStudyStageName: ObservableObject<String> = ObservableObject("Стадия обучения")
    
    //MARK: - Private Functions and Properties
    private var networkingManager = NetworkManager()
    private var namesOfKitsOfSelectedStudyStage: [String] = []
    private func setupBinder() {
        networkingManager.isConnectedToInternet.bind {  [weak self] isConnected in
            self?.isConnectedToInternet = isConnected
        }
    }
    
    //MARK: - Public Functions and Properties
    var numberOfRows: Int? {
        return questions.value.count
    }
    var isConnectedToInternet: Bool = true
    var newNetworkKitStudyStage: Int? {
        didSet {
            if let newNetworkKitStudyStage = newNetworkKitStudyStage {
                self.namesOfKitsOfSelectedStudyStage = KitsManager.shared.getKitNamesForStudyStage(with: [newNetworkKitStudyStage])
                self.newNetworkKitStudyStageName.value = StudyStage.getStudyStageName(studyStage: newNetworkKitStudyStage)
            }
        }
    }
    
    func retrieveQuestions(completion: @escaping () -> Void) {
        networkingManager.retrieveQuestions { [weak self] questions in
            self?.questions.value = questions
            completion()
        }
    }

    func cellViewModel(for indexPath: IndexPath) -> NewKitTableViewCellViewModel? {
        let question = questions.value[indexPath.row]
        return NewKitTableViewCellViewModel(question: ObservableObject(question))
    }

    func newKitName(_ newName: String) -> String {
        var newNameVar = newName
        
        while newNameVar.first == " " {
            newNameVar.removeFirst()
        }
        while newNameVar.last == " " {
            newNameVar.removeLast()
        }
        
        var output = ""
        if newNameVar == "" {
            output = "Empty"
        } else if newNameVar.count > 30 {
            output = "Too long"
        } else {
            newNetworkKitName.value = newNameVar
        }
        
        return output
    }
    
    func createNewKit() -> String {
        var output = ""
        
        if newNetworkKitName.value == "Название набора" {
            output = "No kit name"
        } else if newNetworkKitStudyStage == nil {
            output = "No study stage"
        } else if namesOfKitsOfSelectedStudyStage.contains(newNetworkKitName.value ?? "") {
            output = "Name already exists"
        } else if questions.value.isEmpty {
            output = "Questions not loaded"
        } else {
            KitsManager.shared.createNewKit(newNetworkKitName.value ?? "", newNetworkKitStudyStage ?? 0, questions.value)
            UserDataManager.shared.createNewUserData(for: newNetworkKitName.value ?? "")
        }
        
        return output
    }
    
    //MARK: - Initialization
    init() {
        setupBinder()
    }
}
