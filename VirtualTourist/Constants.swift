//
//  FlickrAPIConstants.swift
//  Virtual Tourist
//
//  Created by Dritani on 2016-03-18.
//  Copyright © 2016 AquariusLB. All rights reserved.
//
struct Constants {
    
    // Struct responsible to hold all the parameters
    // and it's values
    //
    struct FlickrParamValue {
        
        // parameters
        static let ParamMethod: String = "method"
        static let ParamApiKey: String = "api_key"
        static let ParamSafeSearch: String = "safe_search"
        static let ParamExtras: String = "extras"
        static let ParamFormat: String = "format"
        static let ParamNoJsonCallback: String = "nojsoncallback"
        static let ParamMedia: String = "media"
        static let ParamPerPage: String = "per_page"
        static let ParamMinUploadDate: String = "min_upload_date"
        static let ParamMaxUploadDate: String = "max_upload_date"
        static let ParamPage: String = "page"
        static let ParamLat: String = "lat"
        static let ParamLon: String = "lon"
        
        // values
        static let ValueMethod: String = "flickr.photos.search"
        static let ValueApiKey: String = "f75c8ee161f2dd75de9bec0e6b8ef41f"
        static let ValueSafeSearch: String = "1"
        static let ValueExtras: String = "url_m"
        static let ValueFormat: String = "json"
        static let ValueNoJsonCallback: String = "1"
        static let ValueMedia = "photos"
        static let ValuePerPage = "9"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
    
    // struct response to hold all JSON tags
    // and expected values
    //
    struct FlickrJSON {

        // json tags
        static let TagId: String = "id"
        static let TagUrlM: String = "url_m"
        static let TagPhotos: String = "photos"
        static let TagPhoto: String = "photo"
        static let TagStat: String = "stat"
        static let TagPages: String = "pages"
        
        // expected values
        static let StatOk: String = "ok"
    }
}