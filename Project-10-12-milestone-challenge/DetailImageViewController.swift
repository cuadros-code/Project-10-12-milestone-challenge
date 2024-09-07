//
//  DetailImageViewController.swift
//  Project-10-12-milestone-challenge
//
//  Created by Kevin Cuadros on 6/09/24.
//

import UIKit

class DetailImageViewController: UIViewController {
    @IBOutlet var image: UIImageView!
    var imagePath: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image.image = UIImage(contentsOfFile: imagePath.path)
    }
    

}
