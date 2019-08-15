//
//  ViewController.swift
//  Zenith
//
//  Created by simba on 7/22/19.
//  Copyright © 2019 simba. All rights reserved.
//

import UIKit
import AVKit
import Alamofire
import SwiftyJSON

import FirebaseAuth

class AuthController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var m_vVideo: UIView!
    @IBOutlet weak var m_vLogin: UIView!
    @IBOutlet weak var m_vSignup: UIView!
    
    @IBOutlet weak var m_etSignupUsername: UITextField!
    @IBOutlet weak var m_etSignupEmail: UITextField!
    @IBOutlet weak var m_etSignupPassword: UITextField!
    
    @IBOutlet weak var m_etLoginEmail: UITextField!
    @IBOutlet weak var m_etLoginPassword: UITextField!
    
    private var playerLayer: AVPlayerLayer!
    private var player: AVPlayer!
    
    private var stopPos: CMTime!
    private var m_blLoginScreen: Bool!
    
    private var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        m_etSignupUsername.delegate = self
        m_etSignupPassword.delegate = self
        m_etSignupEmail.delegate = self
        
        m_etLoginEmail.delegate = self
        m_etLoginPassword.delegate = self
        
        m_blLoginScreen = true
        stopPos = CMTime(seconds: 0, preferredTimescale: 1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AuthController.appEnteredForeground(note:)),name:UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AuthController.appEnteredBackground(note:)),name:UIApplication.didEnterBackgroundNotification, object: nil)
        
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
    
    // MARK: - View controller life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
        NotificationCenter.default.removeObserver(self, name:UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func onClickLogin(_ sender: Any) {
        let email:String = m_etLoginEmail.text ?? ""
        let password: String = m_etLoginPassword.text ?? ""
        
        if email.isEmpty {
            displayToastMessage("Please input email")
            return
        }
        
        if isValidEmail(emailStr: email) == false {
            displayToastMessage("Email is invalide")
            return
        }
        
        if password.isEmpty {
            displayToastMessage("Please input password")
            return
        }
        
        
    }
    
    private func firebaseLoginSuccess(username: String, email: String, password: String) {
        
        httpRequestSend(username: username, email: email)
    }
    
    @IBAction func onClickRegister(_ sender: Any) {
        m_vLogin.isHidden = true
        m_vSignup.isHidden = false
        m_blLoginScreen = false
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        m_vLogin.isHidden = false
        m_vSignup.isHidden = true
        m_blLoginScreen = true
    }
    
    @IBAction func onClickDonate(_ sender: Any) {
        
    }
    
    @IBAction func onClickSignup(_ sender: Any) {
        let username: String = m_etSignupUsername.text ?? ""
        let email: String = m_etSignupEmail.text ?? ""
        let password: String = m_etSignupPassword.text ?? ""
        
        if username.isEmpty {
            displayToastMessage("Please input username. Username should be equal to Indiegogo name")
            return
        }
        
        if email.isEmpty {
            displayToastMessage("Please input email")
            return
        }
        
        if isValidEmail(emailStr: email) == false {
            displayToastMessage("Email is invalide")
            return
        }
        
        if password.isEmpty {
            displayToastMessage("Please input password")
            return
        }
        
        if password.count < 6 {
            displayToastMessage("Password length should be at least 6")
            return
        }
        
        
    }
    
    //private func firebaseLoginSuccess
    
    private func signupSuccess(username: String, email: String, password: String) {
        //let contribute = "5"
        
        httpRequestSend(username: username, email: email)
    }
    
    @IBAction func onClickForgotPassword(_ sender: Any) {
        let forgotPasswordAlert = UIAlertController(title: "Forgot password?", message: "Enter email address", preferredStyle: .alert)
        forgotPasswordAlert.addTextField { (textField) in
            textField.placeholder = "Enter email address"
        }
        forgotPasswordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        forgotPasswordAlert.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { (action) in
            let resetEmail = forgotPasswordAlert.textFields?.first?.text
        
        }))
        //PRESENT ALERT
        self.present(forgotPasswordAlert, animated: true, completion: nil)
    }
    
    private func updateUI(contribute: String) {
        
    }
    
    func textFieldShouldReturn(_ etText: UITextField) -> Bool {
        if etText.isEqual(m_etSignupUsername) {
            m_etSignupEmail.becomeFirstResponder()
        } else if etText.isEqual(m_etSignupEmail) {
            m_etSignupPassword.becomeFirstResponder()
        } else if etText.isEqual(m_etLoginEmail) {
            m_etLoginPassword.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
        return true
    }
    
    public func pausePlayer() {
        if player != nil {
            player.pause()
            stopPos = player.currentTime()
        }
    }
    
    public func resumePlayer() {
        if player != nil {
            player.seek(to: stopPos)
            player.play()
        }
    }
    
    private func playStartVideo() {
        
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
        
        
    }
    
    private func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    
    private func displayToastMessage(_ message : String) {
        
        let toastView = UILabel()
        toastView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastView.textColor = UIColor.white
        toastView.textAlignment = .center
        toastView.font = UIFont.preferredFont(forTextStyle: .caption1)
        toastView.layer.cornerRadius = 25
        toastView.layer.masksToBounds = true
        toastView.text = message
        toastView.numberOfLines = 0
        toastView.alpha = 0
        toastView.translatesAutoresizingMaskIntoConstraints = false
        
        let window = UIApplication.shared.delegate?.window!
        window?.addSubview(toastView)
        
        let horizontalCenterContraint: NSLayoutConstraint = NSLayoutConstraint(item: toastView, attribute: .centerX, relatedBy: .equal, toItem: window, attribute: .centerX, multiplier: 1, constant: 0)
        
        let widthContraint: NSLayoutConstraint = NSLayoutConstraint(item: toastView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 275)
        
        let verticalContraint: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=200)-[loginView(==50)]-68-|", options: [.alignAllCenterX, .alignAllCenterY], metrics: nil, views: ["loginView": toastView])
        
        NSLayoutConstraint.activate([horizontalCenterContraint, widthContraint])
        NSLayoutConstraint.activate(verticalContraint)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            toastView.alpha = 1
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                toastView.alpha = 0
            }, completion: { finished in
                toastView.removeFromSuperview()
            })
        })
    }
    
    private func httpRequestSend(username: String, email: String) {
        
        
    }
    
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        print("keyboard will be shown")
        
        
        
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        
        if let activeField = self.activeField {
            let ptBottomRight: CGPoint = CGPoint(x: activeField.frame.origin.x + activeField.frame.width, y: activeField.frame.origin.y + activeField.frame.height)
            print(ptBottomRight)
            if (!aRect.contains(ptBottomRight)){
                print(activeField.frame)
                let keyboardY: CGFloat = self.view.frame.height - keyboardSize!.height
                self.view.frame = CGRect(x: 0, y: -(ptBottomRight.y - keyboardY + activeField.frame.height), width: self.view.frame.width, height: self.view.frame.height)
            }
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        print("keyboard will be hidden")
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
       /* var scrollView : UIScrollView = m_vLogin
        if m_blLoginScreen == false {
            scrollView = m_vSignup
        }
        
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        scrollView.isScrollEnabled = false*/
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
}

var vSpinner : UIView?

extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

