//
//  TrainingModeViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 7.07.23.
//

import Foundation

protocol TrainingModeViewModelProtocol {
    var numberOfSections: Int { get }
    var userSettingsForTraining: ([IndexPath], Int)? { get set }
    func cellViewModel(for section: Int, and indexPath: IndexPath) -> TrainingModeTableViewCellViewModel?
    func headerInSectionName(for tableViewSection: Int) -> String
    func numberOfRowsInSection(for section: Int) -> Int
    func sliderMaximumValue(for indexPaths: [IndexPath]) -> Float
    func isBasicKitCheck(for indexPath: IndexPath, for indexPathSection: Int) -> Bool
    func deleteUserKit(for indexPath: IndexPath, for indexPathSection: Int)
    func viewModelForTrainingModeTesting() -> TrainingModeTestingViewModelProtocol?
}

final class TrainingModeViewModel: TrainingModeViewModelProtocol {
    var numberOfSections: Int {
        return StudyStage.countOfStudyStages
    }
    
    var userSettingsForTraining: ([IndexPath], Int)? {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: chosenTrainingNotificationKey), object: userSettingsForTraining)
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
    
    func sliderMaximumValue(for indexPaths: [IndexPath]) -> Float {
        var value: Int = 0
        for index in indexPaths {
            value += KitsManager.shared.getKitForTesting(for: index[0], and: index[1]).count
        }
        return Float(value)
    }
    
    func isBasicKitCheck(for indexPath: IndexPath, for indexPathSection: Int) -> Bool {
        return KitsManager.shared.isBasicKitCheck(for: indexPath, for: indexPathSection)
    }
    
    func deleteUserKit(for indexPath: IndexPath, for indexPathSection: Int) {
        KitsManager.shared.deleteUserKit(for: indexPath, for: indexPathSection)
    }
    
    func viewModelForTrainingModeTesting() -> TrainingModeTestingViewModelProtocol? {
        return TrainingModeTestingViewModel()
    }
}
