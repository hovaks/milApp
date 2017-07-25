//
//  NewsImageViewController.swift
//  Banak
//
//  Created by Hovak Davtyan on 7/20/17.
//  Copyright © 2017 alfaSolutions. All rights reserved.
//

import UIKit
import Kingfisher

class NewsImageViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    
    //Properties
    var imageIndex: Int?
    var imageURL: URL?
    var tapGestureRecognizer: UITapGestureRecognizer!
    var doubleTapGestureRecogniser: UITapGestureRecognizer!
    
    //Flags
    var isZoomed = false
    var darkModeEnabled = false
    var deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation {
        didSet {
            if let parent = parent as? NewsImagePageViewController {
                if deviceOrientation.isPortrait {
                    if !darkModeEnabled {
                        parent.statusBarIsHidden = false
                    }
                } else {
                    parent.statusBarIsHidden = true
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Gesture Recognizers
        doubleTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(imageDoubleTapped))
        doubleTapGestureRecogniser.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(doubleTapGestureRecogniser)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        tapGestureRecognizer.require(toFail: doubleTapGestureRecogniser)
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // Do any additional setup after loading the view.
        scrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Set Image
        imageView.kf.setImage(with: imageURL, placeholder: #imageLiteral(resourceName: "ImagePlaceholder"), options: [.scaleFactor(2)], progressBlock: nil) { (image, error, cacheType, url) in
            if error == nil {
                DispatchQueue.main.async {
                    self.updateConstraintsForSize(self.view.bounds.size)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            deviceOrientation = UIDeviceOrientation.landscapeLeft
        } else {
            deviceOrientation = UIDeviceOrientation.portrait
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        if !isZoomed {
            scrollView.minimumZoomScale = minScale
            scrollView.zoomScale = minScale
        }
    }
    
    fileprivate func updateConstraintsForSize(_ size: CGSize) {
        
        let tabBarHeight = tabBarController?.tabBar.frame.size.height ?? 0
        let naviGationBarHeight = navigationController?.navigationBar.frame.size.height ?? 0
        
        var yOffset = max(0, (size.height - imageView.frame.height) / 2)
        
        if deviceOrientation.isPortrait {
            if darkModeEnabled {
                if isZoomed {
                    yOffset = yOffset + naviGationBarHeight - tabBarHeight + 20 - 14
                } else {
                    yOffset = yOffset + 0
                }
            } else {
                if isZoomed {
                    yOffset = yOffset - tabBarHeight - 14
                } else {
                    yOffset -= tabBarHeight + 20 - 5
                }
            }
        } else {
            if !darkModeEnabled {
                yOffset = yOffset - naviGationBarHeight
            }
        }
        
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
    
    func imageTapped() {
        if darkModeEnabled {
            disableDarkMode()
        } else {
            enableDarkMode()
        }
    }
    
    fileprivate func enableDarkMode() {
        if  !darkModeEnabled {
            darkModeEnabled = true
            if let parent = parent as? NewsImagePageViewController {
                var pageControl: UIPageControl?
                for view in parent.view.subviews {
                    if view is UIPageControl {
                        pageControl = view as? UIPageControl
                    }
                }
                parent.darkModeEnabled = true
                parent.statusBarIsHidden = true
                parent.view.backgroundColor = UIColor.black
                pageControl?.isHidden = true
                navigationController?.setNavigationBarHidden(true, animated: false)
                updateConstraintsForSize(view.bounds.size)
            }
        }
    }
    
    fileprivate func disableDarkMode() {
        if  darkModeEnabled {
            darkModeEnabled = false
            if let parent = parent as? NewsImagePageViewController {
                var pageControl: UIPageControl?
                for view in parent.view.subviews {
                    if view is UIPageControl {
                        pageControl = view as? UIPageControl
                    }
                }
                parent.darkModeEnabled = false
                if deviceOrientation.isPortrait {
                    parent.statusBarIsHidden = false
                }
                parent.view.backgroundColor = UIColor.white
                pageControl?.isHidden = false
                navigationController?.setNavigationBarHidden(false, animated: false)
                updateConstraintsForSize(view.bounds.size)
            }
        }
    }
    
    func imageDoubleTapped() {
        if !isZoomed {
            let location = doubleTapGestureRecogniser.location(in: imageView)
            scrollView.zoom(to: CGRect(x: location.x, y: location.y, width: 0, height: 0), animated: true)
            isZoomed = true
        } else {
            scrollView.setZoomScale(0.1, animated: true) //Here a trick for setting zoom scale lower than the minimum UNSAFE
            isZoomed = false
        }
    }
}

extension NewsImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        enableDarkMode()
        isZoomed = true
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            isZoomed = false
        }
        updateConstraintsForSize(view.bounds.size)
    }
}
