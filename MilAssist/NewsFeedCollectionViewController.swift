//
//  NewsFeedCollectionViewController.swift
//  MilApp
//
//  Created by Hovak Davtyan on 6/20/17.
//  Copyright © 2017 Hovak Davtyan. All rights reserved.
//

import UIKit
import Kingfisher
import youtube_ios_player_helper

private var reuseIdentifier = "Cell"

class NewsFeedCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var newsArray: [News] = [] {
        didSet {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.searchBarItem.isEnabled = true
                self.collectionView?.reloadData()
                self.refresher.endRefreshing()
            }
        }
    }
    
    var refresher: UIRefreshControl!
    var selectedIndex: IndexPath?
    
    //Search
    @IBOutlet weak var searchBarItem: UIBarButtonItem!
    var searchController: UISearchController!
    var searchText: String!
    
    //Autoratation Settings
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }
    
    override var shouldAutorotate: Bool {
        if globals.currentPlayer?.playerState() == .playing {
            return true
        } else {
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting the UI Refresher
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Բեռնվում է")
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
        
        if let indexPath = selectedIndex {
            if let cell = collectionView?.cellForItem(at: indexPath) as? NewsFeedCollectionViewCell {
                cell.resumeVideo()
                cell.imageView.addSubview(globals.currentPlayer!)
                if let state = globals.currentPlayer?.playerState() {
                    switch state {
                    case .paused: globals.currentPlayer?.pauseVideo()
                    case .playing: globals.currentPlayer?.playVideo()
                    default: return
                    }
                }
            }
        }
        
        let value =  UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        
        if (self.navigationController?.isNavigationBarHidden)! {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        if !activityIndicator.isAnimating {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
        }
        populate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        globals.playerMod = .normal
        print("normal Mod")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            if globals.currentPlayer?.playerState() == .playing {
                performSegue(withIdentifier: "fullScreenSegue", sender: nil)
            }
        }
    }
    
    
    
    @objc private func populate() {
        //Disable Searching
        DispatchQueue.main.async {
            self.searchBarItem.isEnabled = false
        }
        
        getNews(toPage: 3) { newResults in
            
            //Check if news have been added
            let newsResultsSorted = newResults.sorted {
                if $0.dateCreated == $1.dateCreated && $0.type != $1.type {
                    return ($0.type?.rawValue)! < ($1.type?.rawValue)!
                } else {
                    return $0.dateCreated! > $1.dateCreated!
                }
            }
            
            if self.newsArray.isEmpty || self.newsArray[0].title != newsResultsSorted[0].title {
                self.newsArray = newsResultsSorted
            } else {
                self.searchBarItem.isEnabled = true
                self.refresher.endRefreshing()
                return
            }
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
        
        downloadGroup.enter()
        Parser.get1000PlusNews(fromPage: 1) { (newsResults, respone, error) in
            downloadGroup.leave()
            newNewsArray.append(contentsOf: newsResults)
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) {
            completionHandler(newNewsArray)
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "newsSegue":
            let destintaion = segue.destination as! NewsViewController
            if let indexPaths = collectionView?.indexPathsForSelectedItems {
                for indexPath in indexPaths {
                    let news = newsArray[indexPath.row]
                    destintaion.news = news
                    destintaion.articleURL = news.articleURL
                }
            }
        case "searchSegue":
            let destintaion = segue.destination as! SearchTableViewController
            destintaion.newsArray = newsArray
            
        case "fullScreenSegue":
            if let cell = collectionView?.cellForItem(at: selectedIndex!) as? NewsFeedCollectionViewCell {
                let videoID = cell.news?.articleURL?.description
                let destination = segue.destination as! FullScreenVideoViewController
                destination.videoID = videoID
                //globals.currentPlayer?.cueVideo(byId: videoID!, startSeconds: (globals.currentPlayer?.currentTime())!, suggestedQuality: .medium)
            }
            
        default:
            break
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
        case .article1000Plus?:
            reuseIdentifier = "News1000PlusCell"
        default:
            break
        }
        
        //Getting Cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if let newsCell = cell as? NewsFeedCollectionViewCell {
            newsCell.news = news
        }
        
        //Set Cell Shadow
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? NewsFeedCollectionViewCell {
            selectedIndex = indexPath
            if !cell.playerIsConfigured {
                cell.configurePlayer()
            } else {
                if let state = globals.currentPlayer?.playerState() {
                    switch state {
                    case .paused: globals.currentPlayer?.playVideo()
                    case .playing: globals.currentPlayer?.pauseVideo()
                    default: return
                    }
                }
            }
        }
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

struct globals {
    enum PlayerMod {
        case normal
        case fullScreen
    }
    
    static var currentPlayer: YTPlayerView?
    static var playerMod: PlayerMod?
}
