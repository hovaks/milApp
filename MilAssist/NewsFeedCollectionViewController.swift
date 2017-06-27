//
//  NewsFeedCollectionViewController.swift
//  MilApp
//
//  Created by Hovak Davtyan on 6/20/17.
//  Copyright © 2017 Hovak Davtyan. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class NewsFeedCollectionViewController: UICollectionViewController {
    
    var initialPage = 1
    var videosArray: Data?
    var newsArray: [News] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getNews(fromPage: initialPage)
        getVideos()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
    }
    
    func getVideos() {
        var videosArray: [News] = []
        Parser.getYoutube { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                do {
                    if let resultDictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? Dictionary<String, AnyObject> {
                        let items = resultDictionary["items"] as! Array<AnyObject>
                        for item in items {
                            let itemDictionary = item as! Dictionary<String, AnyObject>
                            let snippetDictionary = itemDictionary["snippet"] as! Dictionary<String, AnyObject>
                            var videoNews = News()
                            videoNews.title = snippetDictionary["title"] as? String
                            videoNews.description = snippetDictionary["description"] as? String
                            let imageDictionary = snippetDictionary["thumbnails"] as! Dictionary<String, AnyObject>
                            let imageDictionaryDefault = imageDictionary["high"] as! Dictionary<String, AnyObject>
                            if let imageURLString = imageDictionaryDefault["url"] as? String {
                                videoNews.imageURL = URL(string: imageURLString)
                            }
                            videoNews.dateCreated = Date() //snippetDictionary["publishedAt"] as? String !!!
                            videoNews.articleURL = URL(string: "youtube.com")
                            videoNews.type = .video
                            videosArray.append(videoNews)
                        }
                        self.newsArray.append(contentsOf: videosArray)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getNews(fromPage page: Int) {
        Parser.getNews(fromPage: page) { (newsResults) in
            self.newsArray.append(contentsOf: newsResults)
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let news = newsArray[indexPath.row]
        if indexPath.row == newsArray.count - 5 {
            initialPage += 1
            getNews(fromPage: initialPage)
        }
        
        //Defining the Reuse Identifier
        var reuseIdentifier = ""
        switch news.type {
        case .article? :
            reuseIdentifier = "NewsCell"
        case .video?:
            reuseIdentifier = "VideoCell"
        default:
            break
        }
        
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
