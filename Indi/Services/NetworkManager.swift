//
//  NetworkManager.swift
//  Indi
//
//  Created by Alexander Sivko on 25.05.23.
//

import Network
import RxSwift
import RxCocoa

protocol NetworkManagerDataAndLogic {
    var isConnectedToInternet: PublishRelay<Bool> { get set }
    func retrieveQuestions() -> Observable<[Question]>
}

fileprivate extension String {
    static let qustionsStringUrl = "https://api.npoint.io/83158e0ff5e7f7127d53"
}

final class NetworkManager: NetworkManagerDataAndLogic {
    // MARK: - Private
    private struct QuestionNetwork: Decodable {
        var question: String?
        var correctAnswer: String?
        var incorrectAnswers: [String]?
    }
    
    private lazy var jsonDecoder = JSONDecoder()
    private let urlSession = URLSession(configuration: .default)
        
    private func internetConnectionMonitoring() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.isConnectedToInternet.accept(true)
            } else {
                self.isConnectedToInternet.accept(false)
            }
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    private func questionsTransformation(for networkQuestions: [QuestionNetwork]) -> [Question] {
        let transformedQuestions: [Question] = networkQuestions.map { question in
            let newQuestion = KitsManager.shared.createQuestionWithoutSaving(question.question ?? "",
                                                                             question.correctAnswer ?? "",
                                                                             question.incorrectAnswers ?? [])
            return newQuestion
        }
                
        return transformedQuestions
    }
    
    //MARK: - Public
    var isConnectedToInternet = PublishRelay<Bool>()
    
    func retrieveQuestions() -> Observable<[Question]> {
        guard let url = URL(string: String.qustionsStringUrl) else { return Observable.empty() }
        
        return Observable.create { observer -> Disposable in
            self.urlSession.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                if let httpResponse = response as? HTTPURLResponse {
                    let statusCode = httpResponse.statusCode
                    
                    do {
                        guard let data = data else { return }
                        if (200...399).contains(statusCode) {
                            let questions = try self.jsonDecoder.decode([QuestionNetwork].self, from: data)
                            let result = self.questionsTransformation(for: questions)
                            observer.onNext(result)
                        } else {
                            guard let error = error else { return }
                            observer.onError(error)
                        }
                    }
                    catch {
                        observer.onError(error)
                    }
                }
                observer.onCompleted()
            }
            .resume()
            return Disposables.create()
        }
    }
    
    //MARK: - Initialization
    init() {
        internetConnectionMonitoring()
    }
}
