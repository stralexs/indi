//
//  UserNewKitViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 22.05.23.
//

import RxSwift
import RxCocoa

protocol UserNewKitViewModelData {
    var questions: BehaviorRelay<[Question]> { get set }
    var newKitName: BehaviorRelay<String> { get set }
    var newKitStudyStageName: BehaviorRelay<String> { get set }
    var newKitStudyStage: BehaviorRelay<Int?> { get set }
}

protocol UserNewKitViewModelLogic {
    func cellViewModel(for row: Int) -> NewKitTableViewCellViewModelData
    func newKitName(_ newName: String) throws
    func createNewKit() throws
    func createNewQuestion(_ firstTextFieldText: String, _ secondTextFieldText: String, _ thirdTextFieldText: String) throws
}

final class UserNewKitViewModel: UserNewKitViewModelData {
    var questions: BehaviorRelay<[Question]> = BehaviorRelay(value: [])
    var newKitName: BehaviorRelay<String> = BehaviorRelay(value: "Название набора")
    var newKitStudyStageName: BehaviorRelay<String> = BehaviorRelay(value: "Стадия обучения")
    var newKitStudyStage: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    
    private let disposeBag = DisposeBag()
    private var namesOfKitsOfSelectedStudyStage = [String]()
    
    init() {
        bindToNewKitStudyStage()
    }
}

extension UserNewKitViewModel: UserNewKitViewModelLogic {
    private func bindToNewKitStudyStage() {
        newKitStudyStage.bind { name in
            guard let name = name else { return }
            self.namesOfKitsOfSelectedStudyStage = KitsManager.shared.getKitNamesForStudyStage(with: [name])
            self.newKitStudyStageName.accept(StudyStage[name])
        }
        .disposed(by: disposeBag)
    }
    
    func cellViewModel(for row: Int) -> NewKitTableViewCellViewModelData {
        let question = questions.value[row]
        return NewKitTableViewCellViewModel(question: Observable.just(question))
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
    
    func createNewQuestion(_ firstTextFieldText: String, _ secondTextFieldText: String, _ thirdTextFieldText: String) throws {
        let trimmedFirstText = firstTextFieldText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSecondText = secondTextFieldText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let splitText = thirdTextFieldText.split(separator: ",")
        var incorrectAnswers: [String] = splitText.map {
            let trimmedText = $0.trimmingCharacters(in: .whitespacesAndNewlines)
            return String(trimmedText)
        }
        
        if incorrectAnswers.count == 1 {
            incorrectAnswers += ["", ""]
        } else if incorrectAnswers.count == 2 {
            incorrectAnswers += [""]
        }
                
        if trimmedFirstText == "" || trimmedSecondText == "" || thirdTextFieldText == "" || incorrectAnswers == ["", "", ""] || incorrectAnswers.isEmpty {
            throw CreateQuestionError.emptyFields
        } else if incorrectAnswers.count > 3 {
            throw CreateQuestionError.tooManyIncorrect
        } else if incorrectAnswers.contains(trimmedSecondText) {
            throw CreateQuestionError.incorrectContainsCorrect
        } else {
            let newQuestion = KitsManager.shared.createQuestionWithoutSaving(trimmedFirstText,
                                                                             trimmedSecondText,
                                                                             incorrectAnswers)
            let newValue = questions.value + [newQuestion]
            questions.accept(newValue)
        }
    }
}
