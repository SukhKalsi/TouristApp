//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Sukh Kalsi on 27/12/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        do {
            try fetchedResultsController.performFetch()
            loadPins()
        } catch {}
        
        fetchedResultsController.delegate = self
        mapView.delegate = self
        
        // Long press handler to add new pins from User action
        // Inspiration taken from Stackoverflow - http://stackoverflow.com/questions/30858360/adding-a-pin-annotation-to-a-map-view-on-a-long-press-in-swift
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    // MARK: - CoreData
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        return fetchedResultsController
    }()
    
    
    // MARK: - MapView: Load the data for the Map

    func loadPins() {
        
        if let pins = fetchedResultsController.fetchedObjects as? [Pin] {
            
            // Remove any existing annotations
            let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
            mapView.removeAnnotations( annotationsToRemove )
            
            // Add saved pins to the map
            dispatch_async(dispatch_get_main_queue()) {
                self.mapView.addAnnotations(pins)
            }
        }
    }
    
    // MARK: - MapView: Add annotation from long press
    
    func addAnnotation(gestureRecognizer:UIGestureRecognizer) {
        
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let coordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        
        switch gestureRecognizer.state {
            
        case UIGestureRecognizerState.Began:
            let pin = Pin(latitude: coordinates.latitude, longitude: coordinates.longitude, context: self.sharedContext)
            mapView.addAnnotation(pin)
            
        case UIGestureRecognizerState.Ended:
            dispatch_async(dispatch_get_main_queue()) {
                CoreDataStackManager.sharedInstance().saveContext()
            }
        
        default: break

        }
    }
    
    // MARK: - MapKit
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.animatesDrop = true
            pinView!.canShowCallout = false
            pinView!.pinTintColor = UIColor.redColor()
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {

        if let annotation = view.annotation as? Pin {
            let controller = storyboard!.instantiateViewControllerWithIdentifier("photoAlbumCollectionViewController") as! PhotoAlbumCollectionViewController
            controller.location = annotation
            self.navigationController!.pushViewController(controller, animated: true)
        }
        
        // http://stackoverflow.com/questions/26620672/mapview-didselectannotationview-not-functioning-properly
        mapView.deselectAnnotation(view.annotation, animated: false)
    }

    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        return
    }
}
