//
//  LibraryTableViewController.swift
//  BookCatalogue
//
//  Created by melisadlg on 6/30/16.
//  Copyright © 2016 MelisaDlg. All rights reserved.
//
//  Table Controller class

import UIKit
import SwiftyJSON
import Kingfisher
import MBProgressHUD

class LibraryTableViewController: UITableViewController, UISearchBarDelegate, CustomSearchControllerDelegate {
  
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var isLoadingData = false
    var isLoadingSearch = false
    var shouldShowSearchResults = false
    var featuredLoaded = false
    
    var featuredItems = [BookObject]() // Array of type BookObject for featured books
    var searchedItems = [BookObject]() // Array of type BookObject for searched books
   
    var customSearchController: CustomSearchController! // Custom UISearchController
    
    var featPage = 0
    var searchPerPage = 0
    var searchTerm = String()
    
    var hud: MBProgressHUD = MBProgressHUD() // Loading message
    
    //var searchController:UISearchController! // Default UISearchController

	override func viewWillAppear(_ animated: Bool) {
        
        //configureSearchController()
        configureCustomSearchController()
        
        // Changing the Navigation bar look
        let nav = self.navigationController?.navigationBar
		nav?.barStyle = UIBarStyle.black
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        
        spinner.isHidden = true

		loadFeatBooks(page: featPage)
        
        // Changing the Back button in the Navigation bar look
		let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: nil)
		backButton.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "GillSans", size: 18)!], for: UIControlState.normal)
        navigationItem.backBarButtonItem = backButton
    }
	
    // Setting up the custom search bar look
    func configureCustomSearchController() {
        // Calling function from CustomSearchController class to define postition, size, font, color and background
		customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 50.0), searchBarFont: UIFont(name: "GillSans", size: 16.0)!, searchBarTextColor: UIColor(red: 197.0/255, green: 128.0/255, blue: 217.0/255, alpha: 1.0), searchBarTintColor: UIColor.darkGray)
        
        customSearchController.customSearchBar.placeholder = "Search books..."
        customSearchController.customDelegate = self
        customSearchController.dimsBackgroundDuringPresentation = false
        
        // Changing Cancel button look
        for sView in customSearchController.customSearchBar.subviews {
            for ssView in sView.subviews {
                if ssView is UIButton {
                    let cancelButton = ssView as! UIButton
					cancelButton.setTitle("Cancel", for: .normal)
                    cancelButton.titleLabel?.font = UIFont(name: "GillSans", size: 16.0)
                    break
                }
            }
        }
        // Adding search bar to tableView
        tableView.tableHeaderView = customSearchController.customSearchBar
    }
    
    // Loading list of Featured Books from API with help from RestApiManager class
    func loadFeatBooks(page: Int) {
        // Showing loading feedback to user
		let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
		loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        
        // Calling RestApiManager function to get books array
		RestApiManager.sharedInstance.getAPIBooks(tablePage: page) { (json: JSON) in
            if let results = json["books"].array {
                for entry in results {
                    self.featuredItems.append(BookObject(json: entry))
                }
				DispatchQueue.main.async { //Updating the UI asynchronously
                    self.featPage += 50 // Adding 50 to load the next page in the results
                    self.tableView.reloadData()
                    self.spinner.stopAnimating()
                    self.isLoadingData = false
					self.spinner.isHidden = true
                    self.featuredLoaded = true
					MBProgressHUD.hide(for: self.view, animated: true)// Hide loading feedback
                }
            }
        }
    }

    // MARK: - Table view data source
    // Loading data to tableView
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		var cell = tableView.dequeueReusableCell(withIdentifier: "Book Cell") //Reusing identifier for smooth scroll
        let book: BookObject
        
        if cell == nil {
			cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Book Cell")
        }
        
        if shouldShowSearchResults {
            book = self.searchedItems[indexPath.row]
        } else {
            book = self.featuredItems[indexPath.row]
        }
        // Downloading book cover image  with Kingfisher, showing a placeholder image while the book cover is loaded, for better perfomance
		let url = URL(string: book.coverURL)!
		cell?.imageView?.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
		
        cell!.textLabel?.text = book.title
        cell!.textLabel!.font =  UIFont(name: "GillSans", size: 15)
        return cell!
    
    }
    // Loading more data to tableView when user reaches the bottom of the table
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
        if !isLoadingData && indexPath.row == featPage - 1 {
            self.spinner.isHidden = false
            spinner.startAnimating()
            isLoadingData = true
			loadFeatBooks(page: featPage)
        }
        if !isLoadingSearch && indexPath.row == searchPerPage - 1 {
            self.spinner.isHidden = false
            spinner.startAnimating()
            isLoadingSearch = true
			reloadSearch(searchText: searchTerm)
        }
    }
	
	override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return searchedItems.count
        }else {
            return featuredItems.count
        }
    }
    
    // MARK: CustomSearchControllerDelegate functions
    
    // Table is emptied in order to load new results when user starts a new search
    func didStartSearching() {
        shouldShowSearchResults = true
        searchPerPage = 0
        self.searchedItems = [BookObject] ()
        tableView.reloadData()
    }
    // Showing results in tableView
    func didTapOnSearchButton() {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
            if searchedItems.count == 0{ // If no results were found, an alert message shows up for feedback to the user
				let alert = UIAlertController(title: "Alert", message: "No Results Were Found", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        searchPerPage = 0
        tableView.reloadData()
    }
    
    func didEndEditing(searchBar: UISearchBar) {
        shouldShowSearchResults = false
    }
    
    // Loading results from search on the API with help from RestApiManager class
    func didChangeSearchText(searchText: String) {
        shouldShowSearchResults = true
        searchTerm = searchText
        
        self.searchedItems = [BookObject] ()
        self.tableView.reloadData()
        searchPerPage = 0
		RestApiManager.sharedInstance.getAPISearch(searchText: searchTerm,searchPage: searchPerPage) { (json: JSON) in
            if let results = json["books"].array {
                for entry in results {
                    self.searchedItems.append(BookObject(json: entry))
                }
                
                DispatchQueue.main.async {  // Updating the UI asynchronously
                    self.tableView.reloadData()
                    self.searchPerPage += 50 // Adding 50 to load the next page in the results
					self.spinner.isHidden = true
                    
                }
                
            }
        }
    }
    // Searching for more results in the tableView, with help from RestApiManager class
    func reloadSearch(searchText: String){
        shouldShowSearchResults = true
       
		RestApiManager.sharedInstance.getAPISearch(searchText: searchTerm,searchPage: searchPerPage) { (json: JSON) in
            if let results = json["books"].array {
                
                for entry in results {
                    self.searchedItems.append(BookObject(json: entry))
                }
                
                DispatchQueue.main.async {
                    self.searchPerPage += 50
                    self.tableView.reloadData()
                    self.spinner.stopAnimating()
                    self.isLoadingSearch = false
					self.spinner.isHidden = true
                }
                
            }
        }
    }
    
    // MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		customSearchController.isActive = false
        
        if segue.identifier == "ShowDetailSegue"{
            
            if let indexPath = self.tableView.indexPathForSelectedRow{
				let object = self.bookAtIndexPath(indexPath: indexPath as NSIndexPath)
				let controller = segue.destination as! DetailViewController
                controller.book = object
				controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = false
            }
        }
    }
    
    // Getting selected book from tableView for Segue
    func bookAtIndexPath(indexPath: NSIndexPath) -> BookObject{
        if shouldShowSearchResults {
            return searchedItems[indexPath.row]
        } else {
            return featuredItems[indexPath.row]
        }
    }
   
}
