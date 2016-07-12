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

    override func viewWillAppear(animated: Bool) {
        
        //configureSearchController()
        configureCustomSearchController()
        
        // Changing the Navigation bar look
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        
        spinner.hidden = true
        
        // Changing the Back button in the Navigation bar look
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "GillSans", size: 18)!], forState: UIControlState.Normal)
        navigationItem.backBarButtonItem = backButton
        
        // Checking if the user has a connection to internet
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LibraryTableViewController.networkStatusChanged(_:)), name: ReachabilityStatusChangedNotification, object: nil)
        Reach().monitorReachabilityChanges()
        
        
    }
    
    // Checking connection with help from Reach class
    func networkStatusChanged(notification: NSNotification) {
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline: // If user is offline, an Alert will appear
           // print("Not connected")
            let alert = UIAlertController(title: "Alert", message: "No Internet Connection Available", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        case .Online(.WWAN): // If user is online, then featured books are loaded
           // print("Connected via WWAN")
            if !featuredLoaded {
                loadFeatBooks(featPage)
            }
        case .Online(.WiFi): // If user is online, then featured books are loaded
           // print("Connected via WiFi")
            if !featuredLoaded {
                loadFeatBooks(featPage)
            }
        }
    }
    
    // Setting up the custom search bar look
    func configureCustomSearchController() {
        // Calling function from CustomSearchController class to define postition, size, font, color and background
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRectMake(0.0, 0.0, tableView.frame.size.width, 50.0), searchBarFont: UIFont(name: "GillSans", size: 16.0)!, searchBarTextColor: UIColor (colorLiteralRed: 197.0/255, green: 128.0/255, blue: 217.0/255, alpha: 1.0), searchBarTintColor: UIColor.darkGrayColor())
        
        customSearchController.customSearchBar.placeholder = "Search books..."
        customSearchController.customDelegate = self
        customSearchController.dimsBackgroundDuringPresentation = false
        
        // Changing Cancel button look
        for sView in customSearchController.customSearchBar.subviews {
            for ssView in sView.subviews {
                if ssView.isKindOfClass(UIButton.self) {
                    let cancelButton = ssView as! UIButton
                    cancelButton.setTitle("Cancel", forState: .Normal)
                    cancelButton.titleLabel?.font = UIFont(name: "GillSans", size: 16.0)
                    break
                }
            }
        }
        // Adding search bar to tableView
        tableView.tableHeaderView = customSearchController.customSearchBar
    }
   
    /* Default SearchController 
     func configureSearchController() {
        
        //searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        
        tableView.tableHeaderView = searchController.searchBar
        
    } */
    
    // Loading list of Featured Books from API with help from RestApiManager class
    func loadFeatBooks(page: Int) {
        // Showing loading feedback to user
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Loading"
        
        // Calling RestApiManager function to get books array
        RestApiManager.sharedInstance.getAPIBooks(page) { (json: JSON) in
            if let results = json["books"].array {
                for entry in results {
                    self.featuredItems.append(BookObject(json: entry))
                }
                dispatch_async(dispatch_get_main_queue(),{ //Updating the UI asynchronously
                    self.featPage += 50 // Adding 50 to load the next page in the results
                    self.tableView.reloadData()
                    self.spinner.stopAnimating()
                    self.isLoadingData = false
                    self.spinner.hidden = true
                    self.featuredLoaded = true
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Hide loading feedback
                })
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    // Loading data to tableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Book Cell") //Reusing identifier for smooth scroll
        let book: BookObject
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Book Cell")
        }
        
        if shouldShowSearchResults {
            book = self.searchedItems[indexPath.row]
        } else {
            book = self.featuredItems[indexPath.row]
        }
        // Downloading book cover image  with Kingfisher, showing a placeholder image while the book cover is loaded, for better perfomance
        cell?.imageView!.kf_setImageWithURL(NSURL(string: book.coverURL)!, placeholderImage: UIImage(named: "placeholder"))
        cell!.textLabel?.text = book.title
        cell!.textLabel!.font =  UIFont(name: "GillSans", size: 15)
        return cell!
    
    }
    // Loading more data to tableView when user reaches the bottom of the table
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
       
        if !isLoadingData && indexPath.row == featPage - 1 {
            self.spinner.hidden = false
            spinner.startAnimating()
            isLoadingData = true
            loadFeatBooks(featPage)
        }
        if !isLoadingSearch && indexPath.row == searchPerPage - 1 {
            self.spinner.hidden = false
            spinner.startAnimating()
            isLoadingSearch = true
            reloadSearch(searchTerm)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
                let alert = UIAlertController(title: "Alert", message: "No Results Were Found", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
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
        RestApiManager.sharedInstance.getAPISearch(searchTerm,searchPage: searchPerPage) { (json: JSON) in
            if let results = json["books"].array {
                for entry in results {
                    self.searchedItems.append(BookObject(json: entry))
                }
                
                dispatch_async(dispatch_get_main_queue(),{ // Updating the UI asynchronously
                    self.tableView.reloadData()
                    self.searchPerPage += 50 // Adding 50 to load the next page in the results
                    self.spinner.hidden = true
                    
                })
                
            }
        }
    }
    // Searching for more results in the tableView, with help from RestApiManager class
    func reloadSearch(searchText: String){
        shouldShowSearchResults = true
       
        RestApiManager.sharedInstance.getAPISearch(searchTerm,searchPage: searchPerPage) { (json: JSON) in
            if let results = json["books"].array {
                
                for entry in results {
                    self.searchedItems.append(BookObject(json: entry))
                }
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.searchPerPage += 50
                    self.tableView.reloadData()
                    self.spinner.stopAnimating()
                    self.isLoadingSearch = false
                    self.spinner.hidden = true
                })
                
            }
        }
    }
    
    /* Default UISearchBar delegate
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView.reloadData()
    }
    */
   
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController. Sending selected book object to DetailViewController to display corresponding book details
        
        customSearchController.active = false
        
        if segue.identifier == "ShowDetailSegue"{
            
            if let indexPath = self.tableView.indexPathForSelectedRow{
                let object = self.bookAtIndexPath(indexPath)
                let controller = segue.destinationViewController as! DetailViewController
                controller.book = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
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