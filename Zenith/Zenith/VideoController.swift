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
        //try AVAudioSession.sharedInstance().setCategory(., mode: .default, options: [])
        
        /*if isFirst {
            //testAlert(msg:"first foreground")
            player.seek(to: stopPos)
            player.play()
        } else {
            if (m_videoIndex >= m_videoList.count || m_videoIndex < 0) {
                return
            }
            
            m_curVideoInfo = m_videoList[m_videoIndex]
            if m_curVideoInfo == nil {
                return
            }
            
            m_curVideoInfo!.state = LOOP_STATE
            
            guard let path = Bundle.main.path(forResource: m_curVideoInfo!.loopVideo, ofType:"mp4") else {
                debugPrint(m_curVideoInfo!.loopVideo + "not found")
                return
            }
            
            let videoURL = URL(fileURLWithPath: path)
            let item = AVPlayerItem(url: videoURL)
            
            NotificationCenter.default.addObserver(self, selector: #selector(VideoController.completedVideoPlay(note:)),name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
            
            player = AVPlayer(playerItem: item)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.view.bounds
            //self.view.layer.removeFromSuperlayer()
            self.view.layer.addSublayer(playerLayer)
            
            player.play()
        }*/
        
        if player != nil {
            if isFirst {
                //testAlert(msg:"first foreground")
                player.seek(to: stopPos)
                player.play()
            } else {
                if let player = player{
                    
                    playerLayer = AVPlayerLayer(player: player)
                    playerLayer.frame = self.view.bounds
                    self.view.layer.replaceSublayer(oldLayer, with: playerLayer)
                    
                    if player.timeControlStatus == .paused{
                        playLoopVideo()
                    }
                }
            }
        }
    }
    
    private func playStartVideo() {
        guard let path = Bundle.main.path(forResource: "after_login_video_to_twitter_prize_480", ofType:"mp4") else {
            debugPrint("after_login_video_to_twitter_prize_480.mp4 not found")
            return
        }
        
        let videoURL = URL(fileURLWithPath: path)
        let item = AVPlayerItem(url: videoURL)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoController.completedVideoPlay(note:)),name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        player = AVPlayer(playerItem: item)
        player.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        print(self.view.bounds)
        self.view.layer.addSublayer(playerLayer)
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
            if m_curVideoInfo!.state == LOOP_STATE {
                player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                player.play()
            } else if m_curVideoInfo!.state == LEFT_STATE {
                startLeftLink()
            } else if m_curVideoInfo!.state == RIGHT_STATE {
                startRightLink()
            } else if m_curVideoInfo!.state == SWIPE_STATE {
                m_videoIndex += 1
                if m_videoIndex >= m_videoList.count {
                    m_videoIndex = 0
                }
                
                playLoopVideo()
            }
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
            
            if m_curVideoInfo!.state == LOOP_STATE {
                if let swipeGesture = gesture as? UISwipeGestureRecognizer {
                    switch swipeGesture.direction {
                    case UISwipeGestureRecognizer.Direction.right:
                        if point.x < playerLayer.frame.width / 2 {
                            playSwipeVideo()
                        }
                        print("Swiped right")
                    case UISwipeGestureRecognizer.Direction.left:
                        if point.x < playerLayer.frame.width / 2 {
                            m_videoIndex -= 1
                            if m_videoIndex < 0 {
                                m_videoIndex = m_videoList.count - 1
                            }
                            playLoopVideo()
                        }
                        print("Swiped left")
                        
                    default:
                        break
                    }
                }
            } else if m_curVideoInfo!.state == SWIPE_STATE {
                if let swipeGesture = gesture as? UISwipeGestureRecognizer {
                    switch swipeGesture.direction {
                    case UISwipeGestureRecognizer.Direction.right:
                        if point.x < playerLayer.frame.width / 2 {
                            m_videoIndex += 1
                            if m_videoIndex >= m_videoList.count {
                                m_videoIndex = 0
                            }
                            
                            m_curVideoInfo = m_videoList[m_videoIndex]
                            
                            playSwipeVideo()
                        }
                        print("Swiped right")
                    case UISwipeGestureRecognizer.Direction.left:
                        if point.x < playerLayer.frame.width / 2 {
                            //                        m_videoIndex -= 1
                            //                        if m_videoIndex < 0 {
                            //                            m_videoIndex = m_videoList.count - 1
                            //                        }
                            playLoopVideo()
                        }
                        print("Swiped left")
                        
                    default:
                        break
                    }
                }
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
            if m_curVideoInfo != nil {
                if m_curVideoInfo!.state == LOOP_STATE {
                    if point.x < playerLayer.frame.width / 2 {
                        playLeftVideo()
                    } else {
                        playRightVideo()
                    }
                } else if m_curVideoInfo!.state == SWIPE_STATE {
                    let prevIndex = m_videoIndex
                    let prevVideoInfo = m_curVideoInfo
                    
                    m_videoIndex += 1
                    
                    if m_videoIndex >= m_videoList.count {
                        m_videoIndex = 0
                    }
                    
                    m_curVideoInfo = m_videoList[m_videoIndex]
                    
                    if point.x < playerLayer.frame.width / 2 {
                        if m_curVideoInfo!.locked == true || m_curVideoInfo!.leftLink == nil {
                            m_videoIndex = prevIndex
                            m_curVideoInfo = prevVideoInfo
                        } else {
                            playLeftVideo()
                        }
                    } else {
                        playRightVideo()
                    }
                }

            }
        }
    }
    
    private func startMainVideo() {
        isFirst = false
        m_videoIndex = 0
        
        playLoopVideo();
    }
    
    private func playLoopVideo() {
        if (m_videoIndex >= m_videoList.count || m_videoIndex < 0) {
            return
        }
        
        m_curVideoInfo = m_videoList[m_videoIndex]
        if m_curVideoInfo == nil {
            return
        }
        
        m_curVideoInfo!.state = LOOP_STATE
        
        replacePlayItem(res_id: m_curVideoInfo!.loopVideo)
    }
    
    private func playLeftVideo() {
        if m_curVideoInfo == nil {
            return
        }
        if m_curVideoInfo!.locked == true || m_curVideoInfo!.leftLink == nil {
            return
        }
        
        m_curVideoInfo!.state = LEFT_STATE
        
        replacePlayItem(res_id: m_curVideoInfo!.leftLink!.video)
    }
    
    private func playRightVideo() {
        if m_curVideoInfo == nil {
            return
        }
        
        m_curVideoInfo!.state = RIGHT_STATE
        
        replacePlayItem(res_id: m_curVideoInfo!.rightLink.video)
    }
    
    private func playSwipeVideo() {
        if m_curVideoInfo == nil {
            return
        }
        
        m_curVideoInfo!.state = SWIPE_STATE
        
        replacePlayItem(res_id: m_curVideoInfo!.swipeVideo)
    }
    
    private func replacePlayItem(res_id: String) {
        guard let path = Bundle.main.path(forResource: res_id, ofType:"mp4") else {
            debugPrint(m_curVideoInfo!.loopVideo + ".mp4 not found")
            return
        }
        
        let videoURL = URL(fileURLWithPath: path)
        let item = AVPlayerItem(url: videoURL)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoController.completedVideoPlay(note:)),name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        player.replaceCurrentItem(with: item)
        player.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        player.play()
    }
    
    private func startLeftLink() {
        if m_curVideoInfo == nil {
            return
        }
        
        if m_curVideoInfo!.leftLink == nil {
            return
        }
        
        if m_curVideoInfo!.leftLink!.name.caseInsensitiveCompare("twitter") == .orderedSame {
            let screenName =  m_curVideoInfo!.leftLink!.link
            let appURL = NSURL(string: "twitter://user?screen_name=\(screenName)")!
            let webURL = NSURL(string: "https://twitter.com/\(screenName)")!
            
            if UIApplication.shared.canOpenURL(appURL as URL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(appURL as URL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(appURL as URL)
                }
            } else {
                //redirect to safari because the user doesn't have Instagram
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(webURL as URL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(webURL as URL)
                }
            }
        } else if m_curVideoInfo!.leftLink!.name.caseInsensitiveCompare("snapchat") == .orderedSame {
            let screenName =  m_curVideoInfo!.leftLink!.link
            let webURL = NSURL(string: "https://www.snapchat.com/add/\(screenName)")!
            
            if UIApplication.shared.canOpenURL(webURL as URL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(webURL as URL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(webURL as URL)
                }
            }
        } else if m_curVideoInfo!.leftLink!.name.caseInsensitiveCompare("instagram") == .orderedSame {
            let screenName =  m_curVideoInfo!.leftLink!.link
            let appURL = NSURL(string: "instagram://user?username=\(screenName)")!
            let webURL = NSURL(string: "https://instagram.com/\(screenName)")!
            
            if UIApplication.shared.canOpenURL(appURL as URL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(appURL as URL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(appURL as URL)
                }
            } else {
                //redirect to safari because the user doesn't have Instagram
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(webURL as URL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(webURL as URL)
                }
            }
        } else if m_curVideoInfo!.leftLink!.name.caseInsensitiveCompare("replay") == .orderedSame {
            replayMainvideo()
        } else {
            guard let url = URL(string: m_curVideoInfo!.leftLink!.link) else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }

    }
    
    private func startRightLink() {
        if m_curVideoInfo == nil {
            return
        }
        
        guard let url = URL(string: m_curVideoInfo!.rightLink.link) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    private func replayMainvideo() {
        isFirst = true
        m_videoIndex = -1
        
        replacePlayItem(res_id: "after_login_video_to_twitter_prize_480")
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
    
    private func testAlert(msg: String) {
        let alert = UIAlertController(title: "test", message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
}
