//
//  GifCollectionViewCell.swift
//  SearchGif
//
//  Created by Dimz on 05.09.17.
//  Copyright © 2017 Dmitriy Zyablikov. All rights reserved.
//

import UIKit
import FLAnimatedImage


class GifCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: FLAnimatedImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var trandedView: UIView!
    
}

