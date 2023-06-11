//
//  NetworkingModel.swift
//  Indi
//
//  Created by Alexander Sivko on 25.05.23.
//

import Foundation

class NetworkingModel {
    private struct Record: Codable {
        var record: [QuestionNetwork]
    }
    
    private struct QuestionNetwork: Codable {
        var question: String?
        var correctAnswer: String?
        var incorrectAnswers: [String]?
        
        enum CodingKeys: String, CodingKey {
            case question = "question"
            case correctAnswer = "correct_Answer"
            case incorrectAnswers = "incorrect_Answers"
        }
    }
    
    var newNetworkKitName: String?
    var newNetworkKitStudyStage: Int?
    
    func createNewKit() {
        KitsLibrary.shared.createNewKit(newNetworkKitName!, newNetworkKitStudyStage!, questions)
        UserData.shared.createNewUserData(for: newNetworkKitName!)
    }
    
    func removingSpaces(for text: String) -> String {
        var outputText = text
        
        while outputText.first == " " {
            outputText.removeFirst()
        }
        while outputText.last == " " {
            outputText.removeLast()
        }
        
        return outputText
    }
    
    private var dataFromServer: Record?
    private var questions: [Question] = []
        
    func retrieveQuestions(completion: @escaping ([Question]) -> ()) {
        guard let url = URL(string: "https://api.jsonbin.io/v3/b/646f796b8e4aa6225ea40151") else { return completion([]) }

        let params: [String: Any] = [
            "userName": UserData.shared.getUserName(),
            "userAvatar": UserData.shared.getUserAvatar()
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)

        URLSession.shared.dataTask(with: url) { [self]
            data, response, error in

            guard let data = data else {
                if let error = error as? URLError, error.code == URLError.Code.notConnectedToInternet {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: noInternetConnectionNotificationKey), object: nil)
                }
                return
            }

            do {
                self.dataFromServer = try JSONDecoder().decode(Record.self, from: data)
                let result = self.questionsTransformation(for: dataFromServer?.record ?? [])
                questions = result
                
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            catch {
                print(error)
            }
        }.resume()
    }
    
    private func questionsTransformation(for networkQuestions: [QuestionNetwork]) -> [Question] {
        guard networkQuestions.isEmpty == false else { return [] }
        
        var outputQuestions: [Question] = []
        
        networkQuestions.forEach { question in
            let questionString = question.question
            let correctAnswerString = question.correctAnswer
            let incorrectAnswersString = question.incorrectAnswers
            
            let newQuestion = KitsLibrary.shared.createQuestionWithoutSaving(questionString!, correctAnswerString!, incorrectAnswersString!)
            
            outputQuestions.append(newQuestion)
        }
        
        return outputQuestions
    }
    
    init() {}
}
