//
//  NewsFeedCollectionViewController.swift
//  MilApp
//
//  Created by Hovak Davtyan on 6/20/17.
//  Copyright © 2017 Hovak Davtyan. All rights reserved.
//

import UIKit

private var reuseIdentifier = "Cell"

class NewsFeedSearchResultsCollectionViewController: UICollectionViewController, UISearchBarDelegate {
    
    var searchResults: [News] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    var newsArray: [News] = []
    var imageCache = NSCache<NSString, AnyObject>()
    var searchHistory: [String] = []
    
    //Search
    var searchBar: UISearchBar!
    var searchText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Register Cell
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //Add SerachBar
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.text = searchText
        self.navigationItem.titleView = searchBar
    }
    
    override func willMove(toParentViewController parent:UIViewController?)
    {
        super.willMove(toParentViewController: parent)
        
        if (parent == nil) {
            if let navigationController = self.navigationController {
                var viewControllers = navigationController.viewControllers
                let viewControllersCount = viewControllers.count
                if (viewControllersCount > 2) {
                    viewControllers.remove(at: viewControllersCount - 2)
                    navigationController.setViewControllers(viewControllers, animated:false)
                }
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Defining the Reuse Identifier
        let news = searchResults[indexPath.row]
        switch news.type {
        case .article? :
            reuseIdentifier = "NewsCell"
        case .video?:
            reuseIdentifier = "VideoCell"
        case .article1000Plus?:
            reuseIdentifier = "News1000PlusCell"
        default:
            break
        }
        
        //Getting Cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if let newsCell = cell as? NewsFeedCollectionViewCell {
            
            newsCell.news = news
            
            //Set Images Using Cache
            if let imageURL = news.imageURL {
                let imageURLString = (imageURL.absoluteString) as NSString
                if let cachedImage = imageCache.object(forKey: imageURLString) as? UIImage {
                    DispatchQueue.main.async {
                        newsCell.imageView.image = cachedImage
                    }
                } else {
                    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                        if let imageData = try? Data(contentsOf: imageURL) {
                            let image = UIImage(data: imageData)
                            self?.imageCache.setObject(image!, forKey: imageURLString)
                            DispatchQueue.main.async {
                                newsCell.imageView.image = image
                                newsCell.imageLoadActivityIndicator.stopAnimating()
                            }
                            
                        }
                    }
                }
            }
        }
        
        //Set Cell Shadow
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        //Uncomment to enable round corners
        //        cell.layer.masksToBounds = true
        //        cell.layer.cornerRadius = 20
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
    // MARK: Search and UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchText = searchBar.text
        searchResults = []
        for news in newsArray {
            let newsTitle = news.title
            if (newsTitle?.contains(searchText))! {
                searchResults.append(news)
            }
        }
        
        //Save text for history
        let defaults = UserDefaults.standard
        searchHistory.append(searchText)
        searchHistory = searchHistory.filter { $0 != "" }
        searchHistory = searchHistory.unique()
        defaults.set(searchHistory, forKey: "SearchHistoryArray")
    }
    
}
