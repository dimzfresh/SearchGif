//
//  Network.swift
//  SearchGif
//
//  Created by Dimz on 05.09.17.
//  Copyright © 2017 Dmitriy Zyablikov. All rights reserved.
//

import Foundation

typealias HTTPHeaderFields = [String: String]
let baseUrl = "http://api.giphy.com"
let apiKey  = "afb77cc4a5ab4e8ea646220ffeb83e09"

//  Custom class to handle API requests
class Network {
    
    //  Function to send request and asynchronously return response using escaping closure
    func send(request: URLRequest, callback: (([String : Any], HTTPURLResponse?, Error?) -> Void)?) {
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
            
        //  Creating data task on shared URLsession
        session.dataTask(with: request) { (data, response, error) in
            
            // Logging error description
            if error != nil {
                callback?(Dictionary(), nil, error)
                return
            }
            
            //Response is sent here
            let httpResponse = response as? HTTPURLResponse
            
            do {
                // Parsing JSON from the response data
                let responseDictionary = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    
                //  Returning parsed JSON to the caller
                callback?(responseDictionary as! [String : Any], httpResponse, nil)
            } catch {
                print("Error: Could not download gif's")
            }
            
            }.resume()  //  Starting data task.
        }
    
    func searchRequest(searchText: String, offset: Int) -> URLRequest {
        
        let str = searchText.lowercased().replace(target: " ", withString: "+")
        let url = URL(string: "https://api.giphy.com/v1/gifs/search?q=\(str)&api_key=\(apiKey)&offset=\(offset)")!
        var request = URLRequest(url: url)
        request.httpMethod = "get"
        //request.allHTTPHeaderFields = authorizationHeaders(contentType: "application/json; charset=UTF-8")
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 5.0
        
        return request
        
    }
    
    

}

extension Network {
    
    func authorizationHeaders(contentType: String) -> HTTPHeaderFields {
        //let authToken = "" // read the token from secure storage.
        return [
            //"Content-Type": "application/json",
            "Content-Type": contentType]
            //"Authorization": authToken
    }
    
}
