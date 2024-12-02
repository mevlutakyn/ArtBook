//
//  DetailsVC.swift
//  ArtBook
//
//  Created by Mevlüt Akküyün on 24.11.2024.
//

import UIKit
import CoreData
class DetailsVC: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var chosenName=""
    var chosenID : UUID?

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        view.addGestureRecognizer(gestureRecognizer)
        imageView.isUserInteractionEnabled=true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageGestureRecognizer)
        
        if chosenName != "" {
            imageView.isUserInteractionEnabled=false
            saveButton.isHidden=true
            let uuidString = chosenID?.uuidString
            let appdelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appdelegate?.persistentContainer.viewContext
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetch.returnsObjectsAsFaults = false
            let predicate = NSPredicate(format: "id == %@", uuidString!)
            fetch.predicate=predicate
            
            do{
                let results = try context?.fetch(fetch)
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String{
                        nameText.text = name
                    }
                    if let artist = result.value(forKey: "artist") as? String{
                        artistText.text = artist
                    }
                    if let year = result.value(forKey: "year") as? Int{
                        yearText.text = String(year)
                    }
                    if let data = result.value(forKey: "image") as? Data{
                        imageView.image = UIImage(data: data)
                    }
                }
                
            }catch{
                print("error")
            }
        }else{
            imageView.isUserInteractionEnabled=true
            saveButton.isEnabled=false
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }
        
    }
    @IBAction func savaButtonClicked(_ sender: Any) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let paintings=NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        paintings.setValue(nameText.text, forKey: "name")
        paintings.setValue(artistText.text, forKey: "artist")
        paintings.setValue(UUID(), forKey: "id")
        if let year = Int(yearText.text!){
            paintings.setValue(year, forKey: "year")
        }
        let image = imageView.image?.jpegData(compressionQuality: 0.5)
        paintings.setValue(image, forKey: "image")
        do{
          try context.save()
            print("saved")
        }catch{
            print("errorr")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NewData"), object: nil)
        navigationController?.popViewController(animated: true)
        
    }
    @objc func endEditing() {
        view.endEditing(true)
    }
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing=true
        present(picker, animated: true , completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image=info[.editedImage] as? UIImage
        saveButton.isEnabled=true
        self.dismiss(animated: true, completion: nil)
    }
    

    
}
