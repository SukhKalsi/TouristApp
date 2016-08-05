//
//  FlickrHelper.swift
//  Virtual Tourist
//
//  Created by Sukh Kalsi on 27/12/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

extension FlickrClient {
    
    /* Helper function: Provides bounding area of Lat & Lng values as 'bbox' which Flickr require */
    func createBoundingBox(latitude: Double, longitude: Double) -> String {
        
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - Constants.BoundingBoxWidth, Constants.LongMin)
        let bottom_left_lat = max(latitude - Constants.BoundingBoxHeight, Constants.LatMin)
        let top_right_lon = min(longitude + Constants.BoundingBoxHeight, Constants.LongMax)
        let top_right_lat = min(latitude + Constants.BoundingBoxHeight, Constants.LatMax)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
}
