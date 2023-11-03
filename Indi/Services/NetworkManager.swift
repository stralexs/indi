//
//  NetworkManager.swift
//  Indi
//
//  Created by Alexander Sivko on 25.05.23.
//

import Foundation
import Network

protocol NetworkManagerLogic {
    var isConnectedToInternet: ObservableObject<Bool> { get set }
    func retrieveQuestions(completion: @escaping ([Question]) -> ())
}

final class NetworkManager: NetworkManagerLogic {
    //MARK: - Private Properties and Methods
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
    
    private var dataFromServer: Record?
    
    private func internetConnectionMonitoring() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                self?.isConnectedToInternet.value = true
            } else {
                self?.isConnectedToInternet.value = false
            }
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    private func questionsTransformation(for networkQuestions: [QuestionNetwork]) -> [Question] {
        guard networkQuestions.isEmpty == false else { return [] }
        
        var outputQuestions: [Question] = []
        
        networkQuestions.forEach { question in
            let questionString = question.question
            let correctAnswerString = question.correctAnswer
            let incorrectAnswersString = question.incorrectAnswers
            
            let newQuestion = KitsManager.shared.createQuestionWithoutSaving(questionString!, correctAnswerString!, incorrectAnswersString!)
            
            outputQuestions.append(newQuestion)
        }
        
        return outputQuestions
    }
    
    //MARK: - Public Properties and Methods
    var isConnectedToInternet: ObservableObject<Bool> = ObservableObject(true)
        
    func retrieveQuestions(completion: @escaping ([Question]) -> ()) {
        guard let url = URL(string: "https://api.jsonbin.io/v3/b/64aac27a8e4aa6225ebb89bb") else { return completion([]) }

        let params: [String: Any] = [
            "userName": UserDataManager.shared.getUserName(),
            "userAvatar": UserDataManager.shared.getUserAvatar()
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)

        URLSession.shared.dataTask(with: url) { [self]
            data, response, error in

            guard let data = data else { return }
            
            do {
                self.dataFromServer = try JSONDecoder().decode(Record.self, from: data)
                let result = self.questionsTransformation(for: dataFromServer?.record ?? [])
                completion(result)
            }
            catch {
                print(error)
            }
        }.resume()
    }
    
    //MARK: - Initialization
    init() {
        internetConnectionMonitoring()
    }
}
