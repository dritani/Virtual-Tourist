//
//  PhotosVC.swift
//  Virtual Tourist
//
//  Created by Dritani on 2016-03-18.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class PhotosVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var pin: Pin!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollection: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Coordinate region
        let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        let region = MKCoordinateRegion(center: pin.coordinate, span: span)
        mapView.setRegion(region, animated: false)
        mapView.addAnnotation(pin)
        
        activityIndicator.startAnimating()

        // if brand new pin, call FLickrAPI
        if pin.totalPages == -1 {
            FlickrAPI.sharedInstance().getFlickrInfo(pin.coordinate,page: Int(pin.pageNum),completionHandler: {(totalPages,urlArray) in
                
                self.pin.totalPages = totalPages
                
                if totalPages != 0 {
                    for i in 0...urlArray.count-1 {
                        dispatch_async(dispatch_get_main_queue(), {
                            var newPhoto = Photo(content: ["A":urlArray[i]], context: self.sharedContext)
                            newPhoto.pin = self.pin
                        })
                    }
                }
                try! CoreDataStackManager.sharedInstance().saveContext()
                self.updateUI()
            })
        } else {
            updateUI()
        }
    }

    
    func updateUI() {
        // update screen based on results, regardless of whether FlickrAPI was called or not
        if pin.totalPages == 0 {
            collectionView.hidden = true
            newCollection.enabled = false
            emptyLabel.hidden = false
        } else if pin.totalPages == 1 { // set newCollection to not allowed
            collectionView.hidden = false
            newCollection.enabled = false
            emptyLabel.hidden = true
        } else if Int(pin.totalPages) > 1 { // set newCollection to allowed
            collectionView.hidden = false
            newCollection.enabled = true
            emptyLabel.hidden = true
        }
        print(pin.totalPages)
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        
        collectionView.reloadData()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Layout
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = floor(self.collectionView.frame.size.width/3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }

    
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return pin.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
        let photo = pin.photos[indexPath.row] as! Photo
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCellView", forIndexPath: indexPath) as! PhotoCell
        
        if NSFileManager.defaultManager().fileExistsAtPath(String(photo.photoPath)) {
            let data = NSData(contentsOfFile: String(photo.photoPath))
            let image = UIImage(data: data!)
            cell.photo.image = image
        } else {
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.hidden = false
            FlickrAPI.sharedInstance().getFlickrPhoto(String(photo.photoURL!),completion:{(data) in
            
                let path = "\(indexPath.row)"
                let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
                let totalPath:String = documentsDirectoryURL.URLByAppendingPathComponent(path as String).path!
                self.pin.photos[indexPath.row].photoPath = totalPath
                
                let image = UIImage(data: data)
                let result = UIImageJPEGRepresentation(image!, 0.0)!
                result.writeToFile(totalPath as String, atomically: true)
                
                dispatch_async(dispatch_get_main_queue(), {
                    cell.photo.image = image
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.hidden = true
                })
            })
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = pin.photos[indexPath.row] as! Photo
        sharedContext.deleteObject(photo)
        try! CoreDataStackManager.sharedInstance().saveContext()
        try! NSFileManager.defaultManager().removeItemAtPath(String(photo.photoPath))
        collectionView.reloadData()
    }
    
    @IBAction func newCollectionActionClick(sender: UIBarButtonItem) {
        print("wtf")
        if Int(pin.pageNum) + 1 <= Int(pin.totalPages) {
            pin.pageNum = Int(pin.pageNum) + 1

        let photosToDelete = pin.photos
        
        for item in photosToDelete {
            let photo = item as! Photo
            sharedContext.deleteObject(photo)
            try! NSFileManager.defaultManager().removeItemAtPath(String(photo.photoPath))
        }
            
        try! CoreDataStackManager.sharedInstance().saveContext()
        collectionView.reloadData()
            
        activityIndicator.hidden = false
        activityIndicator.startAnimating()

        FlickrAPI.sharedInstance().getFlickrInfo(pin.coordinate,page: Int(pin.pageNum),completionHandler: {(totalPages,urlArray) in
                
                self.pin.totalPages = totalPages
                
                if totalPages != 0 {
                    for i in 0...urlArray.count-1 {
                        var newPhoto = Photo(content: ["A":urlArray[i]], context: self.sharedContext)
                        newPhoto.pin = self.pin
                    }
                }
                try! CoreDataStackManager.sharedInstance().saveContext()
                self.updateUI()
            })
        } else {
            alert("No more images",viewController: self)
        }
    }
    
    func alert(message: String, viewController: UIViewController) {
        
        let alertController = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
        }
        alertController.addAction(OKAction)
        viewController.presentViewController(alertController, animated: true) {
        }
    }
   
}