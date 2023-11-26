//
//  StudyStage.swift
//  Indi
//
//  Created by Alexander Sivko on 15.06.23.
//

import Foundation

enum StudyStage: Int64, CaseIterable {
    case newborn
    case preschool
    case earlySchool
    case highSchool
    case lifeActivities
    case programmingUniversity
    case constructionUniversity
    case sideJob
    
    static subscript(studyStageRawValue: Int) -> String {
        switch studyStageRawValue {
        case 0:
            return "Newborn"
        case 1:
            return "Preschool"
        case 2:
            return "Early school"
        case 3:
            return "High school"
        case 4:
            return "Life activities"
        case 5:
            return "Programming university"
        case 6:
            return "Construction university"
        default:
            return "Side jobs"
        }
    }
    
    static func getExamName(studyStage rawValue: Int) -> String {
        switch rawValue {
        case 0:
            return "Newborn exam"
        case 1:
            return "Preschool exam"
        case 2:
            return "Early school exam"
        case 3:
            return "High school exam"
        default:
            return "Final exam"
        }
    }
    
    static var countOfStudyStages: Int {
        return StudyStage.allCases.count
    }
}
