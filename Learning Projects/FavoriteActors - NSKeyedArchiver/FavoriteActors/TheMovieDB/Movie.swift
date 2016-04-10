//
//  Movie.swift
//  TheMovieDB
//
//  Created by Jason on 1/11/15.
//

import UIKit

class Movie: NSObject, NSCoding {
    
    struct Keys {
        static let Title = "title"
        static let PosterPath = "poster_path"
        static let ReleaseDate = "release_date"
    }
    
    var title = ""
    var id = 0
    var posterPath: String? = nil
    var releaseDate: NSDate? = nil
        
    init(dictionary: [String : AnyObject]) {
        title = dictionary[Keys.Title] as! String
        id = dictionary[TheMovieDB.Keys.ID] as! Int
        posterPath = dictionary[Keys.PosterPath] as? String
        
        if let releaseDateString = dictionary[Keys.ReleaseDate] as? String {
            releaseDate = TheMovieDB.sharedDateFormatter.dateFromString(releaseDateString)
        }
    }
    
    
    /**
        posterImage is a computed property. From outside of the class is should look like objects
        have a direct handle to their image. In fact, they store them in an imageCache. The
        cache stores the images into the documents directory, and keeps a resonable number of
        them in memory.
    */
    
    var posterImage: UIImage? {
        
        get {
            return TheMovieDB.Caches.imageCache.imageWithIdentifier(posterPath)
        }
        
        set {
            TheMovieDB.Caches.imageCache.storeImage(newValue, withIdentifier: posterPath!)
        }
    }
    
    func encodeWithCoder(archiver: NSCoder) {
        
        // archive the information inside the Person, one property at a time
        archiver.encodeObject(name, forKey: Keys.Name)
        archiver.encodeObject(id, forKey: Keys.ID)
        archiver.encodeObject(imagePath, forKey: Keys.ProfilePath)
        archiver.encodeObject(movies, forKey: Keys.Movies)
    }
    
    required init(coder unarchiver: NSCoder) {
        super.init()
        
        // Unarchive the data, one property at a time
        name = unarchiver.decodeObjectForKey(Keys.Name) as! String
        id = unarchiver.decodeObjectForKey(Keys.ID) as! Int
        imagePath = unarchiver.decodeObjectForKey(Keys.ProfilePath) as! String
        movies = unarchiver.decodeObjectForKey(Keys.Movies) as! [Movie]
    }
    
}



