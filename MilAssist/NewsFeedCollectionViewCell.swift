//
//  NewsFeedCollectionViewCell.swift
//  MilApp
//
//  Created by Hovak Davtyan on 6/20/17.
//  Copyright © 2017 Hovak Davtyan. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class NewsFeedCollectionViewCell: UICollectionViewCell {
    var youtubePlayer: YTPlayerView?
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var actionView: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playButtonLogo: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var bufferSlider: UISlider!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var news: News? { didSet { updateUI() } }
    var timer: Timer?
    var tapGestureRecognizer: UITapGestureRecognizer!
    var playerIsConfigured = false
    
    
    
    private  func updateUI() {
        //Here is a bug with cell being called the second time
        titleLabel.text = news?.title
        
        if let date = news?.dateCreated {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy"
            dateLabel.text = dateFormatter.string(from: date)
        }
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: news?.imageURL, placeholder: #imageLiteral(resourceName: "ImagePlaceholder"))
    }
    
    func configurePlayer() {
        print("video Will Configure")
        if news?.type == .video {
            if globals.currentPlayer == nil {
                globals.currentPlayer = YTPlayerView()
            }
            
            playButtonLogo.isHidden = true
            let playerFrame = CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.height)
            globals.currentPlayer = YTPlayerView(frame: playerFrame)
            
            
            slider.setThumbImage(#imageLiteral(resourceName: "sliderThumbMin"), for: .normal)
            bufferSlider.setThumbImage(#imageLiteral(resourceName: "sliderThumbMin"), for: .normal)
            bufferSlider.isUserInteractionEnabled = false
            slider.addTarget(self, action: #selector(sliderDragDidEnd), for: .touchUpInside)
            
            tapGestureRecognizer = UITapGestureRecognizer()
            tapGestureRecognizer.addTarget(self, action: #selector(tapGestureRecognized))
            slider.addGestureRecognizer(tapGestureRecognizer)
            
            globals.currentPlayer?.load(withVideoId: (news?.articleURL?.absoluteString)!,
                                        playerVars: ["playsinline" : "1",
                                                     "showinfo" : "0",
                                                     "rel" : "0",
                                                     "modestbranding" : "1",
                                                     "controls" : "0"])
            
            globals.currentPlayer?.delegate = self
            playerIsConfigured = true
        }
    }
    
    func resumeVideo() {
        print("resumeVideo")
        let playerFrame = CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.height)
        globals.currentPlayer?.frame = playerFrame
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        if playButton.isSelected {
            globals.currentPlayer?.pauseVideo()
            playButtonLogo.isHidden = false
        } else {
            globals.currentPlayer?.playVideo()
            playButtonLogo.isHidden = true
        }
    }
    
    @IBAction func slide(_ sender: UISlider) {
        slider.setThumbImage(#imageLiteral(resourceName: "sliderThumb"), for: .normal)
        globals.currentPlayer?.pauseVideo()
        globals.currentPlayer?.seek(toSeconds: sender.value, allowSeekAhead: true)
    }
    
    func updateSlider() {
        bufferSlider.value = (globals.currentPlayer?.videoLoadedFraction())!
        slider.value = (globals.currentPlayer?.currentTime())!
    }
    
    func sliderDragDidEnd() {
        timer?.invalidate()
        slider.setThumbImage(#imageLiteral(resourceName: "sliderThumbMin"), for: .normal)
        globals.currentPlayer?.playVideo()
    }
    
    func tapGestureRecognized() {
        timer?.invalidate()
        slider.setThumbImage(#imageLiteral(resourceName: "sliderThumb"), for: .normal)
        let sliderLength = slider.frame.size.width
        let pointX = tapGestureRecognizer.location(in: slider).x
        let percent = (100 * pointX) / sliderLength
        let length = slider.maximumValue + slider.minimumValue
        let value = (Float(percent) / 100) * length
        slider.value = value
        globals.currentPlayer?.seek(toSeconds: value, allowSeekAhead: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.slider.setThumbImage(#imageLiteral(resourceName: "sliderThumbMin"), for: .normal)
        }
    }
    
}

extension NewsFeedCollectionViewCell: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        print("didBecomeReady")
        imageView.addSubview(globals.currentPlayer!)
        globals.currentPlayer?.playVideo()
        slider.maximumValue = Float((globals.currentPlayer?.duration())!)
        slider.minimumValue = -(Float((globals.currentPlayer?.duration())!) / 100 * 2)
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case .playing:
            print("Playing")
            playButtonLogo.isHidden = true
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        //youtubePlayer?.transform = CGAffineTransform(scaleX: 1.03, y: 1)
        likeButton.isHidden = true
        shareButton .isHidden = true
        dateLabel.isHidden = true
        titleView.isHidden = true
        playButton.isSelected = true
        playButton.isHidden = false
        slider.isHidden = false
        bufferSlider.isHidden = false
        case .paused:
        print("Paused")
        playButtonLogo.isHidden = false
        timer?.invalidate()
        titleView.isHidden = false
        actionView.isHidden = false
        playButton.isSelected = false
        case .unknown:
        print("unknown")
        case .ended:
        print("ended")
        timer?.invalidate()
        //youtubePlayer?.transform = CGAffineTransform(scaleX: 1, y: 1)
        titleView.isHidden = false
        likeButton.isHidden = false
        shareButton .isHidden = false
        dateLabel.isHidden = false
        playButton.isSelected = false
        playButton.isHidden = true
        slider.isHidden = true
        bufferSlider.isHidden = true
        default: break
    }
}
}
