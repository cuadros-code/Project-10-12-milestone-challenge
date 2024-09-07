//
//  ViewController.swift
//  Project-10-12-milestone-challenge
//
//  Created by Kevin Cuadros on 5/09/24.
//

import UIKit

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
        let editTitleAction = UIAction(title: "Edit title", image: UIImage(systemName: "pencil")) { _ in
            
        }
        let editSecondaryText = UIAction(title: "Edit subtitle", image: UIImage(systemName: "pencil")) { _ in
            
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
            detailController.imagePath = getDocumentDirectory().appendingPathComponent(selectedItem.imageID)
            navigationController?.pushViewController(detailController, animated: true)
        }
    }
    
    
    // Picket Image
    @objc func takePhoto(){
        let pickerImage = UIImagePickerController()
        pickerImage.delegate = self
        pickerImage.sourceType = .camera
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
        
        dismiss(animated: true)
    }
    
    // User Directory
    func getDocumentDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0]
    }

    
    // Alerts
    func confirmDeleteItem(at indexPath: IndexPath){
        let alert = UIAlertController(title: "Delete Item", message: "Be sure to delete", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { [weak self] _ in
            self?.listImages.remove(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        deleteAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

}

