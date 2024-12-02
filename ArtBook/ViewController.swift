//
//  ViewController.swift
//  ArtBook
//
//  Created by Mevlüt Akküyün on 24.11.2024.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedName=""
    var selectedId:UUID?

    

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addClicked))
        
        getData()
    }
    @objc func getData(){
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        request.returnsObjectsAsFaults = false
        do{
            let results = try context.fetch(request)
            for result in results as! [NSManagedObject] {
                if  let name = result.value(forKey: "name") as? String {
                    nameArray.append(name)
                }
                if let id = result.value(forKey: "id") as? UUID {
                    idArray.append(id)
                }
                tableView.reloadData()
            }
            
        }catch{
            print("error")
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "NewData"), object: nil)
    }
    
    @objc func addClicked(){
        selectedName=""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text=nameArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedName=nameArray[indexPath.row]
        selectedId=idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier=="toDetailsVC"{
             let destinationVC = segue.destination as? DetailsVC
            destinationVC?.chosenName=selectedName
            destinationVC?.chosenID=selectedId
                
                
            
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            request.returnsObjectsAsFaults = false
            let idString = idArray[indexPath.row].uuidString
            request.predicate=NSPredicate(format: "id = %@", idString)
            let results = try! context.fetch(request)
            for result in results as! [NSManagedObject]{
                if let id = result.value(forKey: "id") as? UUID{
                    if id == idArray[indexPath.row]{
                        context.delete(result)
                        nameArray.remove(at: indexPath.row)
                        idArray.remove(at: indexPath.row)
                        self.tableView.reloadData()
                        do {
                            try context.save()
                        }catch {
                            print("error")
                        }
                        break
                    }
                    
                    
                }
            }
        }
        
    }


}

