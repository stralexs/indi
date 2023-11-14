//
//  StoryModeKitSelectionViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 8.07.23.
//

import RxSwift
import RxCocoa

protocol StoryModeKitSelectionViewModelData {
    var kits: BehaviorRelay<[Kit]> { get }
    init(chosenStudyStage: Int)
}

protocol StoryModeKitSelectionViewModelLogic {
    func fetchKits()
    func cellViewModel(for row: Int) -> StoryModeKitSelectionCollectionViewCellViewModelLogic
    func isBasicKitCheck(for indexPath: IndexPath) -> Bool
    func deleteUserKit(for indexPath: IndexPath)
    func viewModelForTesting(_ indexPath: IndexPath) -> StoryModeTestingViewModelData & StoryModeTestingViewModelLogic
}

final class StoryModeKitSelectionViewModel: StoryModeKitSelectionViewModelData {
    private let studyStageRawValue: Int
    
    let kits: BehaviorRelay<[Kit]> = BehaviorRelay(value: [])
    
    required init(chosenStudyStage: Int) {
        self.studyStageRawValue = chosenStudyStage
        fetchKits()
    }
}

extension StoryModeKitSelectionViewModel: StoryModeKitSelectionViewModelLogic {
    func fetchKits() {
        let kits = KitsManager.shared.getKits(for: studyStageRawValue)
        self.kits.accept(kits)
    }
    
    func cellViewModel(for row: Int) -> StoryModeKitSelectionCollectionViewCellViewModelLogic {
        let kit = kits.value[row]
        let testResult = UserDataManager.shared.getUserResult(for: kit.name ?? "")
        return StoryModeKitSelectionCollectionViewCellViewModel(kit: Observable.just(kit),
                                                                testResult: Observable.just(testResult))
    }
    
    func isBasicKitCheck(for indexPath: IndexPath) -> Bool {
        return KitsManager.shared.isBasicKitCheck(for: indexPath, for: studyStageRawValue)
    }
    
    func deleteUserKit(for indexPath: IndexPath) {
        KitsManager.shared.deleteUserKit(for: indexPath, for: studyStageRawValue)
    }
    
    func viewModelForTesting(_ indexPath: IndexPath) -> StoryModeTestingViewModelData & StoryModeTestingViewModelLogic {
        return StoryModeTestingViewModel(soundManager: SoundManager(), selectedKit: indexPath, studyStage: studyStageRawValue)
    }
}
