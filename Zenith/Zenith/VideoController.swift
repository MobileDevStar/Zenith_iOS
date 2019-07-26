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
    
    @IBOutlet weak var m_butLogin: UIButton!
    
    private var playerLayer: AVPlayerLayer!
    private var player: AVPlayer!
    
    private var isTitle: Bool!
    private var isFirst: Bool!
    
    private var stopPos: CMTime!
    
    // private var tutorialVideoPlayer:AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        isTitle = true
        isFirst = false
        m_butLogin.isHidden = true
        stopPos = CMTime(seconds: 0, preferredTimescale: 1)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.respondToTapGesture))
        self.view.addGestureRecognizer(tapGes)
        
        playStartVideo()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//    }
//
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
        playerLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

    }
    
    @IBAction func onLoginButtonClicked(_ sender: Any) {
        if (isTitle) {
            m_butLogin.isHidden = true
            isTitle = false
            playFirstVideo()
        }
    }
    
    public func pausePlayer() {
        if player != nil {
            stopPos = player.currentTime();
            player.pause()
        }
    }
    
    public func resumePlayer() {
        if player != nil {
            player.seek(to: stopPos)
            player.play()
        }
    }
    
    private func playStartVideo() {
        guard let path = Bundle.main.path(forResource: "title_login_480_sound", ofType:"mp4") else {
            debugPrint("title_login_480_sound.mp4 not found")
            return
        }
        
        //let videoURL = URL(string: "https://zenithzero.s3.us-east-2.amazonaws.com/push.mov")
        let videoURL = URL(fileURLWithPath: path)
        let item = AVPlayerItem(url: videoURL)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoController.completedVideoPlay(note:)),name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        player = AVPlayer(playerItem: item)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        print(self.view.bounds)
        self.view.layer.addSublayer(playerLayer)
        player.play()
    }
    
    private func playFirstVideo() {
        isFirst = true
        
        guard let path = Bundle.main.path(forResource: "after_login_video_to_twitter_prize_480_sound", ofType:"mp4") else {
            debugPrint("after_login_video_to_twitter_prize_480_sound.mp4 not found")
            return
        }
        
        //let videoURL = URL(string: "https://zenithzero.s3.us-east-2.amazonaws.com/push.mov")
        let videoURL = URL(fileURLWithPath: path)
        let item = AVPlayerItem(url: videoURL)
        NotificationCenter.default.addObserver(self, selector: #selector(VideoController.completedVideoPlay(note:)),name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        player.replaceCurrentItem(with: item)
        player.play()
    }
    
    @objc private func completedVideoPlay(note: Notification) {
        // Your code here
        print("Title completed")
        if (isTitle) {
            m_butLogin.isHidden = false
        } else {
            if isFirst {
            
                player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                player.play()
            }
        }
    }
    
     //////Swipe Gesture
    @objc  private func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        let point = CGPoint(x: gesture.location(in: self.view).x, y: gesture.location(in: self.view).y)
        
        print(point)
        print(playerLayer.bounds)
        print(playerLayer.frame)
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                print("Swiped right")
            case UISwipeGestureRecognizer.Direction.down:
                print("Swiped down")
            case UISwipeGestureRecognizer.Direction.left:
                print("Swiped left")
            case UISwipeGestureRecognizer.Direction.up:
                print("Swiped up")
            case UISwipeGestureRecognizer.Direction.init(rawValue: 200):
                print("Swiped Custom")
                
            default:
                break
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
    }
    
}
