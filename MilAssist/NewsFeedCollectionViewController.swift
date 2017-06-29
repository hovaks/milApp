//
//  NewsFeedCollectionViewController.swift
//  MilApp
//
//  Created by Hovak Davtyan on 6/20/17.
//  Copyright © 2017 Hovak Davtyan. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
var setCounter = 0

class NewsFeedCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorView: UIView!
    
    let imageCache = NSCache<NSString, AnyObject>()
    var newsArray: [News] = [] {
        didSet {
            setCounter += 1
            newsArray.sort{ $0.dateCreated! > $1.dateCreated! }
            //Check the need to reload
            if setCounter == 1 {
                activityIndicator.stopAnimating()
                collectionView?.reloadData()
                setCounter = 0
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        errorView.isHidden = true
        //getNews(toPage: 3)
        getVideos()
        if !activityIndicator.isAnimating {
            activityIndicator.startAnimating()
        }
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
                            
                            //Setting Date Range
                            let calendar = Calendar.current
                            let weekEarlier = calendar.date(byAdding: .day, value: -8, to: Date())
                            
                            //Getting Date and checking for Date Range
                            if let dateCreatedString = snippetDictionary["publishedAt"] as? String {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                if let dateCreated = dateFormatter.date(from: dateCreatedString) {
                                    if dateCreated > weekEarlier! {
                                        var videoNews = News()
                                        videoNews.dateCreated = dateCreated
                                        videoNews.title = snippetDictionary["title"] as? String
                                        videoNews.description = snippetDictionary["description"] as? String
                                        let imageDictionary = snippetDictionary["thumbnails"] as! Dictionary<String, AnyObject>
                                        let imageDictionaryDefault = imageDictionary["high"] as! Dictionary<String, AnyObject>
                                        if let imageURLString = imageDictionaryDefault["url"] as? String {
                                            videoNews.imageURL = URL(string: imageURLString)
                                        }
                                        videoNews.articleURL = URL(string: "youtube.com")
                                        videoNews.type = .video
                                        videosArray.append(videoNews)
                                    }
                                }
                            }
                        }
                        self.newsArray.append(contentsOf: videosArray)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getNews(toPage page: Int) {
        for page in 1...page {
            print("getting from page\(page)")
            Parser.getNews(fromPage: page) { newsResults in
                self.newsArray.append(contentsOf: newsResults)
            }
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
