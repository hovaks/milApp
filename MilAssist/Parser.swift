//
//  Parser.swift
//  MilApp
//
//  Created by Hovak Davtyan on 6/22/17.
//  Copyright © 2017 Hovak Davtyan. All rights reserved.
//

import UIKit

struct Parser {
    static func getYoutube(completion: @escaping (Data?, Int, Error?) -> Void) {
        let urlString = "https://www.googleapis.com/youtube/v3/search?key=AIzaSyC3fha2JJYQ1-mEC97qbhcyIWLJEUMti2Y&channelId=UCH5dvlXECL-WSLwWsXl4_eg&part=snippet,id&order=date&maxResults=50"
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print(error)
                } else {
                    DispatchQueue.main.async {
                        completion(data, (response as! HTTPURLResponse).statusCode, error)
                    }
                }
                }.resume()
        }
    }
    
    
    static func getNews(fromPage page:Int, withHandler completion: @escaping ([News]) -> Void) {
        let calendar = Calendar.current
        let weekEarlier = calendar.date(byAdding: .day, value: -8, to: Date())
        
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
            request.timeoutInterval = 15
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    if let newsFeedCollectionViewController = UIApplication.shared.keyWindow?.rootViewController as? NewsFeedCollectionViewController {
                        newsFeedCollectionViewController.activityIndicator.stopAnimating()
                        newsFeedCollectionViewController.errorView.isHidden = false
                    }
                    print(error)
                } else if let unwrappedData = data {
                    let dataString = String(data: unwrappedData, encoding: .utf8)
                    if let newsContainers = dataString?.components(separatedBy: "<div class=\"col-xs-12 col-sm-6 cont_new\">") {
                        let containersCount = newsContainers.count
                        for newsContainer in newsContainers[1..<containersCount] {
                            
                            //Parse Date
                            var dateContainer = newsContainer.components(separatedBy: "<img src=\"pics/calendar.svg\">")
                            dateContainer = dateContainer[1].components(separatedBy: "<div>")
                            dateContainer = dateContainer[1].components(separatedBy: "</div>")
                            
                            let dateStringArmenianSeperated = dateContainer[0].components(separatedBy: " ")
                            var components = DateComponents()
                            components.day = Int(dateStringArmenianSeperated[0])
                            components.month = armenianDateDictionary[dateStringArmenianSeperated[1]]
                            components.year = Int(dateStringArmenianSeperated[2])
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
                                let newsEntry = News(imageURL: imageURL, dateCreated: date, articleURL: articleURL, title: title, description: description, type: .article)
                                resultsArray.append(newsEntry)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        print("page \(page) loaded")
                        completion(resultsArray)
                    }
                }
                }.resume()
        }
    }
}
