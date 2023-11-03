//
//  NetworkNewKitViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 15.06.23.
//

import Foundation
import RxSwift
import RxCocoa

protocol NetworkNewKitViewModelProtocol {
    var questions: ObservableObject<[Question]> { get set }
    var newKitName: ObservableObject<String?> { get set }
    var newKitStudyStageName: ObservableObject<String> { get set }
    var numberOfRows: Int? { get }
    var newKitStudyStage: Int? { get set }
    func cellViewModel(for indexPath: IndexPath) -> NewKitTableViewCellViewModelData?
    func newKitName(_ newName: String) -> String
    func createNewKit() -> String
    func studyStageTitleName(for studyStageRawValue: Int) -> String
    var isConnectedToInternet: Bool { get set }
    func retrieveQuestions(completion: @escaping () -> Void)
}

final class NetworkNewKitViewModel: NetworkNewKitViewModelProtocol {
    //MARK: - Observable Objects
    var questions: ObservableObject<[Question]> = ObservableObject([])
    var newKitName: ObservableObject<String?> = ObservableObject("Название набора")
    var newKitStudyStageName: ObservableObject<String> = ObservableObject("Стадия обучения")
    
    //MARK: - Private Property
    private var namesOfKitsOfSelectedStudyStage: [String] = []
    
    //MARK: - Public Properties and Methods
    var numberOfRows: Int? {
        return questions.value.count
    }
    var newKitStudyStage: Int? {
        didSet {
            if let newKitStudyStage = newKitStudyStage {
                self.namesOfKitsOfSelectedStudyStage = KitsManager.shared.getKitNamesForStudyStage(with: [newKitStudyStage])
                self.newKitStudyStageName.value = StudyStage[newKitStudyStage]
            }
        }
    }
    
    func cellViewModel(for indexPath: IndexPath) -> NewKitTableViewCellViewModelData? {
        let question = questions.value[indexPath.row]
        return NewKitTableViewCellViewModel(question: BehaviorRelay(value: question))
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
            newKitName.value = newNameVar
        }
        
        return output
    }
    
    func createNewKit() -> String {
        var output = ""
        
        if questions.value.count == 0 {
            output = "No questions"
        } else if newKitName.value == "Название набора" {
            output = "No kit name"
        } else if newKitStudyStage == nil {
            output = "No study stage"
        } else if namesOfKitsOfSelectedStudyStage.contains(newKitName.value ?? "") {
            output = "Name already exists"
        } else {
            KitsManager.shared.createNewKit(newKitName.value ?? "", newKitStudyStage ?? 0, questions.value)
            UserDataManager.shared.createNewUserData(for: newKitName.value ?? "")
        }
        
        return output
    }
    
    func studyStageTitleName(for studyStageRawValue: Int) -> String {
        return StudyStage[studyStageRawValue]
    }
    
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
    
    init() {
        setupBinder()
    }
}
