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
    
	func getAPIBooks(tablePage: Int, onCompletion: @escaping (JSON) -> Void) {
        let route = baseURL + String(tablePage)// Completing URL with page parameters
		makeHTTPGetRequest(path: route, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
	func getAPISearch(searchText: String, searchPage: Int, onCompletion: @escaping (JSON) -> Void) {
        let route = searchURL + searchText + "/" + String(searchPage) // Completing URL with search and page parameters
		makeHTTPGetRequest(path: route, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    // MARK: Perform a GET Request
	private func makeHTTPGetRequest(path: String, onCompletion: @escaping ServiceResponse) {
		let request = URLRequest(url: URL(string: path)!)
		
		URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard let data = data else {
				return
			}
			
			do {
				let json = try JSON(data: data)
				onCompletion(json, error as NSError?)
			} catch {
				print("didnt work")
				onCompletion(JSON.null, error as NSError)

			}
			
			}.resume()
    }
    
    // MARK: Perform a GET Request
	private func makeHTTPGetRequest(path: String, body: [String: AnyObject], onCompletion: @escaping ServiceResponse) {
		var request = URLRequest(url: URL(string: path)!)

        // Set the method to GET
        request.httpMethod = "GET"
        
        do {
            // Set the GET body for the request
			let jsonBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            request.httpBody = jsonBody
			
			let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error -> Void in
				
				guard let data = data else {
					return
				}
				
				do {
					let json = try JSON(data: data)
					onCompletion(json, error as NSError?)
				} catch {
					print("didnt work")
					onCompletion(JSON.null, error as NSError)
					
				}
            })
            task.resume()
        } catch {
            onCompletion(JSON.null, nil)
        }
    }
}
