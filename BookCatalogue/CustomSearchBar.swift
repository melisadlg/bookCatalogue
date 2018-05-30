//
//  CustomSearchBar.swift
//  BookCatalogue
//
//  Created by melisadlg on 7/01/16.
//  Copyright © 2016 MelisaDlg. All rights reserved.
//
//  Custom Search Bar class

import UIKit

class CustomSearchBar: UISearchBar {
    
    var preferredFont: UIFont!
    
    var preferredTextColor: UIColor!
    
    // Custom look & feel for the SearchBar
	override func draw(_ rect: CGRect) {
        // Find the index of the search field in the search bar subviews
        if let index = indexOfSearchFieldInSubviews() {
            // Access the search field
            let searchField: UITextField = (subviews[0] ).subviews[index] as! UITextField
            
            // Setting frame, font, text color and background of the search field
			searchField.frame = CGRect(x: 5.0, y: 5.0, width: frame.size.width - 10.0, height: frame.size.height - 10.0)
            searchField.font = preferredFont
            searchField.textColor = preferredTextColor
            searchField.backgroundColor = barTintColor
        }
        
		let startPoint = CGPoint(x: 0.0, y: frame.size.height)
		let endPoint = CGPoint(x: frame.size.width, y: frame.size.height)
        let path = UIBezierPath()
		path.move(to: startPoint)
		path.addLine(to: endPoint)
        
        let shapeLayer = CAShapeLayer()
		shapeLayer.path = path.cgPath
		shapeLayer.strokeColor = preferredTextColor.cgColor
        shapeLayer.lineWidth = 2.5
        
        layer.addSublayer(shapeLayer)
        
		super.draw(rect)
    }
    
    
    
    init(frame: CGRect, font: UIFont, textColor: UIColor) {
        super.init(frame: frame)
        
        self.frame = frame
        preferredFont = font
        preferredTextColor = textColor
        
		searchBarStyle = UISearchBarStyle.prominent
		isTranslucent = false
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func indexOfSearchFieldInSubviews() -> Int! {
        var index: Int!
        let searchBarView = subviews[0]
        
        for i in 0 ..< searchBarView.subviews.count {
			if searchBarView.subviews[i] is UITextView {
                index = i
                break
            }
        }
        
        return index
    }
}
