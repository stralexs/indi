//
//  TrainingModeTableViewCellViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 7.07.23.
//

import RxSwift
import RxCocoa

protocol TrainingModeTableViewCellViewModelLogic {
    var kitName: Observable<String> { get }
    init(kitName: Observable<String>)
}

final class TrainingModeTableViewCellViewModel: TrainingModeTableViewCellViewModelLogic {
    let kitName: Observable<String>
        
    required init(kitName: Observable<String>) {
        self.kitName = kitName
    }
}
