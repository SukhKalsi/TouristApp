//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Sukh Kalsi on 27/12/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

extension FlickrClient {
    
    struct Constants {
        static let ApiKey : String = "ab8509e656e68cbf711c216c0208cfe4" // get key from here: https://www.flickr.com/services/api/explore/flickr.photos.search
        static let BaseURL : String = "https://api.flickr.com/services/rest/"
        static let GalleryID : String = "5704-72157622566655097" // Do we need this? Taken from the old flicr finder app we did...
        static let Format : String = "json"
        static let NoJsonCallback : String = "1"
        static let BoundingBoxHeight : Double = 1.0 // for Flickr bbox when using lat/long search
        static let BoundingBoxWidth : Double = 1.0 // for Flickr bbox when using lat/long search
        static let LatMin : Double = -90.0
        static let LatMax : Double = 90.0
        static let LongMin : Double = -180.0
        static let LongMax : Double = 180.0
        static let Extras : String = "url_m"
        static let Limit : Int = 20
    }
    
    struct HttpHeaders {
        static let ApiKey : String = "api_key"
        static let Endpoint : String = "method"
        static let GalleryID : String = "gallery_id"
        static let Extras : String = "extras"
        static let Format : String = "format"
        static let NoJsonCallback : String = "nojsoncallback"
        static let BoundingBox : String = "bbox"
        static let Limit : String = "per_page"
    }
    
    struct Endpoints {
        static let Search : String = "flickr.photos.search"
        static let Photos : String = "flickr.galleries.getPhotos"
    }
}
