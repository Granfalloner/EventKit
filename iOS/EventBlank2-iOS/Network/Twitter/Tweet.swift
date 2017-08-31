//
//  TweetModel.swift
//  Twitter_test
//
//  Created by Marin Todorov on 6/18/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

import RealmSwift

class Tweet: Object {
    
    //basic properties
    dynamic var id: Int32 = 0
    dynamic var text = ""
    dynamic var userId: Int32 = 0

    //dynamic properties
    var _created: TimeInterval = 0
    var _url: String?
    var _imageUrl: String?
    
    var created: Date {
        set {
            _created = newValue.timeIntervalSince1970
        }
        get {
            return Date(timeIntervalSince1970: _created)
        }
    }
    
    var url: URL? {
        set {
            _url = newValue?.absoluteString
        }
        get {
            guard let url = _url else {
                return nil
            }
            return URL(string: url)
        }
    }
    
    var imageUrl: URL? {
        set {
            _imageUrl = newValue?.absoluteString
        }
        get {
            guard let imageUrl = _imageUrl else {
                return nil
            }
            return URL(string: imageUrl)
        }
    }
    
    dynamic var user: TwitterUser?
    
    static override func ignoredProperties() -> [String] {
        return ["created", "url", "imageUrl"]
    }
    
    static let twitterDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        return formatter
    }()
    
    convenience init?(jsonObject obj: JSON) {
        self.init()
        
        //required properties
        guard let created = obj["created_at"].string,
            let createdDate = Tweet.twitterDateFormatter.date(from: created),
            let id = obj["id"].int32,
            let text = obj["text"].string,
            let userId = obj["user"]["id"].int32,
            let user = TwitterUser(jsonObject: obj["user"])
        else {
            return nil
        }
        
        self.created = createdDate
        self.id = id
        self.text = text
        self.userId = userId
        self.user = user
        
        //url
        if let urlValue = obj["entities"]["urls"][0]["expanded_url"].string {
            url = URL(string: urlValue)
        }
        
        //image
        if let media = obj["extended_entities"]["media"].arrayObject as NSArray?,
            let photoDict = media.filtered(using: NSPredicate(format: "type == 'photo'", argumentArray: [])).first as? NSDictionary,
            let urlValue = photoDict["media_url_https"] as? String {
                imageUrl = URL(string: urlValue)
        }
    }
}
