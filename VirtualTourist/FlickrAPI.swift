//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by Dritani on 2016-03-18.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import Foundation
import MapKit
import CoreData

// Class responsible to hold all necessary methods to get the 
// photos from the Flickr web service
//
class FlickrAPI: NSObject {
    
    var totalPages: Int = 0
    
    // singleton instance
    class func sharedInstance() -> FlickrAPI {
        
        struct Static {
            static var sharedInstance = FlickrAPI()
        }
        
        return Static.sharedInstance
    }
    
    //http://krakendev.io/blog/the-right-way-to-write-a-singleton
    // static let sharedInstance = TheOneAndOnlyKraken()
    
    
    // shared session
    lazy var sharedSession = {
        return NSURLSession.sharedSession()
    }()
    
    // MARK: Public functions
    
    // find the photos from the parameted coordinate
    func getFlickrInfo(coordinate: CLLocationCoordinate2D, page: Int, completionHandler: (totalPages: Int!, urlArray:[String]) -> Void) {
        
        
        let methodArguments = [
            Constants.FlickrParamValue.ParamMethod: Constants.FlickrParamValue.ValueMethod,
            Constants.FlickrParamValue.ParamApiKey: Constants.FlickrParamValue.ValueApiKey,
            Constants.FlickrParamValue.ParamExtras: Constants.FlickrParamValue.ValueExtras,
            Constants.FlickrParamValue.ParamFormat: Constants.FlickrParamValue.ValueFormat,
            Constants.FlickrParamValue.ParamNoJsonCallback: Constants.FlickrParamValue.ValueNoJsonCallback,
            Constants.FlickrParamValue.ParamPerPage: Constants.FlickrParamValue.ValuePerPage,
            Constants.FlickrParamValue.ParamPage: "\(page)",
            Constants.FlickrParamValue.ParamLat: "\(coordinate.latitude)",
            Constants.FlickrParamValue.ParamLon: "\(coordinate.longitude)"
        ]
        
        let urlString = "https://api.flickr.com/services/rest/" + formatParameters(methodArguments)
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        
        let task = sharedSession.dataTaskWithRequest(request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(error: String) {
                print(error)
            }
            
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }

            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String where stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            
            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Pages)' in \(parsedResult)")
                return
            }
            
            var urlArray:[String] = []
            
            if totalPages != 0 {
                guard let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                    displayError("Cannot find key '\(Constants.FlickrResponseKeys.Total)' in \(photosDictionary)")
                    return
                }
                
                for photo in photoArray {
                    let url = photo["url_m"] as! String
                    urlArray.append(url)
                }
                
            }
            
            completionHandler(totalPages:totalPages, urlArray: urlArray)
            
        }
        
        task.resume()
    }
    
    
    func getFlickrPhoto(photoURL:String, completion:(data:NSData)->Void) {
        
        /* 1. Set the parameters */
        
        /* 2. Build the URL */
        
        /* 3. Configure the request */
        let request = NSURLRequest(URL: NSURL(string: photoURL)!)
        
        let session = NSURLSession.sharedSession()
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            // No need, the data is already raw image data.
            
            /* 6. Use the data! */
            completion(data:data)
        }
        
        task.resume()
    }

    
    



    
    
    // format the parameters to the format of URL
    private func formatParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())

            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
}

