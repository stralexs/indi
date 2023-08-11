//
//  StoryModeKitSelectionViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 8.07.23.
//

import Foundation

protocol StoryModeKitSelectionViewModelProtocol {
    var numberOfItemsInSection: Int { get }
    func cellViewModel(for indexPath: IndexPath) -> StoryModeKitSelectionCollectionViewCellViewModelProtocol?
    func postChosenTestNotification(for indexPath: IndexPath)
    func isBasicKitCheck(for indexPath: IndexPath) -> Bool
    func deleteUserKit(for indexPath: IndexPath)
    func viewModelForTesting() -> StoryModeTestingViewModelProtocol?
}

final class StoryModeKitSelectionViewModel: StoryModeKitSelectionViewModelProtocol {
    //MARK: - Private Variable
    private var studyStageRawValue = 0
    
    //MARK: - Public Variable
    var numberOfItemsInSection: Int {
        return KitsManager.shared.countOfKits(for: studyStageRawValue)
    }
    
    //MARK: - Private Methods
    private func createNotificationCenterObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(setStudyStage(_:)), name: Notification.Name(rawValue: "com.indi.chosenStudyStage.notificationKey"), object: nil)
    }
    
    @objc private func setStudyStage(_ notification: NSNotification) {
        if let chosenStudyStage = notification.object as? Int {
            studyStageRawValue = chosenStudyStage
        }
    }
    
    //MARK: - Public Methods
    func cellViewModel(for indexPath: IndexPath) -> StoryModeKitSelectionCollectionViewCellViewModelProtocol? {
        let kitName = KitsManager.shared.getKitName(for: studyStageRawValue, with: indexPath)
        let testResult = UserDataManager.shared.getUserResult(for: kitName)
        return StoryModeKitSelectionCollectionViewCellViewModel(kitName: kitName, testResult: testResult)
    }
    
    func postChosenTestNotification(for indexPath: IndexPath) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "com.indi.chosenTest.notificationKey"), object: (indexPath, studyStageRawValue))
    }
    
    func isBasicKitCheck(for indexPath: IndexPath) -> Bool {
        return KitsManager.shared.isBasicKitCheck(for: indexPath, for: studyStageRawValue)
    }
    
    func deleteUserKit(for indexPath: IndexPath) {
        KitsManager.shared.deleteUserKit(for: indexPath, for: studyStageRawValue)
    }
    
    func viewModelForTesting() -> StoryModeTestingViewModelProtocol? {
        return StoryModeTestingViewModel(soundManager: SoundManager())
    }
    
    //MARK: - Initialization
    init() {
        createNotificationCenterObserver()
    }
}
