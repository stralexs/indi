//
//  CoreDataManager.swift
//  Diploma Sivko Alexander
//
//  Created by Alexander Strelnikov on 9.05.23.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    lazy private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        
        container.loadPersistentStores {
            storeDescription, error in
        }
        
    return container
    }()
    
    func save(completion: (Error?) -> ()) {
        guard context.hasChanges else {
            completion(CoreDataManagerError.noData)
            return
        }
        
        do {
            try context.save()
            completion(nil)
        }
        catch {
            completion(error)
        }
    }
}

enum CoreDataManagerError: Error {
    case noData
}
