//
//  AddTodoViewController.swift
//  ToDoApplication
//
//  Created by Berkay Bingol on 28/03/2018.
//  Copyright © 2018 Berkay Bingol. All rights reserved.
//

import UIKit
import CoreData
class AddTodoViewController: UIViewController {
    //MARK: Properties
    
    var managedContext: NSManagedObjectContext!
    var todo: Todo?
    
    //MARK: Outlets
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    fileprivate func dismissAndResign() {
        dismiss(animated: true )
        textView.resignFirstResponder()
    }
    
    @IBAction func done(_ sender: Any) {
        guard let title = textView.text, !title.isEmpty else {
            return
        }
        if let todo = self.todo {
            todo.title = title
            todo.priority = Int16( segmentedControl.selectedSegmentIndex)
        } else {
            let todo = Todo(context: managedContext)
            todo.title = title
            todo.priority = Int16( segmentedControl.selectedSegmentIndex)
            todo.date = Date()
        }
     
        do {
            try managedContext.save()
            dismissAndResign() //keyboard hides
        } catch {
            print("Error saving todo: \(error)")
        }

        
    }
    @IBAction func cancel(_ sender: Any) {
     dismissAndResign()//QUICKY HIDE KEYBOARD WHEN CANCEL BUTTON PRESSED.
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(with:)),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        textView.becomeFirstResponder() //the keyboard popsup first.
        if let todo = todo {
            textView.text = todo.title
            textView.text = todo.title //bug 
            segmentedControl.selectedSegmentIndex = Int(todo.priority)
        }
    }

    @objc func keyboardWillShow(with notification: Notification) {
        let key = "UIKeyboardFrameEndUserInfoKey"
        guard let keyboardFrame = notification.userInfo?[key] as? NSValue else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height + 16 // 16 is the spacing between keyboard and cancel button.
        bottomConstraint.constant = keyboardHeight
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        //add this height to constant for bottom constraint
    }
  

}

extension AddTodoViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if doneButton.isHidden {
            textView.text.removeAll()
            textView.textColor = .white
            
            doneButton.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

