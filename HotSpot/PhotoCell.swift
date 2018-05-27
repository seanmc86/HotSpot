//
//  PhotoCell.swift
//  HotSpot
//
//  Created by Sean McCalgan on 2018/05/25.
//  Copyright © 2018 Sean McCalgan. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class PhotoCell: UITableViewCell {

    @IBOutlet weak var resultTitleLabel: UILabel!
    @IBOutlet weak var resultImageView: UIImageView!
    
    func setupWithPhoto(flickrPhoto: FlickrPhoto) {
        resultTitleLabel.text = flickrPhoto.title
        resultImageView.sd_setImage(with: flickrPhoto.photoUrl as URL?)
    }
    
}
