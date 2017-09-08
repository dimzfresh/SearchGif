//
//  DetailViewController.swift
//  SearchGif
//
//  Created by Dimz on 08.09.17.
//  Copyright © 2017 Dmitriy Zyablikov. All rights reserved.
//

import UIKit
import FLAnimatedImage

class GifDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: FLAnimatedImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    //  Declaring DetailController's Properties
    var gif: Gif?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barStyle = UIBarStyle.black
    
        //  Setting NavigationBar title from GIF's title property
        title = gif?.username ?? ""
    
        //  Displaying overview in UI (descriptionTextView) from GIF's overview property
        if let text = gif?.username {
            usernameLabel.text = "user name: \(text)"
        }

        // Calling GifImageView's method to download Image
        if let path = gif?.url {
            imageView.sd_setImage(with: URL(string: path)!)
        }
    
    }
    
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        //Set the default sharing message.
        let message = "Check this GIF"
        
        //Set the link to share.
        if let path = gif?.url, let image = imageView.image {
            
            let link = URL(string: path)!
            
            let objectsToShare = [message, link, image] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //Excluded Activities
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }

}
