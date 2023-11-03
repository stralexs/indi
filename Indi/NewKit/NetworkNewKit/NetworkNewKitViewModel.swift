//
//  NetworkNewKitViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 15.06.23.
//

import RxSwift
import RxCocoa

protocol NetworkNewKitViewModelData {
    var questions: BehaviorRelay<[Question]> { get set }
    var newKitName: BehaviorRelay<String> { get set }
    var newKitStudyStageName: BehaviorRelay<String> { get set }
    var newKitStudyStage: BehaviorRelay<Int?> { get set }
    var isConnectedToInternet: BehaviorRelay<Bool?> { get set }
}

protocol NetworkNewKitViewModelLogic {
    func cellViewModel(for row: Int) -> NewKitTableViewCellViewModelData
    func newKitName(_ newName: String) throws
    func createNewKit() throws
    func retrieveQuestions(completion: @escaping () -> Void)
}

final class NetworkNewKitViewModel: NetworkNewKitViewModelData {
    var questions: BehaviorRelay<[Question]> = BehaviorRelay(value: [])
    var newKitName: BehaviorRelay<String> = BehaviorRelay(value: "Название набора")
    var newKitStudyStageName: BehaviorRelay<String> = BehaviorRelay(value: "Стадия обучения")
    var newKitStudyStage: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    var isConnectedToInternet: BehaviorRelay<Bool?> = BehaviorRelay(value: nil)
    
    private let disposeBag = DisposeBag()
    private let networkManager: NetworkManagerLogic
    private var namesOfKitsOfSelectedStudyStage = [String]()
    
    init(networkManager: NetworkManagerLogic) {
        self.networkManager = networkManager
        setupBinder()
        bindToNewKitStudyStage()
    }
}

extension NetworkNewKitViewModel: NetworkNewKitViewModelLogic {
    private func bindToNewKitStudyStage() {
        newKitStudyStage.bind { name in
            guard let name = name else { return }
            self.namesOfKitsOfSelectedStudyStage = KitsManager.shared.getKitNamesForStudyStage(with: [name])
            self.newKitStudyStageName.accept(StudyStage[name])
        }
        .disposed(by: disposeBag)
    }
    
    private func setupBinder() {
        networkManager.isConnectedToInternet.bind {  [weak self] isConnected in
            self?.isConnectedToInternet.accept(isConnected)
        }
    }
    
    func cellViewModel(for row: Int) -> NewKitTableViewCellViewModelData {
        let question = questions.value[row]
        return NewKitTableViewCellViewModel(question: BehaviorRelay(value: question))
    }
    
    func newKitName(_ newName: String) throws {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName == "" {
            throw KitNameError.empty
        } else if trimmedName.count > 30 {
            throw KitNameError.tooLong
        } else {
            newKitName.accept(trimmedName)
        }
    }
    
    func createNewKit() throws {
        if questions.value.count == 0 {
            throw KitCreationError.noQuestions
        } else if newKitName.value == "Название набора" {
            throw KitCreationError.noKitName
        } else if newKitStudyStage.value == nil {
            throw KitCreationError.noStudyStage
        } else if namesOfKitsOfSelectedStudyStage.contains(newKitName.value) {
            throw KitCreationError.nameAlreadyExists
        } else {
            KitsManager.shared.createNewKit(newKitName.value, newKitStudyStage.value ?? 0, questions.value)
            UserDataManager.shared.createNewUserData(for: newKitName.value)
        }
    }
    
    func retrieveQuestions(completion: @escaping () -> Void) {
        networkManager.retrieveQuestions { [weak self] questions in
            self?.questions.accept(questions)
            completion()
        }
    }
}
