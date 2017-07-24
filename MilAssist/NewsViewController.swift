//
//  NewsViewController.swift
//  Banak
//
//  Created by Hovak Davtyan on 7/1/17.
//  Copyright © 2017 alfaSolutions. All rights reserved.
//

import UIKit
import Kingfisher

class NewsViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var news: News!
    var articleURL: URL?
    var selectedImageIndex: Int?
    var imageArray: [URL] = []
    var tapGestureRecognizer: UITapGestureRecognizer!
    var scrollTimer: Timer?
    var resumeTimer: Timer?
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //Autoratation Settings
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTimer()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        self.automaticallyAdjustsScrollViewInsets = false
        
        descriptionTextView.text = news.description
        titleLabel.text = news.title
        navigationItem.titleView = titleLabel
        
        imageScrollView.delegate = self
        
        Parser.getNewsContent(fromUrl: articleURL!) { (article, response, error) in
            self.contentTextView.text = article.text
            //Images
            if var imageURLs = article.imageURLs?["thumbnails"] {
                if imageURLs.isEmpty {
                    imageURLs.append(self.news.imageURL)
                }
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
                    self.imageScrollView.addGestureRecognizer(self.tapGestureRecognizer)
                    imageView.contentMode = .scaleAspectFit
                    imageView.kf.indicatorType = .activity
                    imageView.kf.setImage(with: imageURL, placeholder: #imageLiteral(resourceName: "ImagePlaceholder"))
                    if var fullImageURLs = article.imageURLs?["fullImages"] {
                        if fullImageURLs.isEmpty {
                            fullImageURLs.append(self.news.imageURL)
                        }
                        let fullImageURL = fullImageURLs[index]
                        self.imageArray.append(fullImageURL!)
                    }
                    self.imageScrollView.addSubview(imageView)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if pageControl.numberOfPages != 1 {
        pageControl.isHidden = false
        }
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.gray
        pageControl.backgroundColor = UIColor.clear
        if selectedImageIndex != nil {
            showImage(index: self.selectedImageIndex!)
            resumeTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(startTimer), userInfo: nil, repeats: false)
            pageControl.currentPage = self.selectedImageIndex!
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        pageControl.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        scrollTimer?.invalidate()
        resumeTimer?.invalidate()
    }
    
    
    // MARK: - ScrollView Delegate
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
        let currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1
        pageControl.currentPage = Int(currentPage)
        resumeTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(startTimer), userInfo: nil, repeats: false)
    }
    
    // MARK: - Functions
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
        
        DispatchQueue.main.async {
            if slideToX != 0 {
                self.imageScrollView.setContentOffset(CGPoint(x: slideToX, y: 0), animated: true)
            } else {
                self.pageControl.currentPage = 0
                self.imageScrollView.setContentOffset(CGPoint(x: slideToX, y: 0), animated: false)
            }
        }
    }
    
    func imageTapped() {
        performSegue(withIdentifier: "pageViewControllerSegue", sender: self)
    }
    
    func showImage(index: Int) {
        DispatchQueue.main.async {
            self.imageScrollView.setContentOffset(CGPoint(x: index * (349 + 10), y: 0), animated: false)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "pageViewControllerSegue" {
                if let destination = segue.destination as? NewsImagePageViewController {
                    destination.imageURLs = imageArray
                    destination.selectedImageIndex = pageControl.currentPage
                }
            }
        }
    }
}
