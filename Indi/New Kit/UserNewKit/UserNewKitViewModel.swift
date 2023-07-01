//
//  UserNewKitViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 22.05.23.
//

import Foundation
import UIKit

final class UserNewKitViewModel {
    //MARK: - Observable Objects
    var questions: ObservableObject<[Question]> = ObservableObject([])
    var newUserKitName: ObservableObject<String?> = ObservableObject("Название набора")
    var newUserKitStudyStageName: ObservableObject<String> = ObservableObject("Стадия обучения")
    
    //MARK: - Private Functions and Properties
    private var namesOfKitsOfSelectedStudyStage: [String] = []
    
    //MARK: - Public Functions and Properties
    var numberOfRows: Int? {
        return questions.value.count
    }
    var newUserKitStudyStage: Int? {
        didSet {
            if let newUserKitStudyStage = newUserKitStudyStage {
                self.namesOfKitsOfSelectedStudyStage = KitsManager.shared.getKitNamesForStudyStage(with: [newUserKitStudyStage])
                self.newUserKitStudyStageName.value = StudyStage.getStudyStageName(studyStage: newUserKitStudyStage)
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
            newUserKitName.value = newNameVar
        }
        
        return output
    }
    
    func createNewKit() -> String {
        var output = ""
        
        if newUserKitName.value == "Название набора" {
            output = "No kit name"
        } else if newUserKitStudyStage == nil {
            output = "No study stage"
        } else if questions.value.count == 0 {
            output = "No questions"
        } else if namesOfKitsOfSelectedStudyStage.contains(newUserKitName.value ?? "") {
            output = "Name already exists"
        } else if questions.value.isEmpty {
            output = "Questions not loaded"
        } else {
            KitsManager.shared.createNewKit(newUserKitName.value ?? "", newUserKitStudyStage ?? 0, questions.value)
            UserDataManager.shared.createNewUserData(for: newUserKitName.value ?? "")
        }
        
        return output
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
    
    //MARK: - Initialization
    init() {}
}
