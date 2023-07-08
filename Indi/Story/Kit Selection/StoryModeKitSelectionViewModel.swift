//
//  StoryModeKitSelectionViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 8.07.23.
//

import Foundation

final class StoryModeKitSelectionViewModel {
    //MARK: - Private Variable
    private var studyStageRawValue = 0
    
    //MARK: - Public Variable
    var numberOfItemsInSection: Int {
        return KitsManager.shared.countOfKits(for: studyStageRawValue)
    }
    
    //MARK: - Private Methods
    private func createNotificationCenterObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(setStudyStage(_:)), name: Notification.Name(rawValue: chosenStudyStageNotificationKey), object: nil)
    }
    
    @objc private func setStudyStage(_ notification: NSNotification) {
        if let chosenStudyStage = notification.object as? Int {
            studyStageRawValue = chosenStudyStage
        }
    }
    
    //MARK: - Public Methods
    func cellViewModel(for indexPath: IndexPath) -> StoryModeKitSelectionCollectionViewCellViewModel? {
        let kitName = KitsManager.shared.getKitName(for: studyStageRawValue, with: indexPath)
        let testResult = UserDataManager.shared.getUserResult(for: kitName)
        return StoryModeKitSelectionCollectionViewCellViewModel(kitName: kitName, testResult: testResult)
    }
    
    func postChosenTestNotification(for indexPath: IndexPath) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: chosenTestNotificationKey), object: (indexPath, studyStageRawValue))
    }
    
    func isBasicKitCheck(for indexPath: IndexPath) -> Bool {
        return KitsManager.shared.isBasicKitCheck(for: indexPath, for: studyStageRawValue)
    }
    
    func deleteUserKit(for indexPath: IndexPath) {
        KitsManager.shared.deleteUserKit(for: indexPath, for: studyStageRawValue)
    }
    
    //MARK: - Initialization
    init() {
        createNotificationCenterObserver()
    }
}
