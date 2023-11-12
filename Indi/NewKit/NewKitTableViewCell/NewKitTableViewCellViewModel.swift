//
//  NetworkNewKitTableViewCellViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 15.06.23.
//

import RxSwift
import RxCocoa

protocol NewKitTableViewCellViewModelData {
    var question: Observable<Question> { get }
    init(question: Observable<Question>)
}

final class NewKitTableViewCellViewModel: NewKitTableViewCellViewModelData {
    let question: Observable<Question>
    
    required init(question: Observable<Question>) {
        self.question = question
    }
}
