//
//  NetworkNewKitTableViewCellViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 15.06.23.
//

import RxSwift
import RxCocoa

protocol NewKitTableViewCellViewModelData {
    var question: BehaviorRelay<Question> { get set }
    init(question: BehaviorRelay<Question>)
}

final class NewKitTableViewCellViewModel: NewKitTableViewCellViewModelData {
    var question: BehaviorRelay<Question>
    
    required init(question: BehaviorRelay<Question>) {
        self.question = question
    }
}
