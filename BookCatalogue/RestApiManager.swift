//
//  RestApiManager.swift
//  BookCatalogue
//
//  Created by melisadlg on 6/30/16.
//  Copyright © 2016 MelisaDlg. All rights reserved.
//
//  API helper class, using SwiftyJSON

import Foundation
import SwiftyJSON

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    
    let baseURL = "http://assessment.elastique.nl/books/highlighted/" // URL for Featured Books
    let searchURL = "http://assessment.elastique.nl/books/search/" // URL for Searching Books
    
    func getAPIBooks(tablePage: Int, onCompletion: (JSON) -> Void) {
        let route = baseURL + String(tablePage)// Completing URL with page parameters
        makeHTTPGetRequest(route, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    func getAPISearch(searchText: String, searchPage: Int, onCompletion: (JSON) -> Void) {
        let route = searchURL + searchText + "/" + String(searchPage) // Completing URL with search and page parameters
        makeHTTPGetRequest(route, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    // MARK: Perform a GET Request
    private func makeHTTPGetRequest(path: String, onCompletion: ServiceResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let jsonData = data {
                let json:JSON = JSON(data: jsonData)
                onCompletion(json, error)
            } else {
                onCompletion(nil, error)
            }
        })
        task.resume()
    }
    
    // MARK: Perform a GET Request
    private func makeHTTPGetRequest(path: String, body: [String: AnyObject], onCompletion: ServiceResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        // Set the method to GET
        request.HTTPMethod = "GET"
        
        do {
            // Set the GET body for the request
            let jsonBody = try NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted)
            request.HTTPBody = jsonBody
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                if let jsonData = data {
                    let json:JSON = JSON(data: jsonData)
                    onCompletion(json, nil)
                } else {
                    onCompletion(nil, error)
                }
            })
            task.resume()
        } catch {
            onCompletion(nil, nil)
        }
    }
}