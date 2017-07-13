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
                                if !title.contains("youtube.com") {
                                    resultsArray.append(newsEntry)
                                }
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
    
    static func getNewsContent(fromUrl url: URL, completionHandler: @escaping (Article, URLResponse?, Error?) -> Void) {
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        var text: String?
        var imageURLs = ["fullImages": [URL?](), "thumbnails": [URL?]()]
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
            } else if let unwrappedData = data {
                let dataString = String(data: unwrappedData, encoding: .utf8)
                if let newsContainer = dataString?.components(separatedBy: "<div class='stanTxt'>") {
                    var textContainer = newsContainer
                    textContainer = textContainer[1].components(separatedBy: "</div>")
                    let htmlText = textContainer[0]
                    let encodedData = htmlText.data(using: String.Encoding.utf8, allowLossyConversion: true)!
                    do {
                        text = try NSAttributedString(data: encodedData,
                                                      options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue],
                                                      documentAttributes: nil).string
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
                
                if var imageURLsContainer = dataString?.components(separatedBy: "overflow: hidden;\">") {
                    imageURLsContainer = imageURLsContainer[1].components(separatedBy: "<div u=\"thumbnavigator")
                    imageURLsContainer = imageURLsContainer[0].components(separatedBy: "<div>")
                    
                    for item in imageURLsContainer.dropFirst() {
                        let allSizeImagesContainer = item.components(separatedBy: "</div>")
                        
                        var fullImageContainer = allSizeImagesContainer[0].components(separatedBy: "<a class=\"image-par\" href=\"")
                        fullImageContainer = fullImageContainer[1].components(separatedBy: "\">")
                        let fullImageString = fullImageContainer[0]
                        let fullImageURL = URL(string: "http://www.mil.am/" + fullImageString)
                        imageURLs["fullImages"]?.append(fullImageURL)
                        
                        var thumbnailImageContainer = allSizeImagesContainer[0].components(separatedBy: "<img u=\"thumb\" src=\"")
                        thumbnailImageContainer = thumbnailImageContainer[1].components(separatedBy: "\" />")
                        let thumbnailImageString = thumbnailImageContainer[0]
                        let thumbnailImageURL = URL(string: "http://www.mil.am/" + thumbnailImageString)
                        imageURLs["thumbnails"]?.append(thumbnailImageURL)
                    }
                }
                
                let article = Article(text: text, imageURLs: imageURLs)
                
                
                DispatchQueue.main.async {
                    completionHandler(article, response, error)
                }
            }
            }.resume()
    }
    
    static func get1000PlusNews(fromPage page:Int, completionHandler: @escaping ([News], URLResponse?, Error?) -> Void) {
        
        var resultsArray:[News] = []
        let armenianDateDictionary = [
            "Հունվ": 1,
            "Փետ": 2,
            "Մար": 3,
            "Ապր": 4,
            "Մայ": 5,
            "Հուն": 6,
            "Հուլ": 7,
            "Օգոս": 8,
            "Սեպտ": 9,
            "Հոկտ": 10,
            "Նոյեմ": 11,
            "Դեկտ": 12
        ]
        
        if let url = URL(string: "https://www.1000plus.am/hy/news?page=\(page)") {
            var request = URLRequest(url: url)
            request.timeoutInterval = 20
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print(error)
                } else if let unwrappedData = data {
                    let dataString = String(data: unwrappedData, encoding: .utf8)
                    if let newsContainers = dataString?.components(separatedBy: "<div class=\"news-list\">") {
                        let containersCount = newsContainers.count
                        for newsContainer in newsContainers[1..<containersCount] {
                            
                            //Chech Date, if in range get other values and append
                            var dateContainer = newsContainer.components(separatedBy: "<div class=\"slider-date\">")
                            var dateDayContainer = dateContainer[1].components(separatedBy: "<p class=\"fs38 helvetica-neue-thin\">")
                            dateDayContainer = dateDayContainer[1].components(separatedBy: "</p>")
                            var dateMonthContainer = dateContainer[1].components(separatedBy: "<p class=\"fs15 month\">")
                            dateMonthContainer = dateMonthContainer[1].components(separatedBy: ",</p>")
                            var dateYearContainer = dateContainer[1].components(separatedBy: "<p class=\"fs15 helvetica-neue-thin\">")
                            dateYearContainer = dateYearContainer[1].components(separatedBy: "</p>")
                            
                            //Create Date Components
                            var components = DateComponents()
                            components.day = Int(dateDayContainer[0])
                            components.month = armenianDateDictionary[dateMonthContainer[0]]
                            components.year = Int(dateYearContainer[0])
                            
                            //Check Range
                            let calendar = Calendar.current
                            let weekEarlier = calendar.date(byAdding: .day, value: -8, to: Date())
                            let date = calendar.date(from: components)
                            if date! > weekEarlier! {
                                
                                //Parse Image URL
                                var imageContainer = newsContainer.components(separatedBy: "<div class=\"news-content\">")
                                imageContainer = imageContainer[1].components(separatedBy: "<img src=\"")
                                imageContainer = imageContainer[1].components(separatedBy: "\"  />")
                                let imageURL = URL(string:"\(imageContainer[0])")
                                
                                //Parse Article URL
                                var URLContainer = newsContainer.components(separatedBy: "<div class=\"news-right-content\">")
                                URLContainer = URLContainer[1].components(separatedBy: "<h3><a href=\"")
                                URLContainer = URLContainer[1].components(separatedBy: "\" class=")
                                var urlString = "https://www.1000plus.am/hy/" + URLContainer[0]
                                urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                                let articleURL = URL(string: urlString)
                                
                                //Parse Title
                                var titleContainer = newsContainer.components(separatedBy: "class=\"db fb fs18 trans-color\">")
                                titleContainer = titleContainer[1].components(separatedBy: "</a></h3>")
                                let title = titleContainer[0]
                                
                                //Parse Description
                                var descriptionContainer = newsContainer.components(separatedBy: "<div class=\"description\"><p>")
                                descriptionContainer = descriptionContainer[1].components(separatedBy: "</div>")
                                let description = descriptionContainer[0]
                                
                                //Create News
                                let newsEntry = News(imageURL: imageURL,
                                                     dateCreated:date,
                                                     articleURL: articleURL,
                                                     title: title, description: description,
                                                     type: .article1000Plus)
                                
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
    
    static func get1000PlusContent (completionHandler: @escaping ([String : [String : String]], URLResponse?, Error?) -> Void) {
        var resultsDictionary = [String : [String : String]]()
        
        if let url = URL(string: "https://www.1000plus.am/en") {
            var request = URLRequest(url: url)
            request.timeoutInterval = 20
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print(error)
                } else if let unwrappedData = data {
                    
                    let dataString = String(data: unwrappedData, encoding: .utf8)
                    if let infoContainer = dataString?.components(separatedBy: "<div class=\"accounts-wrapper\">") {
                        
                        //Get Total Funds
                        let totalFundsContainer = infoContainer[1].components(separatedBy: "<p class=\"accounts-title fs18\">Total funds</p>")
                        //By AMD
                        let totalFundsAMDContainer = totalFundsContainer[1].components(separatedBy: "<span data-cur=\"amd\" data-sum=\"")
                        let totalFundsAMD = totalFundsAMDContainer[1].components(separatedBy: "\" class=\"ccy db fs30 amd trans-background active\">դր.</span>")[0]
                        //By USD
                        let totalFundsUSDContainer = totalFundsContainer[1].components(separatedBy: "<span data-cur=\"usd\" data-sum=\"")
                        let totalFundsUSD = totalFundsUSDContainer[1].components(separatedBy: "\" class=\"ccy db fs30 roboto-regular trans-background\">&#36;</span>")[0]
                        //By RUB
                        let totalFundsRUBContainer = totalFundsContainer[1].components(separatedBy: "<span data-cur=\"rub\" data-sum=\"")
                        let totalFundsRUB = totalFundsRUBContainer[1].components(separatedBy: "\" class=\"ccy db fs30 roboto-regular trans-background\">&#8381;</span>")[0]
                        //By EUR
                        let totalFundsEURContainer = totalFundsContainer[1].components(separatedBy: "<span data-cur=\"eur\" data-sum=\"")
                        let totalFundsEUR = totalFundsEURContainer[1].components(separatedBy: "\" class=\"ccy db fs30 roboto-regular trans-background\">&euro;</span>")[0]
                        //Create dictionary
                        let totalFundsDictionary = [
                            "AMD" : totalFundsAMD,
                            "USD" : totalFundsUSD,
                            "RUB" : totalFundsRUB,
                            "EUR" : totalFundsEUR
                        ]
                        
                        //Get Stamp Duty
                        let stampDutyContainer = infoContainer[1].components(separatedBy: "<h5 class=\"title\">Stamp duty</h5>")
                        //By AMD
                        let stampDutyAMDContainer = stampDutyContainer[1].components(separatedBy: "<span class=\"amd dn\">")
                        let stampDutyAMD = stampDutyAMDContainer[1].components(separatedBy: "</span>")[0]
                        //By USD
                        let stampDutyUSDContainer = stampDutyContainer[1].components(separatedBy: "<span class=\"usd dn\">")
                        let stampDutyUSD = stampDutyUSDContainer[1].components(separatedBy: "</span>")[0]
                        //By RUB
                        let stampDutyRUBContainer = stampDutyContainer[1].components(separatedBy: "<span class=\"rub dn\">")
                        let stampDutyRUB = stampDutyRUBContainer[1].components(separatedBy: "</span>")[0]
                        //By EUR
                        let stampDutyEURContainer = stampDutyContainer[1].components(separatedBy: "<span class=\"eur dn\">")
                        let stampDutyEUR = stampDutyEURContainer[1].components(separatedBy: "</span>")[0]
                        //Create dictionary
                        let stampDutyDictionary = [
                            "AMD" : stampDutyAMD,
                            "USD" : stampDutyUSD,
                            "RUB" : stampDutyRUB,
                            "EUR" : stampDutyEUR
                        ]
                        
                        //Get Donations
                        let donationsContainer = infoContainer[1].components(separatedBy: "<h5 class=\"title\">Donations</h5>")
                        //By AMD
                        let donationsAMDContainer = donationsContainer[1].components(separatedBy: "<span class=\"amd dn\">")
                        let donationsAMD = donationsAMDContainer[1].components(separatedBy: "</span>")[0]
                        //By USD
                        let donationsUSDContainer = donationsContainer[1].components(separatedBy: "<span class=\"usd dn\">")
                        let donationsUSD = donationsUSDContainer[1].components(separatedBy: "</span>")[0]
                        //By RUB
                        let donationsRUBContainer = donationsContainer[1].components(separatedBy: "<span class=\"rub dn\">")
                        let donationsRUB = donationsRUBContainer[1].components(separatedBy: "</span>")[0]
                        //By EUR
                        let donationsEURContainer = donationsContainer[1].components(separatedBy: "<span class=\"eur dn\">")
                        let donationsEUR = donationsEURContainer[1].components(separatedBy: "</span>")[0]
                        //Create dictionary
                        let donationsDictionary = [
                            "AMD" : donationsAMD,
                            "USD" : donationsUSD,
                            "RUB" : donationsRUB,
                            "EUR" : donationsEUR
                        ]
                        
                        //Get Compansations
                        let compensationsContainer = infoContainer[1].components(separatedBy: "<p class=\"accounts-title fs18\">Compensations</p>")
                        //By AMD
                        let compensationsAMDContainer = compensationsContainer[1].components(separatedBy: "<span data-cur=\"amd\" data-sum=\"")
                        let compensationsAMD = compensationsAMDContainer[1].components(separatedBy: "\" class=\"ccy db fs30 amd trans-background active\">դր.</span>")[0]
                        //By USD
                        let compensationsUSDContainer = compensationsContainer[1].components(separatedBy: "<span data-cur=\"usd\" data-sum=\"")
                        let compensationsUSD = compensationsUSDContainer[1].components(separatedBy: "\" class=\"ccy db fs30 roboto-regular trans-background\">&#36;</span>")[0]
                        //By RUB
                        let compensationsRUBContainer = compensationsContainer[1].components(separatedBy: "<span data-cur=\"rub\" data-sum=\"")
                        let compensationsRUB = compensationsRUBContainer[1].components(separatedBy: "\" class=\"ccy db fs30 roboto-regular trans-background\">&#8381;</span>")[0]
                        //By EUR
                        let compensationsEURContainer = compensationsContainer[1].components(separatedBy: "<span data-cur=\"eur\" data-sum=\"")
                        let compensationsEUR = compensationsEURContainer[1].components(separatedBy: "\" class=\"ccy db fs30 roboto-regular trans-background\">&euro;</span>")[0]
                        //Create dictionary
                        let compensationsDictionary = [
                            "AMD" : compensationsAMD,
                            "USD" : compensationsUSD,
                            "RUB" : compensationsRUB,
                            "EUR" : compensationsEUR
                        ]
                        
                        //Create Info Dictionary
                        resultsDictionary = [
                            "TotalFunds" : totalFundsDictionary,
                            "StampDuty" : stampDutyDictionary,
                            "Donations" : donationsDictionary,
                            "Compensations" : compensationsDictionary
                        ]
                    }
                }
                DispatchQueue.main.async {
                    completionHandler(resultsDictionary, response, error)
                }
                }.resume()
        }
    }
    
}
