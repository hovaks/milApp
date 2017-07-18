//
//  NewsImageViewController.swift
//  Banak
//
//  Created by Hovak Davtyan on 7/14/17.
//  Copyright © 2017 alfaSolutions. All rights reserved.
//

import UIKit
import Kingfisher

class NewsImageViewController: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var imageURLs: [URL?] = []
    var tapGestureRecognizer: UITapGestureRecognizer!
    var selectedImageIndex: Int?
    var imageViewToZoom: UIImageView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        self.tabBarController?.tabBar.isHidden = true
        self.automaticallyAdjustsScrollViewInsets = false
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        pageControl.numberOfPages = imageURLs.count
        pageControl.currentPage = selectedImageIndex!
        showImage(index: selectedImageIndex!)
        view.addGestureRecognizer(tapGestureRecognizer)
        imageScrollView.delegate = self
        
        for (index, imageURL) in imageURLs.enumerated() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: imageURL, placeholder: #imageLiteral(resourceName: "ImagePlaceholder"))
            
            if index == 0 {
                imageView.frame = CGRect(x: 10, y: 0, width: 375, height: 249)
            } else {
                imageView.frame = CGRect(x: (index * (375 + 20)) + 10, y: 0, width: 375, height: 249)
            }
            imageScrollView.contentSize.width += 375 + 20
            imageScrollView.addSubview(imageView)
        }
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func imageTapped() {
        if !(navigationController?.navigationBar.isHidden)! {
            navigationController?.setNavigationBarHidden(true, animated: false)
            view.backgroundColor = UIColor.black
            pageControl.isHidden = true
        } else {
            navigationController?.setNavigationBarHidden(false, animated: false)
            view.backgroundColor = UIColor.white
            pageControl.isHidden = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //Getting the selected page for the PageController
        let pageWidth = scrollView.frame.width
        let currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1
        pageControl.currentPage = Int(currentPage)
    }
    
    func showImage(index: Int) {
        DispatchQueue.main.async {
            self.imageScrollView.setContentOffset(CGPoint(x: index * (375 + 20), y: 0), animated: false)
        }
    }
    
    // MARK: - Navigation
    override func willMove(toParentViewController parent:UIViewController?)
    {
        super.willMove(toParentViewController: parent)
        
        if (parent == nil) {
            if let navigationController = self.navigationController {
                var viewControllers = navigationController.viewControllers
                let viewControllersCount = viewControllers.count
                if let destination = viewControllers[viewControllersCount - 2] as? NewsViewController {
                    destination.selectedImageIndex = pageControl.currentPage
                }
            }
        }
    }
}
