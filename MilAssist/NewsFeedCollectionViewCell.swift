//
//  NewsFeedCollectionViewCell.swift
//  MilApp
//
//  Created by Hovak Davtyan on 6/20/17.
//  Copyright © 2017 Hovak Davtyan. All rights reserved.
//

import UIKit

class NewsFeedCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var news: News? { didSet { updateUI() } }
    
    private  func updateUI() {
        titleLabel.text = news?.title
        descriptionLabel.text = news?.description
        
        if let date = news?.dateCreated {
        let dateFormatter = DateFormatter()
        dateLabel.text = dateFormatter.string(from: date)
        }
        
        let imageCache = NSCache<NSString, AnyObject>()
        if let imageURL = self.news?.imageURL {
            
            let imageURLString = (imageURL.absoluteString) as NSString
            
            if let cachedImage = imageCache.object(forKey: imageURLString) as? UIImage {
                self.imageView.image = cachedImage
            } else {
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    if let imageData = try? Data(contentsOf: imageURL) {
                        let image = UIImage(data: imageData)
                        DispatchQueue.main.async {
                            self?.imageView.image = image
                        }
                        imageCache.setObject(image!, forKey: imageURLString)
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        imageView.image = #imageLiteral(resourceName: "ImagePlaceholder")
        super.prepareForReuse()
    }
}
