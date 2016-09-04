//
//  PhotoAlbumCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Sukh Kalsi on 28/12/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

private let reuseIdentifier = "PhotoCell"

class PhotoAlbumCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties

    // Pin location object passed through via segue
    var location : Pin!
    
    // The selected indexes array keeps all of the indexPaths for cells that are "selected".
    private var selectedIndexes = [NSIndexPath]()
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    private var insertedIndexPaths: [NSIndexPath]!
    private var deletedIndexPaths: [NSIndexPath]!
    private var updatedIndexPaths: [NSIndexPath]!

    
    // MARK: - Outlets

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    @IBOutlet weak var btnCollection: UIBarButtonItem!
    @IBOutlet weak var collectionViewActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var collectionViewLabel: UILabel!
    
    // MARK: - Actions
    
    @IBAction func btnCollectionAction(sender: UIBarButtonItem) {
        btnCollection.enabled = false
        
        // clear entire collection or remove user selected items
        if selectedIndexes.isEmpty {
            
            collectionViewActivityIndicator.hidden = false
            collectionViewActivityIndicator.startAnimating()
            collectionViewLabel.text = "Loading photos..."
            collectionViewLabel.hidden = false
            
            if let collection = fetchedResultsController.fetchedObjects as? [Picture] {
                
                for picture in collection {
                    picture.location = nil
                    sharedContext.deleteObject(picture)
                }
            }

            // retrieve a new collection set...
            getCollection()
            
        } else {
    
            for indexPath in selectedIndexes {
                let picture = fetchedResultsController.objectAtIndexPath(indexPath) as! Picture
                picture.location = nil
                sharedContext.deleteObject(picture)
            }
            
            selectedIndexes = [NSIndexPath]()
            updateButton()
        }
        
        btnCollection.enabled = true
    }


    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    // Mark: - Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Picture")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoID", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "location == %@", self.location);
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        return fetchedResultsController
        
    }()
    
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Collection view delegate, datasource and Register cell classes
        photoAlbumCollectionView.delegate = self
        photoAlbumCollectionView.dataSource = self
        
        // Set the delegate to this view controller
        fetchedResultsController.delegate = self

        // Perform the fetch
        var error: NSError?
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
        
        // Set the text on the button
        updateButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if location.pictures.isEmpty {
            collectionViewActivityIndicator.startAnimating()
            btnCollection.enabled = false;
            getCollection()
        } else {
            collectionViewActivityIndicator.stopAnimating()
            collectionViewActivityIndicator.hidden = true
            collectionViewLabel.hidden = true
        }
        
        // load the map to the correct location, zoomed in
        loadMap()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Layout the collection view
        let width = floor(self.photoAlbumCollectionView.frame.size.width / 3)
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: width, height: width)
        
        self.photoAlbumCollectionView.collectionViewLayout = layout
    }
    
    
    // MARK: - Private controller methods

    private func getCollection() {

        FlickrClient.sharedInstance().getImagesFromLocation(location.latitude, longitude: location.longitude) { result , error in
            
            if let _ = error {
                print("error.")
            } else {
                
                if let photoDictionaries = result.valueForKey("photo") as? [[String : AnyObject]] {

                    // Parse the array of photo dictionairies
                    let _ = photoDictionaries.map() { (dictionary: [String : AnyObject]) -> Picture in
                        
                        let url = NSURL(string: dictionary["url_m"] as! String)!
                        let picture = Picture(imageURL: url, context: self.sharedContext)
                        picture.location = self.location
                        
                        return picture
                    }
                    
                    // update the collection view on the main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        CoreDataStackManager.sharedInstance().saveContext()

                        self.btnCollection.enabled = true
                        // self.photoAlbumCollectionView.reloadData()
                        
                        self.collectionViewActivityIndicator.stopAnimating()
                        self.collectionViewActivityIndicator.hidden = true
                        
                        if photoDictionaries.isEmpty {
                            self.collectionViewLabel.text = "No photos found for this location."
                        } else {
                            self.collectionViewLabel.hidden = true
                        }
                    }
                }
            }
        }
    }
    
    private func loadMap() {
        // Zoom map into region, Centralise map view to coordinates and add annotation to map view
        let span = MKCoordinateSpanMake(0.0025, 0.0025)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), span: span)
        self.mapView.scrollEnabled = false
        self.mapView.addAnnotation(location)
        self.mapView.regionThatFits(MKCoordinateRegionMake(region.center, region.span))
        self.mapView.setRegion(region, animated: true)
    }
    
    private func updateButton() {
        let text: String!

        if selectedIndexes.isEmpty {
            text = "New Collection"
        } else {
            text = "Remove Selected Pictures"
        }
        
        btnCollection.title = text
    }

    
    // MARK: UICollectionView

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        let sections = self.fetchedResultsController.sections?.count ?? 0
        return sections
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        let numberOfObjects = sectionInfo.numberOfObjects
        return numberOfObjects
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var locationImage = UIImage()
        let picture = fetchedResultsController.objectAtIndexPath(indexPath) as! Picture
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        cell.activityIndicator.hidden = true
        cell.activityIndicator.stopAnimating()

        // we have an image downloaded...
        if picture.locationImage != nil {
            locationImage = picture.locationImage!
            cell.imageView.image = locationImage
            return cell
        }
        
        // we don't have an image downloaded, and there appears to be no url to fetch one
        else if picture.imageURL == nil || picture.imageURL == "" {
            locationImage = UIImage(named: "noImage")!
            cell.imageView.image = locationImage
            return cell
        }
        
        // we start downloading...
        else {
            cell.activityIndicator.hidden = false
            cell.activityIndicator.startAnimating()

            let task = HttpClient.sharedInstance().httpGetImage(picture.imageURL!) { data, error in
                
                if let error = error {
                    print("Image download error: ")
                    print(error)
                } else {
                    
                    // Craete the image
                    let image = UIImage(data: data!)
                    
                    // update the cell later, on the main thread
                    
                    dispatch_async(dispatch_get_main_queue()) {

                        // update the model, for caching
                        picture.locationImage = image
                        
                        cell.imageView.image = image
                        cell.activityIndicator.stopAnimating()
                        cell.activityIndicator.hidden = true
                        
                        // self.photoAlbumCollectionView.reloadItemsAtIndexPaths([indexPath])
                    }
                }
            }
            
            cell.taskToCancelifCellIsReused = task
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCollectionViewCell {
            // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
            if let index = selectedIndexes.indexOf(indexPath) {
                selectedIndexes.removeAtIndex(index)
                cell.imageView.alpha = 1.0
            } else {
                selectedIndexes.append(indexPath)
                cell.imageView.alpha = 0.5
            }
        }
        
        updateButton()
    }

    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {

        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        switch type {
            
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
            
        case .Delete:
            deletedIndexPaths.append(indexPath!)
            break

        case .Update:
            updatedIndexPaths.append(indexPath!)
            
        case .Move:
            print("Move an item. We don't expect to see this in this app.")
            break

        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        photoAlbumCollectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.photoAlbumCollectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.photoAlbumCollectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.photoAlbumCollectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
        }, completion: nil)
    }
}
