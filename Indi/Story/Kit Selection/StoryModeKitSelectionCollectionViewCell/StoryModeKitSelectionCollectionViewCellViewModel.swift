//
//  StoryModeKitSelectionCollectionViewCellViewModel.swift
//  Indi
//
//  Created by Alexander Strelnikov on 8.07.23.
//

import Foundation

protocol StoryModeKitSelectionCollectionViewCellViewModelProtocol {
    var kitName: String { get set }
    var testResult: Int { get set }
    var cellHeight: CGFloat? { get set }
    var progressHeight: CGFloat { get }
    init(kitName: String, testResult: Int)
}

final class StoryModeKitSelectionCollectionViewCellViewModel: StoryModeKitSelectionCollectionViewCellViewModelProtocol {
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
    
    required init(kitName: String, testResult: Int) {
        self.kitName = kitName
        self.testResult = testResult
    }
}
