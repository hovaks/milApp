//
//  NewsViewController.swift
//  Banak
//
//  Created by Hovak Davtyan on 7/1/17.
//  Copyright © 2017 alfaSolutions. All rights reserved.
//

import UIKit
import Kingfisher

class NewsViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var news: News!
    var articleURL: URL?
    var imageArray: [UIImage] = []
    var scrollTimer: Timer?
    var resumeTimer: Timer?
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTimer()
        self.automaticallyAdjustsScrollViewInsets = false
        
        descriptionTextView.text = news.description
        titleLabel.text = news.title
        navigationItem.titleView = titleLabel
        
        imageScrollView.delegate = self
        
        Parser.getNewsContent(fromUrl: articleURL!) { (article, response, error) in
            self.contentTextView.text = article.text
            //Images
            if let imageURLs = article.imageURLs?["thumbnails"] {
                let imageSize = (width: CGFloat(349), height: CGFloat(223), padding: CGFloat(10))
                self.pageControl.hidesForSinglePage = true
                
                for (index, imageURL) in imageURLs.enumerated() {
                    
                    //Checking for The images count not to exceed the page controll limit
                    let pageControlEstimatedSize = self.pageControl.size(forNumberOfPages: index + 3)
                    if pageControlEstimatedSize.width < imageSize.width {
                        self.pageControl.numberOfPages = index + 1
                    } else {
                        return
                    }
                    
                    //Creating the image and adding ti the ScrollView
                    let imageView = UIImageView()
                    if index == 0 {
                        imageView.frame = CGRect(x: 5,
                                                 y: 8.5,
                                                 width: imageSize.width,
                                                 height: imageSize.height)
                        self.imageScrollView.contentSize.width += imageSize.width + imageSize.padding
                    } else {
                        imageView.frame = CGRect(x: (CGFloat(index) * (imageSize.width + imageSize.padding)) + imageSize.padding / 2,
                                                 y: 8.5,
                                                 width: imageSize.width,
                                                 height: imageSize.height)
                        self.imageScrollView.contentSize.width += imageSize.width + imageSize.padding
                    }
                    imageView.contentMode = .scaleAspectFit
                    imageView.kf.indicatorType = .activity
                    imageView.kf.setImage(with: imageURL, placeholder: #imageLiteral(resourceName: "ImagePlaceholder"))
                    self.imageScrollView.addSubview(imageView)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("will dissapear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        scrollTimer?.invalidate()
        resumeTimer?.invalidate()
        print("did Disappear")
    }
    
    
    // MARK: - ScrollView Delegate and Functions
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        //PageControl using Timer
        //Getting the selected page for the PageController
        let pageWidth = scrollView.frame.width
        let currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1
        pageControl.currentPage = Int(currentPage)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //PageControl manual
        scrollTimer?.invalidate()
        scrollTimer = nil
        resumeTimer?.invalidate()
        resumeTimer = nil
        //Getting the selected page for the PageController
        let pageWidth = scrollView.frame.width
        let currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1
        pageControl.currentPage = Int(currentPage)
            resumeTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(startTimer), userInfo: nil, repeats: false)
    }
    
    // MARK: - Timer
    
    func startTimer() {
        scrollTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
    }
    
    func moveToNextPage() {
        let pageWidth = imageScrollView.frame.width
        let maxWidth = imageScrollView.contentSize.width
        let contentOffset = imageScrollView.contentOffset.x
        
        var slideToX = pageWidth + contentOffset
        
        if slideToX == maxWidth {
            slideToX = 0
        }
        
        print(slideToX)
        
        DispatchQueue.main.async {
            if slideToX != 0 {
                self.imageScrollView.setContentOffset(CGPoint(x: slideToX, y: 0), animated: true)
            } else {
                self.pageControl.currentPage = 0
                self.imageScrollView.setContentOffset(CGPoint(x: slideToX, y: 0), animated: false)
            }
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
