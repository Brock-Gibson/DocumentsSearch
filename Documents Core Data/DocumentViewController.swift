//
//  ViewController.swift
//  Documents Core Data
//
//  Created by Brock Gibson on 2/19/19.
//  Copyright © 2019 Brock Gibson. All rights reserved.
//

import UIKit
import CoreData

class DocumentViewController: UITableViewController {

    @IBOutlet var documentTableView: UITableView!
    
    let dateFormatter = DateFormatter()
    
    var documents = [Document]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 70
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .medium
    }

    override func viewWillAppear(_ animated: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        
        do {
            documents = try managedContext.fetch(fetchRequest)
            
            documentTableView.reloadData()
        }
        catch {
            print("Fetch could not be performed")
        }

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = documentTableView.dequeueReusableCell(withIdentifier: "documentCell", for: indexPath)
        
        let document = documents[indexPath.row]
        
        if let cell = cell as? DocumentTableViewCell, let date = document.date {
            cell.titleLabel.text = document.name
            cell.sizeLabel.text = "Size:  \(document.size) bytes"
            cell.modifiedLabel.text = "Modified: " + dateFormatter.string(from: date)
        }
        return cell
    }
    
    func deleteDocument(at indexPath: IndexPath) {
        let document = documents[indexPath.row]
        
        if let managedContext = document.managedObjectContext {
            managedContext.delete(document)
            do {
                try managedContext.save()
                self.documents.remove(at: indexPath.row)
                documentTableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Delete Failed")
                
                documentTableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteDocument(at: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let destination = segue.destination as? DocumentEditViewController ,
            let row = documentTableView.indexPathForSelectedRow?.row{
            destination.existingDocument = documents[row]
        }
    }
}

