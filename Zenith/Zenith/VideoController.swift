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
    private var player: AVPlayer!

    private var isFirst: Bool!
    
    private var stopPos: CMTime!
    private var m_videoList: [VideoInfo] = []
    
    public var  m_contribute: String! = "5"
    
    // private var tutorialVideoPlayer:AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        isFirst = true
        stopPos = CMTime(seconds: 0, preferredTimescale: 1)
        
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
        playerLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

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
        guard let path = Bundle.main.path(forResource: "after_login_video_to_twitter_prize_480_sound", ofType:"mp4") else {
            debugPrint("after_login_video_to_twitter_prize_480_sound.mp4 not found")
            return
        }
        
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
    
    @objc private func completedVideoPlay(note: Notification) {
        // Your code here
        print("Title completed")
        if isFirst {
            player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
            player.play()
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
    
    private func initVideoList() {
        do {
            if let file = Bundle.main.url(forResource: "videos", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    let videos = object["videos"] as? [String: Any]
                    let vList = videos?[m_contribute] as? [Any]
                    for item in vList! {
                        let jsonVideo = item as? [String: Any]
                        let subject = jsonVideo!["subject"] as! String
                        let locked = jsonVideo!["locked"] as! Bool
                        let loopVideo = jsonVideo!["loopVideo"] as! String
                        let swipeVideo = jsonVideo!["swipeVideo"] as! String
                        let state: Int = LOOP_STATE
                        
                        var leftLink: LinkInfo? = nil
                        if locked == false {
                            let leftItem = jsonVideo!["leftLink"] as! [String: Any]
                            
                            let leftLinkName = leftItem["name"] as! String
                            let leftVideo = leftItem["video"] as! String
                            let leftLinkPath = leftItem["link"] as! String
                            
                            leftLink = LinkInfo(name: leftLinkName,video: leftVideo, link: leftLinkPath)
                        }
                        
                        let rightItem = jsonVideo!["rightLink"] as! [String: Any]
                        
                        let rightLinkName = rightItem["name"] as! String
                        let rightVideo = rightItem["video"] as! String
                        let rightLinkPath = rightItem["link"] as! String
                        
                        let rightLink = LinkInfo(name: rightLinkName,video: rightVideo, link: rightLinkPath)
                        
                        let videoInfo = VideoInfo(subject: subject, locked: locked, loopVideo: loopVideo, swipeVideo: swipeVideo, rightLink: rightLink, leftLink: leftLink, state: state)
                        
                        m_videoList.append(videoInfo)
                        print(subject)
                        print(videoInfo.subject)
                        print(videoInfo)

                    }
                } else if let object = json as? [Any] {
                    // json is an array
                    print(object)
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
