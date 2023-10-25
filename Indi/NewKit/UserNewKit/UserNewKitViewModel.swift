//
//  UserNewKitViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 22.05.23.
//

import UIKit

protocol UserNewKitViewModelProtocol {
    var questions: ObservableObject<[Question]> { get set }
    var newKitName: ObservableObject<String?> { get set }
    var newKitStudyStageName: ObservableObject<String> { get set }
    var numberOfRows: Int? { get }
    var newKitStudyStage: Int? { get set }
    func cellViewModel(for indexPath: IndexPath) -> NewKitTableViewCellViewModelProtocol?
    func newKitName(_ newName: String) -> String
    func createNewKit() -> String
    func studyStageTitleName(for studyStageRawValue: Int) -> String
    func createNewQuestion(_ firstTextFieldText: String, _ secondTextFieldText: String, _ thirdTextFieldText: String) -> String
}

final class UserNewKitViewModel: UserNewKitViewModelProtocol {
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
    
    func cellViewModel(for indexPath: IndexPath) -> NewKitTableViewCellViewModelProtocol? {
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
    
    func createNewQuestion(_ firstTextFieldText: String, _ secondTextFieldText: String, _ thirdTextFieldText: String) -> String {
        //First TextField
        var firstTextFieldTextVar = firstTextFieldText
        while firstTextFieldTextVar.first == " " {
            firstTextFieldTextVar.removeFirst()
        }
        while firstTextFieldTextVar.last == " " {
            firstTextFieldTextVar.removeLast()
        }
        
        //Second TextField
        var secondTextFieldTextVar = secondTextFieldText
        while secondTextFieldTextVar.first == " " {
            secondTextFieldTextVar.removeFirst()
        }
        while secondTextFieldTextVar.last == " " {
            secondTextFieldTextVar.removeLast()
        }
        
        //Third TextField
        let splitText = thirdTextFieldText.split(separator: ",")
        var splitTextVar = splitText
        
        var index = 0
        splitText.forEach { _ in
            while splitTextVar[index].first == " " {
                splitTextVar[index].removeFirst()
            }
            while splitTextVar[index].last == " " {
                splitTextVar[index].removeLast()
            }
            index += 1
        }
        
        var incorrectAnswersArr: [String] = []
        
        splitTextVar.forEach { answer in
            incorrectAnswersArr.append(String(answer))
        }
        
        if incorrectAnswersArr.count == 1 {
            incorrectAnswersArr.append("")
            incorrectAnswersArr.append("")
        } else if incorrectAnswersArr.count == 2 {
            incorrectAnswersArr.append("")
        }
                
        var output = ""
        if firstTextFieldTextVar == "" || secondTextFieldTextVar == "" || thirdTextFieldText == "" || incorrectAnswersArr == ["", "", ""] || incorrectAnswersArr.isEmpty {
            output = "Empty fields"
        } else if incorrectAnswersArr.count > 3 {
            output = "Too many incorrect"
        } else if incorrectAnswersArr.contains(secondTextFieldTextVar) {
            output = "Incorrect contain correct"
        } else {
            let newQuestion = KitsManager.shared.createQuestionWithoutSaving(firstTextFieldTextVar, secondTextFieldTextVar, incorrectAnswersArr)
            questions.value.append(newQuestion)
        }
        
        return output
    }
}
