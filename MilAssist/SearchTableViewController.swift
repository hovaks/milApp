//
//  searchTableViewController.swift
//  Banak
//
//  Created by Hovak Davtyan on 7/2/17.
//  Copyright © 2017 alfaSolutions. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    var newsArray: [News] = []
    var searchResults: [News] = []
    var searchBar: UISearchBar!
    var searchHistory: [String] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    var imageCache = NSCache<NSString, AnyObject>()
    
    //Search
    var searchText: String!
    var clickedButtonState: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Hide Navigation
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        //Get Search History
        let defaults = UserDefaults.standard
        searchHistory = (defaults.array(forKey: "SearchHistoryArray") as? [String]) ?? [""]
        searchHistory = searchHistory.reversed()
        
        searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Որոնում"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        searchBar.becomeFirstResponder()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchHistory.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "searchHistoryCell", for: indexPath) as! searchHistoryTableViewCell
        cell.searchHistoryCellLabel.text = searchHistory[indexPath.row]
     return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.text = searchHistory[indexPath.row]
        searchBarSearchButtonClicked(self.searchBar)
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "searchResultsSegue" {
                let destination = segue.destination as! NewsFeedSearchResultsCollectionViewController
                if clickedButtonState {
                    destination.newsArray = newsArray
                    destination.searchResults = searchResults
                    destination.searchHistory = searchHistory
                    destination.searchText = searchText
                    destination.imageCache = imageCache
                }
            }
        }
    }
    
    // MARK: - Search
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchText = searchBar.text
        
        //Save text for history
        let defaults = UserDefaults.standard
        searchHistory.append(searchText)
        searchHistory = searchHistory.filter { $0 != "" }
        searchHistory = searchHistory.unique()
        defaults.set(searchHistory, forKey: "SearchHistoryArray")
        
        
        if let searchTextLowerCased = searchBar.text?.lowercased() {
            for news in newsArray {
                let newsTitle = news.title?.lowercased()
                if (newsTitle?.contains(searchTextLowerCased))! {
                    searchResults.append(news)
                }
            }
            clickedButtonState = true
            dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "searchResultsSegue", sender: searchBar)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clickedButtonState = false
        dismiss(animated: false, completion: nil)
        self.navigationController?.popViewController(animated: false)
    }
    
}

    // MARK: - Extensions

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var alreadyAdded = Set<Iterator.Element>()
        return self.filter { alreadyAdded.insert($0).inserted }
    }
}
