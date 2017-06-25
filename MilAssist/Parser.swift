//
//  Parser.swift
//  MilApp
//
//  Created by Hovak Davtyan on 6/22/17.
//  Copyright © 2017 Hovak Davtyan. All rights reserved.
//

import UIKit

struct Parser {
    
    static func getNews(fromPage page:Int, withHandler completion: @escaping ([News]) -> ()) {
        var resultsArray:[News] = []
        if let url = URL(string: "http://www.mil.am/hy/news/page/\(page)") {
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print(error)
                } else if let unwrappedData = data {
                    let dataString = String(data: unwrappedData, encoding: .utf8)
                    if let newsContainers = dataString?.components(separatedBy: "<div class=\"col-xs-12 col-sm-6 cont_new\">") {
                        let containersCount = newsContainers.count
                        for newsContainer in newsContainers[1..<containersCount] {
                            
                            //Parse Image URL
                            var imageContainer = newsContainer.components(separatedBy: "<img src=\"")
                            imageContainer = imageContainer[1].components(separatedBy: "class=\"img-responsive img1\">")
                            imageContainer = imageContainer[0].components(separatedBy: "\" ")
                            let imageURL = URL(string:"http://www.mil.am/" + imageContainer[0])
                            
                            //Parse Date
                            var dateContainer = newsContainer.components(separatedBy: "<img src=\"pics/calendar.svg\">")
                            dateContainer = dateContainer[1].components(separatedBy: "<div>")
                            dateContainer = dateContainer[1].components(separatedBy: "</div>")
                            let date = dateContainer[0]

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
                            let newsEntry = News(imageURL: imageURL, dateCreated: date, articleURL: articleURL, title: title, description: description)
                            resultsArray.append(newsEntry)
                        }
                    }
                    completion(resultsArray)
                }
            }.resume()
        }
    }
}
