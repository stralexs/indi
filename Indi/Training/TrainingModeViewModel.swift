//
//  TrainingModeViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 7.07.23.
//

import RxSwift
import RxCocoa

protocol TrainingModeViewModelProtocol {
    var numberOfSections: Int { get }
    var sliderMaximumValue: BehaviorRelay<Float> { get set }
    var userSettingsForTraining: ([IndexPath], Int)? { get set }
    func cellViewModel(for section: Int, and indexPath: IndexPath) -> TrainingModeTableViewCellViewModel?
    func headerInSectionName(for tableViewSection: Int) -> String
    func numberOfRowsInSection(for section: Int) -> Int
    func sliderMaximumValue(for indexPaths: [IndexPath])
    func isBasicKitCheck(for indexPath: IndexPath, for indexPathSection: Int) -> Bool
    func deleteUserKit(for indexPath: IndexPath, for indexPathSection: Int)
    func viewModelForTrainingModeTesting() -> TrainingModeTestingViewModelProtocol?
}

final class TrainingModeViewModel: TrainingModeViewModelProtocol {
    var sliderMaximumValue: BehaviorRelay<Float> = BehaviorRelay(value: 0)
    
    func sliderMaximumValue(for indexPaths: [IndexPath]) {
        let questionsCount = indexPaths.map { Float(KitsManager.shared.getKitForTesting(for: $0[0], and: $0[1]).count) }
            .reduce(0) { $0 + $1 }
        sliderMaximumValue.accept(questionsCount)
    }
    
    var numberOfSections: Int {
        return StudyStage.countOfStudyStages
    }
    
    var userSettingsForTraining: ([IndexPath], Int)? {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "com.indi.chosenTraining.notificationKey"), object: userSettingsForTraining)
        }
    }
    
    func cellViewModel(for section: Int, and indexPath: IndexPath) -> TrainingModeTableViewCellViewModel? {
        let kitName = KitsManager.shared.getKitName(for: section, with: indexPath)
        return TrainingModeTableViewCellViewModel(kitName: kitName)
    }
    
    func headerInSectionName(for tableViewSection: Int) -> String {
        return StudyStage[tableViewSection]
    }
    
    func numberOfRowsInSection(for section: Int) -> Int {
        return KitsManager.shared.countOfKits(for: section)
    }
    
    func isBasicKitCheck(for indexPath: IndexPath, for indexPathSection: Int) -> Bool {
        return KitsManager.shared.isBasicKitCheck(for: indexPath, for: indexPathSection)
    }
    
    func deleteUserKit(for indexPath: IndexPath, for indexPathSection: Int) {
        KitsManager.shared.deleteUserKit(for: indexPath, for: indexPathSection)
    }
    
    func viewModelForTrainingModeTesting() -> TrainingModeTestingViewModelProtocol? {
        return TrainingModeTestingViewModel(soundManager: SoundManager())
    }
}
