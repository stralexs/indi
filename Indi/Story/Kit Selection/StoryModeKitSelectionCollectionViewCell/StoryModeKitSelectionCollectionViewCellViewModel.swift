//
//  StoryModeKitSelectionCollectionViewCellViewModel.swift
//  Indi
//
//  Created by Alexander Strelnikov on 8.07.23.
//

import Foundation

final class StoryModeKitSelectionCollectionViewCellViewModel {
    var kitName: String
    var testResult: Int
    var cellHeight: CGFloat?
    var progressHeight: CGFloat {
        var totalHeight: Double {
            Double(cellHeight!)
        }
        var coefficient: Double {
            totalHeight / 100
        }
        return CGFloat(Double(UserDataManager.shared.getUserResult(for: kitName)) * coefficient)
    }
    
    init(kitName: String, testResult: Int) {
        self.kitName = kitName
        self.testResult = testResult
    }
}
