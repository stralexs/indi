//
//  TrainingModeViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 7.07.23.
//

import Foundation

final class TrainingModeViewModel {
    func cellViewModel(for section: Int, and indexPath: IndexPath) -> TrainingModeTableViewCellViewModel? {
        let kitName = KitsManager.shared.getKitName(for: section, with: indexPath)
        return TrainingModeTableViewCellViewModel(kitName: kitName)
    }
    
    func headerInSectionName(for tableViewSection: Int) -> String {
        return StudyStage.getStudyStageName(studyStage: tableViewSection)
    }
    
    var numberOfSections: Int {
        return StudyStage.countOfStudyStages()
    }
    
    func numberOfRowsInSection(for section: Int) -> Int {
        return KitsManager.shared.countOfKits(for: section)
    }
    
    private var countOfQuestions: Int = 1
    
    func sliderMaximumValue(for indexPaths: [IndexPath]) -> Float {
        var value: Int = 0
        for index in indexPaths {
            value += KitsManager.shared.getKitForTesting(for: index[0], and: index[1]).count
        }
        return Float(value)
    }
}
