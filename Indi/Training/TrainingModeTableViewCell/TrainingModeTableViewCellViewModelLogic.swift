//
//  TrainingModeTableViewCellViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 7.07.23.
//

import RxSwift
import RxCocoa

protocol TrainingModeTableViewCellViewModelLogic {
    var kitName: Observable<String> { get set }
    init(kitName: Observable<String>)
}

final class TrainingModeTableViewCellViewModel: TrainingModeTableViewCellViewModelLogic {
    var kitName: Observable<String>
        
    required init(kitName: Observable<String>) {
        self.kitName = kitName
    }
}
