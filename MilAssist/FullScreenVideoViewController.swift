//
//  FullScreenVideoViewController.swift
//  Banak
//
//  Created by Hovak Davtyan on 7/31/17.
//  Copyright © 2017 alfaSolutions. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class FullScreenVideoViewController: UIViewController {
    
    var videoID: String!
    var youtubePlayer: YTPlayerView?
    
    //Autoratation Settings
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        globals.currentPlayer?.frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.width)
        globals.currentPlayer?.cueVideo(byId: videoID, startSeconds: (globals.currentPlayer?.currentTime())!, suggestedQuality: .medium)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        globals.currentPlayer?.playVideo()
        view.addSubview(globals.currentPlayer!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        globals.playerMod = .fullScreen
        print("fullScreen Mod")
        //globals.currentPlayer?.playVideo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isPortrait {
            navigationController?.popViewController(animated: false)
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
