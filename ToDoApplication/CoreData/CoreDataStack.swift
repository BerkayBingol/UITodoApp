//
//  CoreDataStack.swift
//  ToDoApplication
//
//  Created by Berkay Bingol on 30/03/2018.
//  Copyright © 2018 Berkay Bingol. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    var container: NSPersistentContainer {
        let container = NSPersistentContainer(name: "Todos")
        container.loadPersistentStores { (description, error) in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
        }
        return container
    }
    
    var managedContext: NSManagedObjectContext { // responsible for saving deleting updating the data model
        return container.viewContext
    }
}
