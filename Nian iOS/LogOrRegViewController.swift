//
//  LogOrRegViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/20/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit
    
/**
LogOrRegViewController 上的唯一的复用的 Button 的功能类型

- confirm:  “确定” --- 检查邮箱是否已注册
- logIn:
- register:
*/
enum FunctionType: Int {
    case confirm
    case logIn
    case register
}

class LogOrRegViewController: UIViewController {

    // MARK: - 界面上的控件
    
    /// discriotion label 可以设置为 hidden
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emailTextField: NITextfield!
    /// 暂定 logIn 和 register 使用同一个密码框
    @IBOutlet weak var passwordTextField: NITextfield!
    /// 昵称 -- 在注册的最后一步将重用为“确认昵称”
    @IBOutlet weak var nicknameTextField: NITextfield!
    /// functional Button 可以复用为 “确定” “登录” “注册”
    @IBOutlet weak var functionalButton: CustomButton!
    /// “取消”Button 功能：返回欢迎界面(WelcomeVC)
    @IBOutlet weak var cancelButton: UIButton!
    /// "忘记密码"
    @IBOutlet weak var forgetPWDButton: UIButton!
    /// "隐私政策"的 Container View
    @IBOutlet weak var privacyContainerView: UIView!

    // MARK: - 几个需要改变的约束

    /// email text field 距离顶部的约束
    @IBOutlet weak var emailTextFieldToTop: NSLayoutConstraint!
    /// password text field 顶部到 email text field 的约束
    @IBOutlet weak var pwdTextFieldTopToEmail: NSLayoutConstraint!
    /// 昵称顶部到 passwoed 的约束 --- nick name 仅在注册时会用到，所以该约束也只有在注册时才有用
    @IBOutlet weak var nicknameTextFieldTopToPwd: NSLayoutConstraint!
    /// 唯一的 button 到 email text field 的约束
    @IBOutlet weak var functionalButtonTopToEmail: NSLayoutConstraint!
    
    // MARK: - Variables
    
    /// functionalType 决定了 functional button 的 text, 并决定 button 的 function
    var functionalType: FunctionType? {
        didSet {
            switch functionalType! {
            case .confirm:
                self.functionalButton?.setTitle("确定", forState: .Normal)
            case .logIn:
                self.functionalButton.setTitle("登录", forState: .Normal)
                self.descriptionLabel.hidden = true
            case .register:
                self.functionalButton.setTitle("注册", forState: .Normal)
                self.descriptionLabel.hidden = true
            }
        }
    }
    
    /// 检查邮箱是否注册的结果
    var checkEmailResult: NetworkClosure?
    /// 请求登录的结果
    var logInResult: NetworkClosure?
    /// 请求注册的结果
    var registerResult: NetworkClosure?

    // MARK: - view controller life recycle     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.radius = 22
        self.passwordTextField.radius = 22
        self.nicknameTextField.radius = 22
        
        self.emailTextField.layer.cornerRadius = 22
        self.emailTextField.layer.masksToBounds = true
        self.emailTextField.leftViewMode = .Always
        
        // Do any additional setup after loading the view.
        if self.functionalType == .confirm {
            self.passwordTextField.hidden = true
            self.nicknameTextField.hidden = true
            self.forgetPWDButton.hidden = true
            self.privacyContainerView.hidden = true
        }
        
        /* 设置 all textfields 的 delegate  */
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.nicknameTextField.delegate = self
        
        /// 监听 email textfield 不能有变化
        NSNotificationCenter.defaultCenter().addObserver(self,
                                            selector: "emailTextFieldDidChange:",
                                            name: UITextFieldTextDidChangeNotification,
                                            object: self.emailTextField)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UITextFieldTextDidChangeNotification,
            object: self.emailTextField)
    }
    
    
    // MARK: -
    /**
    当在登录或者注册时修改邮箱，将返回 “只有 emailTextField” 的状态
    
    :param: noti
    */
    func emailTextFieldDidChange(noti: NSNotification) {
        if self.functionalType != .confirm {
            let _textfield = noti.object as! UITextField
            
            if _textfield == self.emailTextField {
                // TODO: 返回 “只有 emailTextField” 的状态
                if self.functionalType == .logIn {
                    
                } else if self.functionalType == .register {
                    
                }
            }
        }
    }
    
    //MARK: - click on functionalButton
    
    @IBAction func onFunctionalButton(sender: UIButton) {
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
        
        /* 分别处理 “confirm” "logIn" "register" */
        if self.functionalType == .confirm {
            if let _text = self.emailTextField.text {
                if self.validateEmailAddress(_text) {
                    
                    self.functionalButton.startAnimating()
                    
                    LogOrRegModel.checkEmailValidation(email: self.emailTextField.text!) {
                        (task, responseObject, error) in
                        
                        self.functionalButton.stopAnimating()
                        
                        if let _error = error {
                            logError("\(_error.localizedDescription)")
                        } else {
                            let json = JSON(responseObject!)
                            if json["data"] == "0" {  // email 未注册
                                // 处理未注册
                                self.handleUnregisterEmail()
                            } else if json["data"] == "1" { // email 已注册
                                // 处理登陆
                                self.handleRegisterEmail()
                            }
                            
                        }
                    }
                } else {  //if self.validateEmailAddress == false
                    self.view.showTipText("不是地球上的邮箱...")
                }
            } else { // if let _text = self.emailTextField.text == nil
                self.view.showTipText("注册邮箱不能为空...")
            }
            
        } else if self.functionalType == .logIn {
            /*@explain: 这里不需要再验证邮箱 */
            if self.passwordTextField.text != "" {
                // TODO: spinner 
                
                let _email = self.emailTextField.text!
                let _password = "n*A\(self.passwordTextField.text!)"
                
                self.functionalButton.startAnimating()
                
                LogOrRegModel.logIn(email: _email, password: _password.md5) {
                    (task, responseObject, error) in
                    
                    self.functionalButton.stopAnimating()
                    
                    
                    if let _error = error {
                        logError("\(_error)")
                    } else {
                        let json = JSON(responseObject!)
                        
                        if json["error"] != 0 { // 服务器返回错误
                            
                        } else {
                            let shell = json["data"]["shell"].stringValue
                            let uid = json["data"]["uid"].stringValue
                            let username = json["data"]["username"].stringValue
                            
                            NSUserDefaults.standardUserDefaults().setObject(username, forKey: "user")
                            
                            /// uid 和 shell 保存到 keychain
                            let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
                            uidKey.setObject(uid, forKey: kSecAttrAccount)
                            uidKey.setObject(shell, forKey: kSecValueData)
                            
                            Api.requestLoad()
                            globalWillReEnter = 1
                            let mainViewController = HomeViewController(nibName:nil,  bundle: nil)
                            let navigationViewController = UINavigationController(rootViewController: mainViewController)
                            navigationViewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
                            navigationViewController.navigationBar.tintColor = UIColor.whiteColor()
                            navigationViewController.navigationBar.translucent = true
                            navigationViewController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
                            navigationViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                            navigationViewController.navigationBar.clipsToBounds = true
                            
                            self.presentViewController(navigationViewController, animated: true, completion: {
                                self.emailTextField.text = ""
                                self.passwordTextField.text = ""
                            })
                            Api.postDeviceToken() { string in }
                            Api.postJpushBinding(){_ in }
                            
                            
                            
                        } // if json["error"] != 0
                    } // if let _error = error
                }  // end of closure
            
            }  // if self.passwordTextField.text != ""
        } else if self.functionalType == .register {
            if self.passwordTextField.text != "" {
                if let _nickname = self.nicknameTextField.text {
                    if self.validateNickname(_nickname) {
                        self.performSegueWithIdentifier("toModeVC", sender: nil)
                    } else { // nickname 不符合要求
                        logError("nick name 被占用")
                    }
                } else { // 没有输入 nickname
                
                }
            } else { // 没有输入 password
                
            }
        }
    }
    
    /**
    点击空白 dismiss keyboard
    */
    @IBAction func dismissKeyboard(sender: UIControl) {
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
    }
    
    /**
    无论何时点击左上角的 cancel button, 都将回到 welcome view controller
    */
    @IBAction func backWelcomeViewController(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toModeVC" {
            let regInfo = RegInfo(email: self.emailTextField.text!, nickname: self.nicknameTextField.text!, password: self.passwordTextField.text!)
            
            let patternViewController = segue.destinationViewController as! PatternViewController
            patternViewController.regInfo = regInfo
        }
        
    }

}

// MARK:
// MARK: - UITextFieldDelegate
extension LogOrRegViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        return true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        
    }

}

// MARK: 
// MARK: - 处理事件
extension LogOrRegViewController {
    
    /**
    验证邮箱是否正确
    */
    func validateEmailAddress(text: String) -> Bool {
        if text == "" {
            return false
        } else if !text.isValidEmail() {
            return false
        }
        
        return true
    }
    
    /**
    验证昵称是否符合要求
    */
    func validateNickname(name: String) -> Bool {
        if name == "" {
            return false
        } else if name.characters.count < 4 {
            return false
        } else if !name.isValidName() {
            return false
        }
        
        return true
    }
    
    /**
    email 未注册，View 进入注册的状态
    */
    func handleUnregisterEmail() {
        
        self.passwordTextField.layer.cornerRadius = 22
        self.passwordTextField.layer.masksToBounds = true
        self.passwordTextField.leftViewMode = .Always
        
        self.nicknameTextField.layer.cornerRadius = 22
        self.nicknameTextField.layer.masksToBounds = true
        self.nicknameTextField.leftViewMode = .Always
        
        self.passwordTextField.hidden = false
        self.nicknameTextField.hidden = false
        self.functionalType = .register
        
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(0.4, animations: {
            self.emailTextFieldToTop.constant = 48
            self.pwdTextFieldTopToEmail.constant = 8
            self.nicknameTextFieldTopToPwd.constant = 8
            self.functionalButtonTopToEmail.constant = 128
            
            self.view.layoutIfNeeded()
        })
        
        self.privacyContainerView.hidden = false
        
        self.passwordTextField.becomeFirstResponder()
    }
    
    /**
    email 已注册，View 进入登陆状态
    */
    func handleRegisterEmail() {
        self.passwordTextField.layer.cornerRadius = 22
        self.passwordTextField.layer.masksToBounds = true
        self.passwordTextField.leftViewMode = .Always
        
        self.passwordTextField.hidden = false
        self.functionalType = .logIn
        
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(0.4, animations: {
            self.emailTextFieldToTop.constant = 48
            self.pwdTextFieldTopToEmail.constant = 8
            self.functionalButtonTopToEmail.constant = 76
            
            self.view.layoutIfNeeded()
        })
        
        self.forgetPWDButton.hidden = false
        
        self.passwordTextField.becomeFirstResponder()
    }
    
    
    
    
}


















