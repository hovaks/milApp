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
                //Here is a bug with cell being called the second time
        print("willUpdateUI")
        titleLabel.text = news?.title
        descriptionLabel.text = news?.description
        
        if let date = news?.dateCreated {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy"
            dateLabel.text = dateFormatter.string(from: date)
        }
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: news?.imageURL, placeholder: #imageLiteral(resourceName: "ImagePlaceholder"))
    }
}
