//
//  DetailViewController.swift
//  BookCatalogue
//
//  Created by melisadlg on 6/30/16.
//  Copyright © 2016 MelisaDlg. All rights reserved.
//
//  Book Details View class

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var bookIMG: UIImageView!
    @IBOutlet var bookTitle: UILabel!
    @IBOutlet var bookAuthor: UILabel!
    @IBOutlet var bookPublisher: UILabel!
    @IBOutlet var bookISBN: UILabel!
    @IBOutlet var bookDesc: UITextView!
    
    var data : NSData?
    var book : BookObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Changing the Navigation bar look
        let nav = self.navigationController?.navigationBar
		nav?.barStyle = UIBarStyle.black
        
        // image data
        let url = URL(string: (book?.coverURL)!)
		do {
			data = try Data(contentsOf: url!) as NSData
		} catch {
			print("there was an error getting the image")
		}
		bookIMG?.image = UIImage(data: data! as Data)
        
        // title data
        let title = "Title: "
        var titleName = title
        titleName += (book?.title)!
        bookTitle.text = titleName
        
        // author data
        let author = "Author: "
        var firstName = author
        firstName += (book?.authorF)!
        var lastName = firstName
        let space = " "
        lastName += space
        lastName += (book?.authorL)!
        bookAuthor.text = lastName
        
        // publisher data
        let publisher = "Publisher: "
        var publisherName = publisher
        publisherName += (book?.publisher)!
        bookPublisher.text = publisherName
        
        // ISBN data
        let isbn = "ISBN: "
        var isbnData = isbn
        isbnData += (book?.isbn)!
        bookISBN.text = isbnData
        
        // description data
        bookDesc.text = (book?.desc)!
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
