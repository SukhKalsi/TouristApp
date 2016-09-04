//
//  PhotoCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Sukh Kalsi on 31/12/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
}
