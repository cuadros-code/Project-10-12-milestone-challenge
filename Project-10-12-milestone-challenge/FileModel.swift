//
//  FileModel.swift
//  Project-10-12-milestone-challenge
//
//  Created by Kevin Cuadros on 5/09/24.
//

import UIKit

class FileModel: NSObject, Codable {

    var title: String
    var subtitle: String
    var image: String
    
    init(title: String, subtitle: String, image: String) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
    
}
