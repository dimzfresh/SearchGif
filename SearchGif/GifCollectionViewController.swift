//
//  GifCollectionViewController.swift
//  SearchGif
//
//  Created by Dimz on 05.09.17.
//  Copyright © 2017 Dmitriy Zyablikov. All rights reserved.
//

import UIKit
import FLAnimatedImage
import SDWebImage

private let reuseIdentifier = "GifCell"

class GifCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet var collectionHeaderView: UIView!
    
    let viewTag = 1000
    
    //  Service Object to handle API requests.
    let service = Network()
    
    var gifs = [Gif]()
    var selectedGif: Gif?
    
    var refresher: UIRefreshControl!
    
    var searchText: String {
        get {
            if let text = searchTextField.text, !text.isEmpty {
                return text
            } else {
                return "cats"
            }
        }
    }
    
    // number of items to be fetched each time (LIMIT)
    let itemsPerBatch = 5
    
    // new items
    var thisBatchOfItems: [Dictionary]?
    
    // Where to start fetching items (OFFSET)
    var offset = 0
    
    // a flag for when all items have already been loaded
    var reachedEndOfItems = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        
        collectionHeaderView.tag = viewTag
        collectionHeaderView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 130)
        
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(GifCollectionViewController.refreshGifs), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        // Calling function to download Gifs from API.
        downloadGifs(searchText)
    }
    
    func refreshGifs() {
        offset = 0
        reachedEndOfItems = false
        
        removeGifs()
        downloadGifs(searchText)
        refresher?.endRefreshing()
    }
    
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            let alert = UIAlertController(title: title, message: "Search text is empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        refreshGifs()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return gifs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GifCollectionViewCell
        
        cell.trandedView.layer.cornerRadius = cell.trandedView.frame.height / 2
        cell.trandedView.clipsToBounds = true
        
        let gif = gifs[indexPath.row]
        
        cell.imageView.sd_setImage(with: URL(string: gif.url)!)

        if (!gif.trended.isEmpty || !gif.username.isEmpty) {
            cell.infoView.isHidden = false
            cell.trandedView.isHidden = gif.trended.isEmpty
            cell.usernameLabel.text = gif.username ?? ""
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // Check if the last row number is the same as the last current data element
        if indexPath.item == gifs.count - 1 {
            downloadGifs(searchText)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3 - 1
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    //MARK: UICollectionViewDelegate
    
    //  Handling events on GifCells.
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedGif = gifs[indexPath.row]
        
        //  Triggering navigation to DetailController.
        performSegue(withIdentifier: "DetailVC", sender: self)
        
    }
    
    // MARK: - Navigation
    
    // Sending movie object to DetailController before navigation.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        let backItem = UIBarButtonItem()
//        backItem.action =  #selector(GifDetailViewController.backButtonTapped)
//        backItem.image = #imageLiteral(resourceName: "icon_back")
//        backItem.tintColor = .white
        
        // Geting the new view controller using segue.destinationViewController.
        let detailVC = segue.destination as? GifDetailViewController
        
        // Passing the selected object to DetailController.
        if let gif = selectedGif {
            detailVC?.gif = gif
            detailVC?.navigationItem.leftBarButtonItem?.image = #imageLiteral(resourceName: "icon_back")
            detailVC?.navigationItem.backBarButtonItem?.image = #imageLiteral(resourceName: "icon_back")
        }
        
    }
    
    
    // MARK: - API

    //  function to download gifs from API.
    func downloadGifs(_ searchText: String) {
        
        removeSubview()
        
        //  Creating URLRequest
        let request = service.searchRequest(searchText: searchText, offset: offset)
        
        //  Sending API request on service
        service.send(request: request, callback: { (data, response, error) in
            
            if error != nil {
                if !ConnectionCheck.isConnectedToNetwork() {
                    self.showAlert(title: nil, message: "Check internet connection")
                } else {
                    self.showAlert(title: nil, message: "Something goes wrong")
                }
                return
            }
            
            if response?.statusCode != 200 {
                // check for http errors
                self.showAlert(title: nil, message: "Server error")
                //print("statusCode should be 200, but is \(String(describing: response?.statusCode))")
                return
            }
            
            //  Optional binding to check if the response exists
            guard let newItems = data["data"] as? [Dictionary] else { return }
            
            self.thisBatchOfItems = newItems
            self.loadMore()
            
        })
    }
    
    func removeGifs() {
        gifs.removeAll()
        collectionView?.reloadData()
    }
    
    func removeSubview() {
        if let viewWithTag = self.view.viewWithTag(viewTag) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    func loadMore() {
        
        // don't bother doing another query if already have everything
        guard !self.reachedEndOfItems else { return }
        
        // query the db on a background thread
        //DispatchQueue.global(qos: .background).async {
        
        // update UITableView with new batch of items on main thread after query finishes
        DispatchQueue.main.async {
            
            if let newGifs = self.thisBatchOfItems {
                
                self.insertItems(newGifs)
                
                // check if this was the last of the data
                if newGifs.count < self.itemsPerBatch {
                    self.reachedEndOfItems = true
                }
                
                // reset the offset for the next data query
                self.offset += self.itemsPerBatch
                
                self.thisBatchOfItems?.removeAll()
            }
            
        }
        //}
    }
    
    func insertItems(_ newItems: [Dictionary]) {
        
        guard newItems.count != 0 else { return }
        
        //  Iterating over array of gifs
        for gifObject in newItems {
            
            // Initialing model from the movieObject
            let gif = Gif(gifObject: gifObject)
            
            //  Appending objects to array of Gifs
            gifs.append(gif)
            
            //  Reloading CollectionView's data on main thread to reflect changes.
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
        
        guard gifs.count == 0 else { return }
        
        self.collectionView?.addSubview(self.collectionHeaderView)
        
    }
}

extension GifCollectionViewController: UITextFieldDelegate {
    
    func dismissKeyboard() {
        if self.searchTextField.isFirstResponder {
            self.searchTextField.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        searchTextField.resignFirstResponder()
        
        return false
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
