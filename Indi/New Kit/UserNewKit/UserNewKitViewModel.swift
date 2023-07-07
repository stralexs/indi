//
//  UserNewKitViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 22.05.23.
//

import Foundation
import UIKit

final class UserNewKitViewModel: NewKitViewModel {
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
