//
//  MapVC.swift
//  Virtual Tourist
//
//  Created by Dritani on 2016-03-18.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var newPin: Pin?
    var delete:Bool = false
    var editButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!
    
    @IBOutlet var longPress: UILongPressGestureRecognizer!
    @IBOutlet weak var botButton: UIButton!
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    // MARK: Application lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Edit/Done buttons
        editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editPressed")
        doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "donePressed")
        self.navigationItem.rightBarButtonItem = editButton
        
        // Map Region Persistence
        mapView.delegate = self
        restoreMapRegion(false)
        

        // Pin Persistence
        let pins = fetchAllPins()
        for item in pins {
            let pin = item as Pin
            mapView.addAnnotation(pin)
        }
    }
    
    // Edit/Delete buttons
    func editPressed() {
        botButton.hidden = false
        longPress.enabled = false
        delete = true
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    func donePressed() {
        botButton.hidden = true
        longPress.enabled = true
        delete = false
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    // Pin Persistence
    func fetchAllPins() -> [Pin] {
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        // Execute the Fetch Request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch {
            return [Pin]()
        }
    }
    
    // Map Region Persistence
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    func restoreMapRegion(animated: Bool) {
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude = regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            mapView!.setRegion(savedRegion, animated: animated)
        }
    }
    
    func saveMapRegion() {
        let dictionary = [
            "latitude" : mapView!.region.center.latitude,
            "longitude" : mapView!.region.center.longitude,
            "latitudeDelta" : mapView!.region.span.latitudeDelta,
            "longitudeDelta" : mapView!.region.span.longitudeDelta
        ]
        
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }

    // Add Pin
    @IBAction func addPinToMap(sender: UILongPressGestureRecognizer) {
        let tapPosition:CGPoint = sender.locationInView(self.mapView)
        let coordinates = mapView.convertPoint(tapPosition, toCoordinateFromView: mapView)
        
        switch sender.state {
        case .Began:
            newPin = Pin(latitude: coordinates.latitude, longitude: coordinates.longitude, context: sharedContext)
            break
        case .Changed:
            newPin!.coordinate = coordinates
            break
        case .Ended:
            try! CoreDataStackManager.sharedInstance().saveContext()
            break
        default:
            break
        }
        
        mapView.addAnnotation(newPin!)
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch (newState) {
        case .Starting:
            view.dragState = .Dragging
        case .Ending, .Canceling:
            view.dragState = .None
        default: break
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MKPointAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.animatesDrop = true
                view.canShowCallout = false
            }
            return view
        }
        return nil
    }

    // Pin Next Screen
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        
        if delete {
            mapView.removeAnnotation(view.annotation!)
        } else {
            
            let pin = fetchOnePin(view.annotation!.coordinate)
            
            let photoAlbumViewController = storyboard!.instantiateViewControllerWithIdentifier("photoAlbum") as! PhotosVC
            photoAlbumViewController.pin = pin

            navigationController?.pushViewController(photoAlbumViewController, animated: true)
        }
    }
    
    private func fetchOnePin(coordinate: CLLocationCoordinate2D) -> Pin? {
        
        var pin: Pin? = nil
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.predicate = NSPredicate(format:"latitude == %lf and longitude == %lf", coordinate.latitude, coordinate.longitude)
        do {
            let results = try sharedContext.executeFetchRequest(fetchRequest) as? [Pin]
            if let pins = results {
                if pins.count > 0 {
                    pin = pins[0] as Pin
                }
            }
        } catch {
            pin = nil
        }
        return pin
    }
}