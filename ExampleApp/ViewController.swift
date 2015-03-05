//
//  ViewController.swift
//  ExampleApp
//
//  Created by Samuel Goodwin on 3/5/15.
//  Copyright (c) 2015 Roundwall Software. All rights reserved.
//

import UIKit

extension Int {
    func doStuff() {
        println("This is cool!")
    }
}

protocol CategoriesDelegate {
    func categoriesDidChange()
}

class Categories {
    private var objects: [String] = []
    var delegate: CategoriesDelegate?
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    var count: Int {
        get {
            return objects.count
        }
    }
    
    subscript(index: Int) -> String {
        return objects[index]
    }
    
    func loadThing() {
        let request = NSURLRequest(URL: NSURL(string: "https://staging.travelbird.nl/api/v5/categories/?site=1")!)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSArray
            for item in json {
                if let name = item["name"] as? String {
                    if let type = item["type"] as? String {
                        self.objects.append(name + type)
                    }
                }
                
                // println(name) // This does not exist outside the "if let" statement
                
                if let name = item["name"] as? Int {
                    // This will never happen because our API will only give Strings, but just in case...
                    self.objects.append("\(name)")
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.delegate?.categoriesDidChange()
                return
            })
        })
        task.resume()
    }
}

class ViewController: UITableViewController, CategoriesDelegate {
    let objects = Categories()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        objects.delegate = self
        objects.loadThing()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        cell.textLabel!.text = objects[indexPath.row]
        
        return cell
    }
    
    func categoriesDidChange() {
        tableView.reloadData()
    }
}

