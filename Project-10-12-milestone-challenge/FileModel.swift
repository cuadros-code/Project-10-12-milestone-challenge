//
//  FileModel.swift
//  Project-10-12-milestone-challenge
//
//  Created by Kevin Cuadros on 5/09/24.
//

import UIKit
import MobileCoreServices

class FileModel: NSObject, Codable {
    
    var title: String
    var subtitle: String
    var imageID: String
    
    init(title: String, subtitle: String, imageID: String) {
        self.title = title
        self.subtitle = subtitle
        self.imageID = imageID
    }
    
}
