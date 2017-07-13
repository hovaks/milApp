//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport



let url = URL(string: "http://www.mil.am/hy/news/4860")



var request = URLRequest(url: url!)
request.timeoutInterval = 20

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
                try NSAttributedString(data: encodedData, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:String.Encoding.utf8.rawValue], documentAttributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        if var imageURLsContainer = dataString?.components(separatedBy: "overflow: hidden;\">") {
            imageURLsContainer = imageURLsContainer[1].components(separatedBy: "<div u=\"thumbnavigator")
            imageURLsContainer = imageURLsContainer[0].components(separatedBy: "<div>")
            
            var imageURLs = ["x1000": [URL?](), "x188": [URL?]()]
            
            for item in imageURLsContainer.dropFirst() {
                let allSizeImagesContainer = item.components(separatedBy: "</div>")
                
                var fullImageContainer = allSizeImagesContainer[0].components(separatedBy: "<a class=\"image-par\" href=\"")
                fullImageContainer = fullImageContainer[1].components(separatedBy: "\">")
                let fullImageString = fullImageContainer[0]
                let fullImageURL = URL(string: "http://www.mil.am/" + fullImageString)
                imageURLs["x1000"]?.append(fullImageURL)
                
                var thumbnailImageContainer = allSizeImagesContainer[0].components(separatedBy: "<img u=\"thumb\" src=\"")
                thumbnailImageContainer = thumbnailImageContainer[1].components(separatedBy: "\" />")
                let thumbnailImageString = thumbnailImageContainer[0]
                let thumbnailImageURL = URL(string: "http://www.mil.am/" + thumbnailImageString)
                imageURLs["x188"]?.append(thumbnailImageURL)
            }
            print(imageURLs)
        }
    }
    }.resume()

PlaygroundPage.current.needsIndefiniteExecution = true
