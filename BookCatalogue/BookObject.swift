//
//  BookObject.swift
//  BookCatalogue
//
//  Created by melisadlg on 6/30/16.
//  Copyright © 2016 MelisaDlg. All rights reserved.
//
//  Book class

import Foundation
import SwiftyJSON

class BookObject {
    var coverURL: String!
    var title: String!
    var authorF: String!
    var authorL: String!
    var publisher: String!
    var isbn: String!
    var desc: String!
    
    // Feeding Book from API with SwiftyJSON
    required init(json: JSON) {
        coverURL = json["cover_url"].stringValue
        title = json["title"].stringValue
        authorF = json["author"]["first_name"].stringValue
        authorL = json["author"]["last_name"].stringValue
        publisher = json["publisher"]["name"].stringValue
        isbn = json["isbn"].stringValue
        desc = json["description"].stringValue
    }
}