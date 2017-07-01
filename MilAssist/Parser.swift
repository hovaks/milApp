//
//  Parser.swift
//  MilApp
//
//  Created by Hovak Davtyan on 6/22/17.
//  Copyright © 2017 Hovak Davtyan. All rights reserved.
//

import UIKit

struct Parser {
    
    static func getYoutube(completionHandler: @escaping ([News], URLResponse?, Error?) -> Void) {
        
        var videosArray: [News] = []
        
        let urlString = "https://www.googleapis.com/youtube/v3/search?key=AIzaSyC3fha2JJYQ1-mEC97qbhcyIWLJEUMti2Y&channelId=UCH5dvlXECL-WSLwWsXl4_eg&part=snippet,id&order=date&maxResults=50"
        
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    if let newsFeedCollectionViewController = UIApplication.shared.keyWindow?.rootViewController as? NewsFeedCollectionViewController {
                        DispatchQueue.main.async {
                            newsFeedCollectionViewController.activityIndicator.stopAnimating()
                            newsFeedCollectionViewController.view.bringSubview(toFront: newsFeedCollectionViewController.errorView)
                            newsFeedCollectionViewController.errorView.isHidden = false
                        }
                    }
                    print(error)
                } else {
                    do {
                        if let resultDictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? Dictionary<String, AnyObject> {
                            let items = resultDictionary["items"] as! Array<AnyObject>
                            for item in items {
                                
                                let itemDictionary = item as! Dictionary<String, AnyObject>
                                let snippetDictionary = itemDictionary["snippet"] as! Dictionary<String, AnyObject>
                                
                                //Chech Date, if in range get other values and append
                                let calendar = Calendar.current
                                let weekEarlier = calendar.date(byAdding: .day, value: -8, to: Date())
                                if let dateCreatedString = snippetDictionary["publishedAt"] as? String {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                    if let dateCreated = dateFormatter.date(from: dateCreatedString) {
                                        if dateCreated > weekEarlier! {
                                            var videoNews = News()
                                            //Setting Date, Title, Description
                                            videoNews.dateCreated = dateCreated
                                            videoNews.title = snippetDictionary["title"] as? String
                                            videoNews.description = snippetDictionary["description"] as? String
                                            //Setting imageURL
                                            let imageDictionary = snippetDictionary["thumbnails"] as! Dictionary<String, AnyObject>
                                            let imageDictionaryDefault = imageDictionary["high"] as! Dictionary<String, AnyObject>
                                            if let imageURLString = imageDictionaryDefault["url"] as? String {
                                                videoNews.imageURL = URL(string: imageURLString)
                                            }
                                            //Setting Article URL
                                            let itemDictionary = item as! Dictionary<String, AnyObject>
                                            let idDictionary = itemDictionary["id"] as! Dictionary<String, AnyObject>
                                            if let videoId = idDictionary["videoId"] as? String {
                                                var articleURLString = "https://www.youtube.com/watch?v="
                                                articleURLString.append("\(videoId)")
                                                videoNews.articleURL = URL(string: articleURLString)
                                            }
                                            //Setting The Type and appending
                                            videoNews.type = .video
                                            videosArray.append(videoNews)
                                        }
                                    }
                                }
                            }
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    DispatchQueue.main.async {
                        completionHandler(videosArray, response, error)
                    }
                }
                }.resume()
        }
    }

    static func getNews(fromPage page:Int, completionHandler: @escaping ([News], URLResponse?, Error?) -> Void) {
        
        var resultsArray:[News] = []
        let armenianDateDictionary = [
            "Հունվարի": 1,
            "Փետրվարի": 2,
            "Մարտի": 3,
            "Ապրիլի": 4,
            "Մայիսի": 5,
            "Հունիսի": 6,
            "Հուլիսի": 7,
            "Օգոստոսի": 8,
            "Սեպտեմբերի": 9,
            "Հոկտեմբերի": 10,
            "Նոյեմբերի": 11,
            "Դեկտեմբերի": 12
        ]
        
        if let url = URL(string: "http://www.mil.am/hy/news/page/\(page)") {
            var request = URLRequest(url: url)
            request.timeoutInterval = 20
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    if let newsFeedCollectionViewController = UIApplication.shared.keyWindow?.rootViewController as? NewsFeedCollectionViewController {
                        DispatchQueue.main.async {
                            newsFeedCollectionViewController.activityIndicator.stopAnimating()
                            newsFeedCollectionViewController.view.bringSubview(toFront: newsFeedCollectionViewController.errorView)
                            newsFeedCollectionViewController.errorView.isHidden = false
                        }
                    }
                    print(error)
                } else if let unwrappedData = data {
                    let dataString = String(data: unwrappedData, encoding: .utf8)
                    if let newsContainers = dataString?.components(separatedBy: "<div class=\"col-xs-12 col-sm-6 cont_new\">") {
                        let containersCount = newsContainers.count
                        for newsContainer in newsContainers[1..<containersCount] {
                            
                            //Chech Date, if in range get other values and append
                            var dateContainer = newsContainer.components(separatedBy: "<img src=\"pics/calendar.svg\">")
                            dateContainer = dateContainer[1].components(separatedBy: "<div>")
                            dateContainer = dateContainer[1].components(separatedBy: "</div>")
                            let dateStringArmenianSeperated = dateContainer[0].components(separatedBy: " ")
                            
                            //Create Date Components
                            var components = DateComponents()
                            components.day = Int(dateStringArmenianSeperated[0])
                            components.month = armenianDateDictionary[dateStringArmenianSeperated[1]]
                            components.year = Int(dateStringArmenianSeperated[2])
                            
                            //Check Range
                            let calendar = Calendar.current
                            let weekEarlier = calendar.date(byAdding: .day, value: -8, to: Date())
                            let date = calendar.date(from: components)
                            if date! > weekEarlier! {
                                
                                //Parse Image URL
                                var imageContainer = newsContainer.components(separatedBy: "<img src=\"")
                                imageContainer = imageContainer[1].components(separatedBy: "class=\"img-responsive img1\">")
                                imageContainer = imageContainer[0].components(separatedBy: "\" ")
                                let imageURL = URL(string:"http://www.mil.am/" + imageContainer[0])
                                
                                //Parse Article URL
                                var URLContainer = newsContainer.components(separatedBy: "<a href=\"")
                                URLContainer = URLContainer[1].components(separatedBy: "\">")
                                let articleURL = URL(string:"http://www.mil.am/" + URLContainer[0])
                                
                                //Parse Title
                                var titleContainer = newsContainer.components(separatedBy: "\(URLContainer[0])\">")
                                titleContainer = titleContainer[1].components(separatedBy: "</div>")
                                titleContainer = titleContainer[0].components(separatedBy: "</a>")
                                titleContainer = titleContainer[0].components(separatedBy: "\t")
                                var title = ""
                                for entry in titleContainer {
                                    if entry != "" {
                                        title = entry
                                    }
                                }
                                titleContainer = title.components(separatedBy: "\n")
                                title = titleContainer[0]
                                
                                //Parse Description
                                var descriptionContainer = newsContainer.components(separatedBy: "<div class=\"new1_text\">")
                                descriptionContainer = descriptionContainer[1].components(separatedBy: "</div>")
                                descriptionContainer = descriptionContainer[0].components(separatedBy: "</a>")
                                descriptionContainer = descriptionContainer[0].components(separatedBy: "\t")
                                var description = ""
                                for entry in descriptionContainer {
                                    if entry != "" {
                                        description = entry
                                    }
                                }
                                descriptionContainer = description.components(separatedBy: "\n")
                                description = descriptionContainer[0]
                                
                                //Create News
                                let newsEntry = News(imageURL: imageURL,
                                                     dateCreated:date,
                                                     articleURL: articleURL,
                                                     title: title, description: description,
                                                     type: .article)
                                
                                //Append
                                resultsArray.append(newsEntry)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        completionHandler(resultsArray, response, error)
                    }
                }
                }.resume()
        }
    }
    
    func getArticleByURL(url: URL?) -> News {
        return News()
    }
}
