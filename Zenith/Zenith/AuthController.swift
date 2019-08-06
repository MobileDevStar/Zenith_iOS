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
        
        self.showSpinner(onView: self.view)
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            guard let strongSelf = self else { return }
            
            if error == nil {
                let username : String = user?.user.displayName ?? ""
                self!.firebaseLoginSuccess(username: username, email: email, password: password)
            } else {
                self!.displayToastMessage("Authentication failed")
            }
            self?.removeSpinner()
        }
    }
    
    private func firebaseLoginSuccess(username: String, email: String, password: String) {
        UserDefaults.standard.set(username, forKey: USERNAME_KEY)
        UserDefaults.standard.set(email, forKey: EMAIL_KEY)
        UserDefaults.standard.set(password, forKey: PASSWORD_KEY)
        
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
        guard let url = URL(string: "https://www.indiegogo.com/project/preview/031584c9") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
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
        
        self.showSpinner(onView: self.view)
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error == nil {
                let changeRequest = authResult?.user.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges { error in
                    if error == nil {
                        self.signupSuccess(username: username, email: email, password: password)
                    } else {
                        self.displayToastMessage("Creating username failed")
                    }
                    self.removeSpinner()
                }
            } else {
                self.displayToastMessage("Authentication failed")
                self.removeSpinner()
            }
        }
    }
    
    //private func firebaseLoginSuccess
    
    private func signupSuccess(username: String, email: String, password: String) {
        //let contribute = "5"
        UserDefaults.standard.set(username, forKey: USERNAME_KEY)
        UserDefaults.standard.set(email, forKey: EMAIL_KEY)
        UserDefaults.standard.set(password, forKey: PASSWORD_KEY)
        //UserDefaults.standard.set(contribute, forKey: CONTRIBUTE_KEY)
        
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
            Auth.auth().sendPasswordReset(withEmail: resetEmail!, completion: { (error) in
                if error != nil{
                    let resetFailedAlert = UIAlertController(title: "Reset Failed", message: "Error: \(String(describing: error?.localizedDescription))", preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetFailedAlert, animated: true, completion: nil)
                }else {
                    let resetEmailSentAlert = UIAlertController(title: "Reset email sent successfully", message: "Check your email", preferredStyle: .alert)
                    resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetEmailSentAlert, animated: true, completion: nil)
                }
            })
        }))
        //PRESENT ALERT
        self.present(forgotPasswordAlert, animated: true, completion: nil)
    }
    
    private func updateUI(contribute: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "VideoControllerID") as! VideoController
        controller.m_contribute = contribute
        //controller.m_contribute = "50"
        self.present(controller, animated: true, completion: nil)
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
        guard let path = Bundle.main.path(forResource: "title_login_480", ofType:"mp4") else {
            debugPrint("title_login_480.mp4 not found")
            return
        }
        
        let videoURL = URL(fileURLWithPath: path)
        let item = AVPlayerItem(url: videoURL)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AuthController.completedVideoPlay(note:)),name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        player = AVPlayer(playerItem: item)
        player.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        playerLayer = AVPlayerLayer(player: player)
        m_vVideo.frame = self.view.bounds
        playerLayer.frame = self.view.bounds
        
        m_vVideo.layer.addSublayer(playerLayer);
        //self.view.layer.addSublayer(playerLayer)
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
        
        let username: String = UserDefaults.standard.string(forKey: USERNAME_KEY) ?? ""
        let email: String = UserDefaults.standard.string(forKey: EMAIL_KEY) ?? ""
        let password: String = UserDefaults.standard.string(forKey: PASSWORD_KEY) ?? ""
        
        if username.isEmpty || email.isEmpty || password.isEmpty {
            //displayToastMessage("Please login")
            m_vLogin.isHidden = false
        } else {
            httpRequestSend(username: username, email: email)
        }
        
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
        let strURL = "https://api.indiegogo.com/2/campaigns/2526147/contributions.json"
        let params = ["api_token": "6293ec4d339638fcf3400178cb640c0c3de82c25ec8fbe3dfadb300c1c044b89", "email": email]
        
        self.showSpinner(onView: self.view)
        Alamofire.request(strURL, parameters: params).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Response Successful")
                if let json = response.result.value as? [String: Any] {
                    //print("JSON: \(json)") // serialized json response
                    var maxContribute: Int = 1
                    let contList = json["response"] as? [Any]
                    for item in contList! {
                        print(item)
                        let jsonCont = item as? [String: Any]
                        
                        let amount = jsonCont!["amount"] as! Int
                        if amount > maxContribute {
                            maxContribute = amount
                        }
                        //let logedName = jsonCont!["by"] as! String
                        //if logedName.caseInsensitiveCompare(username) == .orderedSame {}
                    }
                    
                    if maxContribute < 5 {
                        maxContribute = 1;
                    } else if maxContribute < 10 {
                        maxContribute = 5;
                    } else if maxContribute < 20 {
                        maxContribute = 10;
                    } else if maxContribute < 50 {
                        maxContribute = 20;
                    } else {
                        maxContribute = 50;
                    }
                    
                    UserDefaults.standard.set(maxContribute, forKey: CONTRIBUTE_KEY)
                    
                    self.updateUI(contribute: String(maxContribute))
                }
            case .failure(let error):
                print(error)
                let contribute: String = UserDefaults.standard.string(forKey: CONTRIBUTE_KEY) ?? "1"
                self.updateUI(contribute: contribute)
            }
            self.removeSpinner()
        }
        
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

