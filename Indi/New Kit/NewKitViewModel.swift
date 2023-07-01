//
//  NewKitViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 1.07.23.
//

import Foundation

class NewKitViewModel {
    //MARK: - Observable Objects
    var questions: ObservableObject<[Question]> = ObservableObject([])
    var newKitName: ObservableObject<String?> = ObservableObject("Название набора")
    var newKitStudyStageName: ObservableObject<String> = ObservableObject("Стадия обучения")
    
    //MARK: - Private Property
    private var namesOfKitsOfSelectedStudyStage: [String] = []
    
    //MARK: - Public Functions and Properties
    var numberOfRows: Int? {
        return questions.value.count
    }
    var newKitStudyStage: Int? {
        didSet {
            if let newUserKitStudyStage = newKitStudyStage {
                self.namesOfKitsOfSelectedStudyStage = KitsManager.shared.getKitNamesForStudyStage(with: [newUserKitStudyStage])
                self.newKitStudyStageName.value = StudyStage.getStudyStageName(studyStage: newUserKitStudyStage)
            }
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
            newKitName.value = newNameVar
        }
        
        return output
    }
    
    func createNewKit() -> String {
        var output = ""
        
        if newKitName.value == "Название набора" {
            output = "No kit name"
        } else if newKitStudyStage == nil {
            output = "No study stage"
        } else if questions.value.count == 0 {
            output = "No questions"
        } else if namesOfKitsOfSelectedStudyStage.contains(newKitName.value ?? "") {
            output = "Name already exists"
        } else if questions.value.isEmpty {
            output = "Questions not loaded"
        } else {
            KitsManager.shared.createNewKit(newKitName.value ?? "", newKitStudyStage ?? 0, questions.value)
            UserDataManager.shared.createNewUserData(for: newKitName.value ?? "")
        }
        
        return output
    }
    
    //MARK: - Initialization
    init() {}
}
