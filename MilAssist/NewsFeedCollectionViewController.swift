//
//  NewsFeedCollectionViewController.swift
//  MilApp
//
//  Created by Hovak Davtyan on 6/20/17.
//  Copyright © 2017 Hovak Davtyan. All rights reserved.
//

import UIKit

private var reuseIdentifier = "Cell"

class NewsFeedCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorView: UIView!
    var setCounter = 0
    
    var refresher: UIRefreshControl!
    let imageCache = NSCache<NSString, AnyObject>()
    
    var newsArray: [News] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.refresher.endRefreshing()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting the UI Refresher
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Refreshing")
        refresher.addTarget(self, action: #selector(self.populate), for: UIControlEvents.valueChanged)
        collectionView?.insertSubview(refresher, at: 0)
        
        
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        populate()
        
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        } //???? Recheck
        
        if !activityIndicator.isAnimating {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }// Taftalogia
            
        }
    }
    
    @objc private func populate() {
        
        newsArray = []
        
        getNews(toPage: 3) { newResults in
            self.newsArray = newResults
            self.newsArray.sort{ $0.dateCreated! > $1.dateCreated! }
        }
    }
    
    func getNews(toPage page: Int, completionHandler: @escaping ([News]) -> Void) {
        
        var newNewsArray: [News] = []
        let downloadGroup = DispatchGroup()
        downloadGroup.enter()
        Parser.getYoutube { videoResults, response, error in
            if error != nil {
                print(error!)
            } else {
                downloadGroup.leave()
                newNewsArray.append(contentsOf: videoResults)
            }
        }
        
        for page in 1...page {
            downloadGroup.enter()
            Parser.getNews(fromPage: page) { newsResults, response, error in
                if error != nil {
                    print(error!)
                } else {
                    downloadGroup.leave()
                    newNewsArray.append(contentsOf: newsResults)
                }
            }
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) {
            completionHandler(newNewsArray)
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newsSegue" {
            let destintaion = segue.destination as! NewsViewController
            if let indexPaths = collectionView?.indexPathsForSelectedItems {
                for indexPath in indexPaths {
                let news = newsArray[indexPath.row]
                destintaion.articleURL = news.articleURL
                }
            }
            
                print("segueing")
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Defining the Reuse Identifier
        let news = newsArray[indexPath.row]
        switch news.type {
        case .article? :
            reuseIdentifier = "NewsCell"
        case .video?:
            reuseIdentifier = "VideoCell"
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
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 20
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
    
}
