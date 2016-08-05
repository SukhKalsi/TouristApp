//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Sukh Kalsi on 27/12/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import Foundation

class FlickrClient : NSObject {
    
    typealias CompletionHandler = (result: NSDictionary!, error: String?) -> Void

    override init() {
        super.init()
    }
    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: - Public API
    
    func getImagesFromLocation(latitude: Double, longitude: Double, completionHandler: CompletionHandler) {
        
        let boundingBox = createBoundingBox(latitude, longitude: longitude)

        let parameters = [
            FlickrClient.HttpHeaders.ApiKey : FlickrClient.Constants.ApiKey,
            FlickrClient.HttpHeaders.Endpoint : FlickrClient.Endpoints.Search,
            FlickrClient.HttpHeaders.BoundingBox : boundingBox,
            FlickrClient.HttpHeaders.Extras : FlickrClient.Constants.Extras,
            FlickrClient.HttpHeaders.Format : FlickrClient.Constants.Format,
            FlickrClient.HttpHeaders.NoJsonCallback : FlickrClient.Constants.NoJsonCallback,
            FlickrClient.HttpHeaders.Limit : FlickrClient.Constants.Limit,
        ];
        
        HttpClient.sharedInstance().httpGet(Constants.BaseURL, parameters: parameters as! [String : AnyObject]) { result, error in
            
            if let _ = error {
                completionHandler(result: nil, error: "Sorry there was a network error getting the images. Please try again.")
                return
            }
                
            // GUARD: Is "photos" key in our result?
            guard let photosDictionary = result["photos"] as? NSDictionary else {
                print("Cannot find keys 'photos' in \(result)")
                completionHandler(result: nil, error: "Sorry no photo collection could be found. Please try again.")
                return
            }
                
            // GUARD: Is "pages" key in the photosDictionary?
            guard let totalPages = photosDictionary["pages"] as? Int else {
                print("Cannot find key 'pages' in \(photosDictionary)")
                completionHandler(result: nil, error: "Sorry no photo pages could be found. Please try again.")
                    return
            }
            
            // Flickr API will only return up the 4000 images (100 per page * 40 page max)
            // Pick a random page!
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            self.getImageCollection(parameters as! [String : AnyObject], pageNumber: randomPage, completionHandler: completionHandler) // Pass the completion handler through for the 2nd part to handle through...
        }
    }
    
    private func getImageCollection(parameters: [String : AnyObject], pageNumber: Int, completionHandler: CompletionHandler) {
        
        // Add the page to the parameters
        var withPageDictionary = parameters
        withPageDictionary["page"] = pageNumber
        
        // Send out another request
        HttpClient.sharedInstance().httpGet(Constants.BaseURL, parameters: withPageDictionary) { result, error in
            
            if let _ = error {
                completionHandler(result: nil, error: "Sorry there was a network error getting the collection. Please try again.")
                return
            }
            
            // GUARD: Did Flickr return an error (stat != ok)?
            guard let stat = result["stat"] as? String where stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(result)")
                completionHandler(result: nil, error: "Sorry there was a error with Flickr. Please try again.")
                return
            }
            
            // GUARD: Is the "photos" key in our result?
            guard let photosDictionary = result["photos"] as? NSDictionary else {
                print("Cannot find key 'photos' in \(result)")
                completionHandler(result: nil, error: "Sorry Flickr has not provided any photos. Please try again.")
                return
            }
            
            // GUARD: Is the "total" key in photosDictionary?
            guard let totalPhotosVal = (photosDictionary["total"] as? NSString)?.integerValue else {
                print("Cannot find key 'total' in \(photosDictionary)")
                completionHandler(result: nil, error: "Sorry Flickr has not provided the total number of photos. Please try again.")
                return
            }
            
            // Ensure we have photo collection for this location
            if totalPhotosVal <= 0 {
                print("No Photos Found. Search Again.")
                completionHandler(result: nil, error: "No Photos Found. Please search a new location.")
            }
            
            completionHandler(result: photosDictionary, error: nil)
        }
    }
}
