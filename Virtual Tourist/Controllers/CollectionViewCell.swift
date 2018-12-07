//
//  CollectionViewCell.swift
//  Virtual Tourist
//
//  Created by macos on 22/11/18.
//  Copyright © 2018 macos. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    //Properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override var isSelected: Bool {
        didSet {
            //imageView.layer.borderWidth = isSelected ? 10 : 0
            imageView.layer.opacity = isSelected ? 0.4 : 1
        }
    }
}
