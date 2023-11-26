//
//  StoryModeKitSelectionCollectionViewCellViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 8.07.23.
//

import RxSwift
import RxCocoa

protocol StoryModeKitSelectionCollectionViewCellViewModelLogic {
    var kitName: BehaviorRelay<String> { get }
    var testResult: BehaviorRelay<Int> { get }
    var progressHeight: BehaviorRelay<CGFloat> { get }
    func countProgressHeight(with cellHeight: CGFloat)
    init(kitName: String)
}

final class StoryModeKitSelectionCollectionViewCellViewModel: StoryModeKitSelectionCollectionViewCellViewModelLogic {
    private let disposeBag = DisposeBag()
    let kitName = BehaviorRelay<String>(value: "")
    let testResult = BehaviorRelay<Int>(value: 0)
    let progressHeight = BehaviorRelay<CGFloat>(value: 0)
    
    required init(kitName: String) {
        self.kitName.accept(kitName)
        setupUserResults(kitName)
    }
}

extension StoryModeKitSelectionCollectionViewCellViewModel {
    private func setupUserResults(_ kitName: String) {
        UserDataManager.shared.userResults
            .bind(onNext: { result in
                let testResult = result[kitName] ?? 0
                self.testResult.accept(testResult)
            })
            .disposed(by: disposeBag)
    }
    
    func countProgressHeight(with cellHeight: CGFloat) {
        var totalHeight: CGFloat { CGFloat(cellHeight) }
        var coefficient: CGFloat { totalHeight / 100 }
        let kitName = self.kitName.value
        let progressHeight = CGFloat(UserDataManager.shared.userResults.value[kitName] ?? 0) * coefficient
        self.progressHeight.accept(progressHeight)
    }
}
