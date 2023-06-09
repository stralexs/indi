//
//  StudyStage.swift
//  Indi
//
//  Created by Alexander Sivko on 15.06.23.
//

import Foundation

enum StudyStage: Int64, CaseIterable  {
    case newborn
    case preschool
    case earlySchool
    case highSchool
    case lifeActivities
    case programmingUniversity
    case constructionUniversity
    case sideJob
    
    static func getStudyStageName(studyStage rawValue: Int) -> String {
        var output = ""
        
        switch rawValue {
        case 0:
            output = "Newborn"
        case 1:
            output = "Preschool"
        case 2:
            output = "Early school"
        case 3:
            output = "High school"
        case 4:
            output = "Life activities"
        case 5:
            output = "Programming university"
        case 6:
            output = "Construction university"
        default:
            output = "Side jobs"
        }
        
        return output
    }
    
    static func getExamName(studyStage rawValue: Int) -> String {
        var output = ""
        
        switch rawValue {
        case 0:
            output = "Newborn exam"
        case 1:
            output = "Preschool exam"
        case 2:
            output = "Early school exam"
        case 3:
            output = "High school exam"
        default:
            output = "Final exam"
        }
        
        return output
    }
    
    static func countOfStudyStages() -> Int {
        return StudyStage.allCases.count
    }
}
