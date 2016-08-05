//
//  HttpClient.swift
//  Virtual Tourist
//
//  Created by Sukh Kalsi on 27/12/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import Foundation

class HttpClient : NSObject {
    
    typealias CompletionHandler = (result: AnyObject!, error: NSError?) -> Void
    typealias CompletionHandlerData = (data: NSData?, error: NSError?) ->  Void

    // Shared Session
    var session : NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> HttpClient {
        
        struct Singleton {
            static var sharedInstance = HttpClient()
        }
        
        return Singleton.sharedInstance
    }
    
    
    // MARK: Helper functions
    
    // Given a dictionary of parameters, convert to a string for a url
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    // Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHandler) {

        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }

    
    // MARK: - Get request
    func httpGet(resource: String, parameters: [String : AnyObject], headers: [String : String] = [String : String](), completionHandler: CompletionHandler) -> NSURLSessionDataTask {
        
        // Configure the URL
        let urlString = resource + HttpClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        
        // Configure a request
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Apply any additional headers
        for (header, value) in headers {
            request.addValue(value, forHTTPHeaderField: header)
        }
        
        // Fire off the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                completionHandler(result: nil, error: error)
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                // generic error
                let userInfo = [NSLocalizedDescriptionKey : "The server is unavailable."]
                
                if let response = response as? NSHTTPURLResponse {
                    
                    guard let data = data else {
                        print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                        completionHandler(result: nil, error: NSError(domain: "HTTP_Get_NSHTTPURLResponse_without_data", code: 1, userInfo: userInfo))
                        return
                    }
                    
                    HttpClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
                    
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                    completionHandler(result: nil, error: NSError(domain: "HTTP_Get_with_Response", code: 1, userInfo: userInfo))
                } else {
                    print("Your request returned an invalid response!")
                    completionHandler(result: nil, error: NSError(domain: "HTTP_Get_without_Response", code: 1, userInfo: userInfo))
                }

                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "Your data could not be retrieved from the server."]
                completionHandler(result: nil, error: NSError(domain: "HTTP_Get_has_2xx_response_without_data", code: 1, userInfo: userInfo))
                print("No data was returned by the request!")
                return
            }
            
            // Parse the data and use the data (happens in completion handler)
            HttpClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        task.resume()
        return task
    }
    
    // MARK: - Get resources e.g. Image
    func httpGetImage(url: NSURL, completionHandler: CompletionHandlerData) -> NSURLSessionTask {
        
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            if let error = error {
                completionHandler(data: nil, error: error)
            } else {
                completionHandler(data: data, error: nil)
            }
        }
        
        task.resume()
        return task
    }
}