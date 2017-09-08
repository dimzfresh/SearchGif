//
//  Gif.swift
//  SearchGif
//
//  Created by Dimz on 05.09.17.
//  Copyright © 2017 Dmitriy Zyablikov. All rights reserved.
//

import Foundation

typealias Dictionary = [String: Any]

//  Creating Model class for Gif Objects.
struct Gif {
    
    //  Declaring properties of Gif.
    var id: String!
    var url: String!
    var trended: String!
    var username: String!

    //  Initializer for Gif to set the properties when the object is created.
    init(gifObject: Dictionary) {
        
        if let id = gifObject["id"] as? String {
            self.id = id
        }
        
        if let images = gifObject["images"] as? Dictionary,
           let original = images["original"] as? Dictionary,
           let url = original["url"] as? String {
            
            self.url = url
        }
        
        if let username = gifObject["username"] as? String {
            self.username = username
        }
        
        if let trended = gifObject["trending_datetime"] as? String {
            self.trended = trended
        }
    }
}

