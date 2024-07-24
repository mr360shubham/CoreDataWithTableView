////
////  ViewController.swift
////  TableViewCoreData
////
////  Created by Shubam Vijay Yeme on 14/06/24.
////
//
//import UIKit
//
//class ViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//    }
//
//
//}
//

import UIKit
import CoreData

class ViewController: UIViewController {
    //var car = ["ar","ufe","fedbjn"]

    @IBOutlet weak var tableView: UITableView!
    
    var items: [NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the TableView
        tableView.delegate = self
        tableView.dataSource = self
        
        self.title = "CoreData TableView"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Add a button to the navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        self.view.backgroundColor = .red
        fetchItems()
//        deleteItem(at: 0)
//        updateItem(at: 1, with: "white")
        
    }

    @objc func addItem() {
        let alert = UIAlertController(title: "New Item", message: "Add a new item", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter item name"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            guard let textField = alert.textFields?.first,
                  let nameToSave = textField.text else {
                return
            }
            self.saveItem(name: nameToSave)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
       
        present(alert, animated: true)
    }
    
    func fetchItems() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Item")
        
        do {
            items = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func saveItem(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Item", in: context)!
        let item = NSManagedObject(entity: entity, insertInto: context)
        item.setValue(name, forKeyPath: "name")
        
        do {
            items.append(item)
            try context.save()
           
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateItem(at index: Int, with newName: String) {
        print("enter")
            guard index < items.count else { return }
            print("after")
            // Retrieve the object from Core Data
            let item = items[index]
            
            // Update the object’s attribute
            item.setValue(newName, forKey: "name")
            
            // Save the changes in the Core Data context
            do {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                let context = appDelegate.persistentContainer.viewContext
                try context.save()
                
                // Update the item in the array
                items[index] = item
                
                // Reload the specific row in the table view
//                let indexPath = IndexPath(row: index, section: 0)
//                tableView.reloadRows(at: [indexPath], with: .automatic)
                tableView.reloadData()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    
    func deleteItem(at index: Int) {
            guard index < items.count else { return }
            
            // Retrieve the object from Core Data
            let item = items[index]
            
            // Remove the item from Core Data
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            context.delete(item)
            
            do {
                // Save the context to persist the deletion
                try context.save()
                
                // Remove the item from the array
                items.remove(at: index)
                
                // Delete the corresponding row in the table view
                let indexPath = IndexPath(row: index, section: 0)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
        }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.value(forKey: "name") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let alert = UIAlertController(title: "Update Item", message: "Update the item name", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                let item = self.items[indexPath.row]
                textField.text = item.value(forKey: "name") as? String
            }
            
            let updateAction = UIAlertAction(title: "Update", style: .default) { [unowned self] action in
                guard let textField = alert.textFields?.first,
                      let updatedName = textField.text else {
                    return
                }
                self.updateItem(at: indexPath.row, with: updatedName)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            alert.addAction(updateAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true)
        }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                // Call the delete function
                deleteItem(at: indexPath.row)
            }
        }
}
