//
//  TodoTableViewController.swift
//  ToDoApplication
//
//  Created by Berkay Bingol on 28/03/2018.
//  Copyright © 2018 Berkay Bingol. All rights reserved.
//

import UIKit
import CoreData

class TodoTableViewController: UITableViewController {

    //properties
    
    var resultController: NSFetchedResultsController<Todo>!
    let coreDataStack = CoreDataStack()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Request
        
        
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
        
        //Init
        request.sortDescriptors = [sortDescriptors]
       resultController = NSFetchedResultsController(
                                                     fetchRequest: request,
                                                     managedObjectContext: coreDataStack.managedContext,
                                                     sectionNameKeyPath: nil,
                                                     cacheName: nil
        )
        resultController.delegate = self
        //Fetch
        do {
                try resultController.performFetch()

        }
        catch {
            print("Perform fetch error: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

   

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultController.sections?[section].numberOfObjects ?? 0 //if no object will be zero
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)

        // Configure the cell...
        let todo = resultController.object(at: indexPath)
        cell.textLabel?.text = todo.title
        
        return cell
    }
 
   override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
        let todo = self.resultController.object(at: indexPath)
        self.resultController.managedObjectContext.delete(todo)
        do {
            try self.resultController.managedObjectContext.save()
            completion(true)
        }
        catch { print("delete error : \(error)")
            completion(false)

        }
    }
    action.image = #imageLiteral(resourceName: "Trash")
    action.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [action])
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowAddTodo", sender: tableView.cellForRow(at: indexPath))
        
    }
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Check") { (action, view, completion) in
            let todo = self.resultController.object(at: indexPath)
            self.resultController.managedObjectContext.delete(todo)
            do {
                try self.resultController.managedObjectContext.save()
                completion(true)
            }
            catch { print("checked error : \(error)")
                completion(false)
                
            }
        }
        action.image = #imageLiteral(resourceName: "Check")
        action.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [action])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UIBarButtonItem,  let vc = segue.destination as? AddTodoViewController {
            vc.managedContext = resultController.managedObjectContext
        }
        if let cell = sender as? UITableViewCell, let vc = segue.destination as? AddTodoViewController {
            vc.managedContext = resultController.managedObjectContext
            if let indexPath = tableView.indexPath(for: cell){
                let todo = resultController.object(at: indexPath )
                vc.todo = todo
            }
           
        }
        
    }
}

extension TodoTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                let todo = resultController.object(at: indexPath)
                cell.textLabel?.text = todo.title
            }
        default:
            break
        }
    }
}
