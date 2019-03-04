//
//  DocumentEditViewController.swift
//  Documents Core Data
//
//  Created by Brock Gibson on 2/19/19.
//  Copyright © 2019 Brock Gibson. All rights reserved.
//

import UIKit

class DocumentEditViewController: UIViewController {
    
    var existingDocument: Document?

    @IBOutlet weak var titleBar: UINavigationItem!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.text = existingDocument?.name
        titleBar.title = existingDocument?.name
        contentTextField.text = existingDocument?.content

        // Do any additional setup after loading the view.
    }
    @IBAction func nameChanged(_ sender: UITextField) {
        titleBar.title = nameTextField.text
    }
    
    @IBAction func clickSave(_ sender: Any) {
        
        let name = nameTextField.text ?? ""
        let content = contentTextField.text ?? ""
        let dateModified = Date()
        
        var document: Document?
        
        if let exisitingDocument = existingDocument {
            existingDocument?.name = name
            existingDocument?.content = content
            existingDocument?.date = dateModified
            exisitingDocument.size = Int32(content.utf8.count)
            
            document = exisitingDocument
        } else {
            document = Document(name: name, content: content, date: dateModified, size: content)
        }
        
        if let document = document {
            do {
                let managedContext = document.managedObjectContext
                
                try managedContext?.save()
                
                self.navigationController?.popViewController(animated: true)
            }
            catch {
                print("context could not be saved")
            }
        }
        
    }

}
