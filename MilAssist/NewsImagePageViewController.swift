//
//  NewsImagePageViewController.swift
//  Banak
//
//  Created by Hovak Davtyan on 7/20/17.
//  Copyright © 2017 alfaSolutions. All rights reserved.
//

import UIKit

class NewsImagePageViewController: UIPageViewController {
    var imageURLs: [URL?] = []
    var selectedImageIndex: Int?
    var darkModeEnabled = false
    var statusBarIsHidden = false
    
    override var prefersStatusBarHidden: Bool {
        return statusBarIsHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure View
        self.view.backgroundColor = UIColor.white
        self.tabBarController?.tabBar.isHidden = true
        
        if let viewController = setNewsImageViewController(selectedImageIndex ?? 0) {
            let viewControllers = [viewController]
            setViewControllers(viewControllers,
                               direction: .forward,
                               animated: false,
                               completion: nil)
        }
        
        dataSource = self
        delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Configure PageControl
        let pageControl = UIPageControl.appearance()
        pageControl.hidesForSinglePage = true
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.gray
        pageControl.backgroundColor = UIColor.white
    }
    
    override func viewDidLayoutSubviews() {
        for subview in view.subviews {
            if subview is UIScrollView {
                subview.frame = CGRect(x: -5, y: 0, width: view.frame.size.width + 10, height: view.frame.size.height)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNewsImageViewController(_ index:Int) -> NewsImageViewController? {
        guard let storyboard = storyboard,
            let page = storyboard.instantiateViewController(withIdentifier: "NewsImageViewController") as? NewsImageViewController
            else {return nil}
        page.imageURL = imageURLs[index]
        page.imageIndex = index
        return page
    }
    
    override func willMove(toParentViewController parent:UIViewController?)
    {
        super.willMove(toParentViewController: parent)
        
        if (parent == nil) {
            if let navigationController = self.navigationController {
                var viewControllers = navigationController.viewControllers
                let viewControllersCount = viewControllers.count
                if let destination = viewControllers[viewControllersCount - 2] as? NewsViewController {
                    destination.selectedImageIndex = selectedImageIndex
                }
            }
        }
    }
}

extension NewsImagePageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    //Data Source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? NewsImageViewController {
            if let index = viewController.imageIndex,
                index > 0 {
                return setNewsImageViewController(index - 1)
            }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? NewsImageViewController {
            if let index = viewController.imageIndex,
                index + 1 < imageURLs.count {
                return setNewsImageViewController(index + 1)
            }
        }
        
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return imageURLs.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return selectedImageIndex ?? 0
    }
    
    //Delegate
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        for pendingViewController in pendingViewControllers {
            if let pendingViewController = pendingViewController as? NewsImageViewController {
                pendingViewController.darkModeEnabled = darkModeEnabled
                selectedImageIndex = pendingViewController.imageIndex
            }
        }
    }
}
