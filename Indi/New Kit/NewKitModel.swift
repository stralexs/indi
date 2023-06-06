//
//  NewKitModel.swift
//  Indi
//
//  Created by Alexander Sivko on 22.05.23.
//

import Foundation
import UIKit

class NewKitModel {
    var newKitName: String?
    var newKitStage: Int?
    
    private var newQuestions: [Question] = []
    
    func getQuestion(for indexPath: IndexPath) -> Question {
        return newQuestions[indexPath.row]
    }
    
    func getQuestionsCount() -> Int {
        return newQuestions.count
    }
    
    func createNewKit() {
        KitsLibrary.shared.createNewKit(newKitName!, newKitStage!, newQuestions)
        UserData.shared.createNewUserData(for: newKitName!)
        
        newQuestions.removeAll()
    }
    
    func addNewQuestion(_ question: String, _ correctAnswer: String, _ incorrectAnswers: [String]) {
        let result = KitsLibrary.shared.createQuestionWithoutSaving(question, correctAnswer, incorrectAnswers)
        newQuestions.append(result)
    }
    
    func splitOfIncorrectAnswers(_ incorrectAnswers: String) -> [String] {
        let splitText = incorrectAnswers.split(separator: ",")
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
        
        var outputArr: [String] = []
        
        splitTextVar.forEach { answer in
            outputArr.append(String(answer))
        }
        
        if outputArr.count == 1 {
            outputArr.append("")
            outputArr.append("")
        } else if outputArr.count == 2 {
            outputArr.append("")
        }
        
        return outputArr
    }
    
    init() {}
}
