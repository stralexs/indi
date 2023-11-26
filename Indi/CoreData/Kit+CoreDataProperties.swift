//
//  Kit+CoreDataProperties.swift
//  
//
//  Created by Alexander Sivko on 23.11.23.
//
//

import Foundation
import CoreData

extension Kit {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Kit> {
        return NSFetchRequest<Kit>(entityName: "Kit")
    }

    @NSManaged public var name: String?
    @NSManaged public var studyStage: Int64
    @NSManaged public var isBasicKit: Bool
    @NSManaged public var questions: NSSet?
}

// MARK: Generated accessors for questions
extension Kit {
    @objc(addQuestionsObject:)
    @NSManaged public func addToQuestions(_ value: Question)

    @objc(removeQuestionsObject:)
    @NSManaged public func removeFromQuestions(_ value: Question)

    @objc(addQuestions:)
    @NSManaged public func addToQuestions(_ values: NSSet)

    @objc(removeQuestions:)
    @NSManaged public func removeFromQuestions(_ values: NSSet)
}
