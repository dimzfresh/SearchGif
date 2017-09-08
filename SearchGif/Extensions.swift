//
//  Extensions.swift
//  SearchGif
//
//  Created by Dimz on 05.09.17.
//  Copyright © 2017 Dmitriy Zyablikov. All rights reserved.
//

import UIKit

extension String {
    
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: .literal, range: nil)
    }

}

extension UIViewController {
    
    func showAlert(title: String?, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            //print("Handle Ok logic here")
        }))
        
        present(alert, animated: true, completion: nil)
    }

}
