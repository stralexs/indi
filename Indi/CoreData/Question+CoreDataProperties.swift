//
//  Question+CoreDataProperties.swift
//  Indi
//
//  Created by Alexander Sivko on 19.05.23.
//
//

import Foundation
import CoreData


extension Question {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Question> {
        return NSFetchRequest<Question>(entityName: "Question")
    }

    @NSManaged public var question: String?
    @NSManaged public var correctAnswer: String?
    @NSManaged public var incorrectAnswers: [String]?
    @NSManaged public var kit: Kit?

}

extension Question : Identifiable {

}
