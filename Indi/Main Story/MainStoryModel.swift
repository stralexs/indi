//
//  MainStoryModel.swift
//  Indi
//
//  Created by Alexander Sivko on 25.05.23.
//

import Foundation

class MainStoryModel {
    func examAccessControl(for senderRawValue: Int) -> Bool {
        var result: Bool = true
                
        func isHigherThanSeventyFilter(for studyStages: [Int]) -> Bool {
            var output: Bool = true
            
            let kitNames = KitsLibrary.shared.getKitNamesForStudyStage(with: studyStages)
            var userResults: [Int] = []
            kitNames.forEach { name in
                userResults.append(UserData.shared.getUserResult(for: name))
            }
            let filteredResult = userResults.filter { $0 >= 70 }
            
            output = filteredResult.count == userResults.count ? true : false
            return output
        }
        
        switch senderRawValue {
        case 0:
            result = isHigherThanSeventyFilter(for: [0])
        case 1:
            result = isHigherThanSeventyFilter(for: [1])
        case 2:
            result = isHigherThanSeventyFilter(for: [2])
        case 3:
            result = isHigherThanSeventyFilter(for: [3,4])
        default:
            if UserData.shared.getSelectedStages() == [] {
                result = isHigherThanSeventyFilter(for: [5,6,7])
            } else {
                result = isHigherThanSeventyFilter(for: UserData.shared.getSelectedStages())
            }
        }
        
        return result
    }
    
    func studyStageAccessControl(for senderTag: Int) -> Bool {
        var result: Bool = true
        
        switch senderTag {
        case 0:
            result = true
        case 1:
            result = UserData.shared.getUserResult(for: "Newborn exam") >= 50 ? true : false
        case 2:
            result = UserData.shared.getUserResult(for: "Preschool exam") >= 50 ? true : false
        case 3,4:
            result = UserData.shared.getUserResult(for: "Early school exam") >= 50 ? true : false
        default:
            result = UserData.shared.getUserResult(for: "High school exam") >= 50 ? true : false
        }
        
        return result
    }
    
    init() {}
}
