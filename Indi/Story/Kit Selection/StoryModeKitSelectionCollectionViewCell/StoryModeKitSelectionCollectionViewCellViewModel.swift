//
//  StoryModeKitSelectionCollectionViewCellViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 8.07.23.
//

import RxSwift
import RxCocoa

protocol StoryModeKitSelectionCollectionViewCellViewModelLogic {
    var kit: Observable<Kit> { get }
    var testResult: Observable<Int> { get }
    func countProgressHeight(with cellHeight: CGFloat, kitName: String) -> CGFloat
    init(kit: Observable<Kit>, testResult: Observable<Int>)
}

final class StoryModeKitSelectionCollectionViewCellViewModel: StoryModeKitSelectionCollectionViewCellViewModelLogic {
    let kit: Observable<Kit>
    let testResult: Observable<Int>
    
    func countProgressHeight(with cellHeight: CGFloat, kitName: String) -> CGFloat {
        var totalHeight: Double {
            Double(cellHeight)
        }
        var coefficient: Double {
            totalHeight / 100
        }
        return CGFloat(Double(UserDataManager.shared.getUserResult(for: kitName)) * coefficient)
    }
    
    required init(kit: Observable<Kit>, testResult: Observable<Int>) {
        self.kit = kit
        self.testResult = testResult
    }
}
