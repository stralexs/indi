//
//  NetworkNewKitTableViewCellViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 15.06.23.
//

import RxSwift
import RxCocoa

protocol NewKitTableViewCellViewModelData {
    var question: Observable<Question> { get set }
    init(question: Observable<Question>)
}

final class NewKitTableViewCellViewModel: NewKitTableViewCellViewModelData {
    var question: Observable<Question>
    
    required init(question: Observable<Question>) {
        self.question = question
    }
}
