//
//  ViewController.swift
//  Documents Core Data
//
//  Created by Brock Gibson on 2/19/19.
//  Copyright © 2019 Brock Gibson. All rights reserved.
//

import UIKit
import CoreData

class DocumentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating
{

    @IBOutlet var documentTableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)

    let dateFormatter = DateFormatter()
    
    var documents = [Document]()
    var filteredDocuments = [Document]()
    var baseDocuments = [Document]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentTableView.dataSource = self
        documentTableView.delegate = self
        documentTableView.rowHeight = 70
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search Documents"
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .medium
        
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
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
        baseDocuments = documents
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        var names = [Document]()
        var content = [Document]()
        if searchText != nil{
            names = baseDocuments.filter({(doc : Document) -> Bool in
                return (doc.name?.lowercased().contains(searchText!.lowercased()))!})
            content = baseDocuments.filter({(doc : Document) -> Bool in
                return (doc.content?.lowercased().contains(searchText!.lowercased()))!})
            filteredDocuments = Array(Set(names + content))
            if filteredDocuments.count > 0{
                documents = filteredDocuments
            }
            else {
                documents = baseDocuments
            }
            documentTableView.reloadData()
        }
        return
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredDocuments.count
        }
        return documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteDocument(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let destination = segue.destination as? DocumentEditViewController ,
            let row = documentTableView.indexPathForSelectedRow?.row{
            destination.existingDocument = documents[row]
        }
    }
}

