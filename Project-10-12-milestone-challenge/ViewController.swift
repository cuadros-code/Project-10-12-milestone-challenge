//
//  ViewController.swift
//  Project-10-12-milestone-challenge
//
//  Created by Kevin Cuadros on 5/09/24.
//

import UIKit

enum EditType {
    case title
    case subtitle
}

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var listImages = [FileModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "PhotoMark"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(takePhoto)
        )
        
        let defaults = UserDefaults.standard
        
        if let getList = defaults.object(forKey: "listImages") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                listImages = try jsonDecoder.decode([FileModel].self, from: getList)
            } catch {
                print("Failed to get List.")
            }
        }
        
    }
    
    
    // Table Actions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listImages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = listImages[indexPath.row]
        let imagePath = getDocumentDirectory().appendingPathComponent(item.imageID)
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        content.secondaryText = item.subtitle
        content.image = UIImage(contentsOfFile: imagePath.path)
        content.imageProperties.cornerRadius = 4
        content.imageProperties.maximumSize = CGSize(width: 70, height: 50)
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let editTitleAction = UIAction(title: "Edit title", image: UIImage(systemName: "pencil")) { [weak self] _ in
            self?.changeTitle(at: indexPath, type: .title)
        }
        let editSecondaryText = UIAction(title: "Edit subtitle", image: UIImage(systemName: "pencil")) { [weak self] _ in
            self?.changeTitle(at: indexPath, type: .subtitle)
        }
        
        let deleteItem = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { [weak self] _ in
            self?.confirmDeleteItem(at: indexPath)
        }
        deleteItem.attributes = .destructive
            
        let menu = UIMenu(title: "Actions", children: [editTitleAction, editSecondaryText, deleteItem])
        
        return UIContextMenuConfiguration(actionProvider: { _ in
            return menu
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailController = storyboard?.instantiateViewController(withIdentifier: "ImageDetail") as? DetailImageViewController {
            let selectedItem = listImages[indexPath.row]
            detailController.titleImage = selectedItem.title
            detailController.imagePath = getDocumentDirectory().appendingPathComponent(selectedItem.imageID)
            navigationController?.pushViewController(detailController, animated: true)
        }
    }
    
    
    // Picket Image
    @objc func takePhoto(){
        let pickerImage = UIImagePickerController()
        pickerImage.delegate = self
        pickerImage.sourceType = .photoLibrary
        present(pickerImage, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        let imageID = UUID().uuidString
        let imagePath = getDocumentDirectory().appendingPathComponent(imageID)
        
        if let imageData = image.jpegData(compressionQuality: 0.9){
            try? imageData.write(to: imagePath)
        }
        
        let selectedImage = FileModel(title: "Unknown", subtitle: "Unknown", imageID: imageID)
        listImages.insert(selectedImage, at: 0)
        
        DispatchQueue.main.async {
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        }
        saveList(listImages)
        dismiss(animated: true)
    }
    
    // User Directory
    func getDocumentDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0]
    }

    
    // Alerts
    func confirmDeleteItem(at indexPath: IndexPath){
        let alert = UIAlertController(title: "This photo will be delete on your device", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { _ in
            self.listImages.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.saveList(self.listImages)
        }
        deleteAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func changeTitle(at indexPath: IndexPath, type typeAlert: EditType){
        
        let message = typeAlert == .title ? "Rename your photo" : "Add a caption to your photo"
        
        let alert = UIAlertController(title: "\(message)", message: nil, preferredStyle: .alert)
        alert.addTextField()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let submitAction = UIAlertAction(title: "Save", style: .default) { [weak alert] _ in
            if let text = alert?.textFields?[0].text {
                if typeAlert == .title {
                    self.listImages[indexPath.row].title = text
                } else if typeAlert == .subtitle {
                    self.listImages[indexPath.row].subtitle = text
                }
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
            self.saveList(self.listImages)
        }
        
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    
    func saveList( _ list: [FileModel]) {
        let jsonEncoder = JSONEncoder()
        if let saveData = try? jsonEncoder.encode(list) {
            let defaults = UserDefaults.standard
            defaults.setValue(saveData, forKey: "listImages")
        } else {
            print("Failed to save photo.")
        }
        
    }

}

