//
//  CustomSearchController.swift
//  BookCatalogue
//
//  Created by melisadlg on 7/01/16.
//  Copyright © 2016 MelisaDlg. All rights reserved.
//
//  Custom Search Bar class

import UIKit

protocol CustomSearchControllerDelegate { // Custom Delegate functions
    func didStartSearching()
    
    func didTapOnSearchButton()
    
    func didTapOnCancelButton()
    
    func didChangeSearchText(searchText: String)
    
    func didEndEditing(searchBar: UISearchBar)
}

class CustomSearchController: UISearchController, UISearchBarDelegate {
    
    var customSearchBar: CustomSearchBar!
    
    var customDelegate: CustomSearchControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Initialization
    
    init(searchResultsController: UIViewController!, searchBarFrame: CGRect, searchBarFont: UIFont, searchBarTextColor: UIColor, searchBarTintColor: UIColor) {
        super.init(searchResultsController: searchResultsController)
        
        configureSearchBar(searchBarFrame, font: searchBarFont, textColor: searchBarTextColor, bgColor: searchBarTintColor)
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: Custom function for look & feel
    
    func configureSearchBar(frame: CGRect, font: UIFont, textColor: UIColor, bgColor: UIColor) {
        customSearchBar = CustomSearchBar(frame: frame, font: font , textColor: textColor)
        
        customSearchBar.barTintColor = bgColor
        customSearchBar.tintColor = textColor
        customSearchBar.showsBookmarkButton = false
        customSearchBar.showsCancelButton = true
        customSearchBar.delegate = self
    }
    
    // MARK: UISearchBarDelegate functions
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        customDelegate.didStartSearching()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        customSearchBar.resignFirstResponder()
        customDelegate.didTapOnSearchButton()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        customSearchBar.resignFirstResponder()
        customSearchBar.text = ""
        customDelegate.didTapOnCancelButton()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        customDelegate.didChangeSearchText(searchText)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar){
        customSearchBar.resignFirstResponder()
        customSearchBar.text = customSearchBar.text
        customDelegate.didEndEditing(searchBar)
    }

}