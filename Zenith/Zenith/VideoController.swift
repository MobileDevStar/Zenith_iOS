//
//  File.swift
//  Zenith
//
//  Created by simba on 7/22/19.
//  Copyright © 2019 simba. All rights reserved.
//

import UIKit
import AVKit

class VideoController: UIViewController {
    
    private var playerLayer: AVPlayerLayer!
    private var oldLayer: AVPlayerLayer!
    private var player: AVPlayer!

    private var isFirst: Bool!
    
    private var stopPos: CMTime!
    private var m_videoList: [VideoInfo] = []
    private var m_videoIndex: Int = -1
    private var m_curVideoInfo: VideoInfo? = nil
    
    public var  m_contribute: String! = "1"
    
    
    // private var tutorialVideoPlayer:AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        isFirst = true
        stopPos = CMTime(seconds: 0, preferredTimescale: 1)
        //m_curVideoInfo = nil
        
        print(m_contribute ?? "5")
        initVideoList()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.respondToTapGesture))
        self.view.addGestureRecognizer(tapGes)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoController.appEnteredForeground(note:)),name:UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(VideoController.appEnteredBackground(note:)),name:UIApplication.didEnterBackgroundNotification, object: nil)
        
        //testAlert(msg:"did load")
        
        playStartVideo()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else {
            print("Portrait")
        }
        
        print(size)
        print(self.view.bounds)
        //playerLayer.frame = self.view.bounds
        if playerLayer != nil {
            playerLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name:UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public func pausePlayer() {
       /* if isFirst {
            stopPos = player.currentTime();
            player.pause()
        } else {
            oldLayer = playerLayer
            player.pause()
            playerLayer = nil
            player = nil
        }*/
       
        if player != nil {
            if isFirst {
                stopPos = player.currentTime();
                player.pause()
            } else {
                player.pause()
                oldLayer = playerLayer
                playerLayer = nil
            }
            
        }
    }
    
    public func resumePlayer() {
        
    }
    
    private func playStartVideo() {
        
        player.play()
    }
    
    @objc private func appEnteredForeground(note: Notification) {
        print("foreground")
        resumePlayer()
    }
    
    @objc private func appEnteredBackground(note: Notification) {
        print("background")
        pausePlayer()
    }
    
    @objc private func completedVideoPlay(note: Notification) {
        // Your code here
        print("Title completed")
        if isFirst == true && m_videoIndex == -1 {
            startMainVideo()
        } else {
        
        }
    }
    
     //////Swipe Gesture
    @objc  private func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        let point = CGPoint(x: gesture.location(in: self.view).x, y: gesture.location(in: self.view).y)
        
        print(point)
        print(playerLayer.bounds)
        print(playerLayer.frame)
        
        if isFirst == true && m_videoIndex == -1 {
            startMainVideo()
        } else {
            if m_curVideoInfo == nil {
                return
            }
            
        }
    }
    
    //////Tap Gesture
    @objc  private func respondToTapGesture(gesture: UIGestureRecognizer) {
        
        let point = CGPoint(x: gesture.location(in: self.view).x, y: gesture.location(in: self.view).y)
        
        print(point)
        print(playerLayer.bounds)
        print(playerLayer.frame)
        
        print("Tap gestured")
        
        if isFirst == true && m_videoIndex == -1 {
            //startMainVideo()
        } else {
            
        }
    }
    
    private func startMainVideo() {
        isFirst = false
        m_videoIndex = 0
        
        playLoopVideo();
    }
    
    private func playLoopVideo() {
        
    }
    
    private func playLeftVideo() {
        if m_curVideoInfo == nil {
            return
        }
        if m_curVideoInfo!.locked == true || m_curVideoInfo!.leftLink == nil {
            return
        }
        
        
    }
    
    private func playRightVideo() {
        if m_curVideoInfo == nil {
            return
        }
        
        
    }
    
    private func playSwipeVideo() {
        if m_curVideoInfo == nil {
            return
        }
        
        
    }
    
    private func replacePlayItem(res_id: String) {
        
        player.play()
    }
    
    private func startLeftLink() {
        if m_curVideoInfo == nil {
            return
        }
        
        if m_curVideoInfo!.leftLink == nil {
            return
        }
        
        

    }
    
    private func startRightLink() {
        if m_curVideoInfo == nil {
            return
        }
        
        guard let url = URL(string: m_curVideoInfo!.rightLink.link) else {
            return //be safe
        }
        
        
    }
    
    private func replayMainvideo() {
        isFirst = true
        m_videoIndex = -1
        
        replacePlayItem(res_id: "after_login_video_to_twitter_prize_480")
    }
    
    private func initVideoList() {
        do {
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func testAlert(msg: String) {
        let alert = UIAlertController(title: "test", message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
}
