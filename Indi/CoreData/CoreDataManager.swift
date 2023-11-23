//
//  CoreDataManager.swift
//  Indi
//
//  Created by Alexander Sivko on 9.05.23.
//

import CoreData

protocol CoreDataManagerDataAndLogic {
    var context: NSManagedObjectContext { get }
    func save(completion: (Error?) -> Void)
}

final class CoreDataManager: CoreDataManagerDataAndLogic {   
    lazy private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { storeDescription, error in }
        return container
    }()
    
    lazy var context: NSManagedObjectContext = { persistentContainer.viewContext }()
    
    func save(completion: (Error?) -> Void) {
        guard context.hasChanges else {
            completion(CoreDataError.noData)
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
