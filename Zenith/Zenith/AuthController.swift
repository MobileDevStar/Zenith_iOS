//
//  ViewController.swift
//  Zenith
//
//  Created by simba on 7/22/19.
//  Copyright © 2019 simba. All rights reserved.
//

import UIKit
import AVKit

class AuthController: UIViewController {

    @IBOutlet weak var m_vVideo: UIView!
    @IBOutlet weak var m_vLogin: UIView!
    @IBOutlet weak var m_vSignup: UIView!
    
    private var playerLayer: AVPlayerLayer!
    private var player: AVPlayer!
    
    private var stopPos: CMTime!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        stopPos = CMTime(seconds: 0, preferredTimescale: 1)
        
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
        m_vVideo.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        playerLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func onClickLogin(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "VideoControllerID") as! VideoController
        controller.m_contribute = "1"
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func onClickRegister(_ sender: Any) {
        m_vLogin.isHidden = true
        m_vSignup.isHidden = false
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        m_vLogin.isHidden = false
        m_vSignup.isHidden = true
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
        
        let videoURL = URL(fileURLWithPath: path)
        let item = AVPlayerItem(url: videoURL)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AuthController.completedVideoPlay(note:)),name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        player = AVPlayer(playerItem: item)
        
        playerLayer = AVPlayerLayer(player: player)
        m_vVideo.frame = self.view.bounds
        playerLayer.frame = self.view.bounds
        
        m_vVideo.layer.addSublayer(playerLayer);
        //self.view.layer.addSublayer(playerLayer)
        player.play()
    }
    
    @objc private func completedVideoPlay(note: Notification) {
        // Your code here
        print("Title completed")
        
        m_vLogin.isHidden = false
    }
}

