//
//  ViewController.swift
//  EA Client Example
//
//  Created by Antti Köliö on 25.3.2021.
//

import UIKit
import MegicalEasyAccess_SDK_iOS
import SwiftyBeaver

class ViewController: UIViewController {
    let log = SwiftyBeaver.self
    
    private let bRegister = UIButton(type: .roundedRect)
    private let bAuth = UIButton(type: .roundedRect)
    private var authFlow: MegAuthFlow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onExampleRegisterAppTokenReceived(notification:)),
                                               name: .init(rawValue: NOTIFICATION_NAME_REGISTER_APP_TOKEN_RECEIVED),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onEasyaccessSuccessWithLoginCode(notification:)),
                                               name: .init(rawValue: NOTIFICATION_NAME_EASY_ACCESS_SUCCESS),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onEasyAccessAuthCodeReceived(notification:)),
                                               name: .init(rawValue: NOTIFICATION_NAME_AUTH_CODE_RECEIVED),
                                               object: nil)
        
        self.bRegister.setTitle("Register Client", for: .normal)
        self.view.addSubview(self.bRegister)
        self.bRegister.translatesAutoresizingMaskIntoConstraints = false
        self.bRegister.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -40.0).isActive = true
        self.bRegister.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 40.0).isActive = true
        self.bRegister.addAction(UIAction(handler: { (action: UIAction) in
            // Client registration needs app token from the app we are actually authenticating to.
            // self.getClientTokenAndRegisterClient(appToken: "9911a2c4-cd31-498f-bfb7-c935629ce428")
            
            // In the example app we can get this by logging in to the service at
            // https://playground.megical.com/easyaccess/
            // and touching the test app client registration token code.
            guard let exampleUrl = URL(string: "https://playground.megical.com/easyaccess/") else {
                return
            }
//            com.megical.easyaccess.example:/register?clientToken=d5b044c6-ed6e-4f7e-9fe5-d8d2daf9137c
            UIApplication.shared.open(exampleUrl) { (handled: Bool) in }
        }), for: .touchUpInside)
        
        self.bAuth.setTitle("Authenticate", for: .normal)
        self.view.addSubview(self.bAuth)
        self.bAuth.translatesAutoresizingMaskIntoConstraints = false
        self.bAuth.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -40.0).isActive = true
        self.bAuth.leftAnchor.constraint(equalTo: bRegister.rightAnchor, constant: 40.0).isActive = true
        self.bAuth.addAction(UIAction(handler: { (action: UIAction) in
            self.authenticate()
        }), for: .touchUpInside)
    }
    
    /**
     Get clientToken from the service we are authenticating against.
     In the example we are getting clientToken with appToken we get
     by logging in to playground with easy access.

     Login to https://playground.megical.com/easyaccess/ to get
     one time example app token (valid 3 days) that looks like this:
     d9e734f7-353d-490d-9f78-42ce3c0f19ff
     */
    private func getClientTokenAndRegisterClient(appToken: String) {
        PlaygroundAPI.playgroundClientToken(appToken: appToken) { [weak self] (playgroundRetval: PlaygroundClientTokenReturnValue?, error: Error?) in
            guard let self = self else {
                return
            }
            
            guard error == nil else {
                self.log.warning(error!)
                return
            }
            
            guard let playgroundRetval = playgroundRetval else {
                self.log.warning("No retval from playground")
                return
            }
            
            UserDefaults.standard.setValue(playgroundRetval.audience, forKey: "eaAudience")
            UserDefaults.standard.setValue(playgroundRetval.authEnvUrl, forKey: "eaAuthEnvUrl")
            UserDefaults.standard.setValue(playgroundRetval.authEnv, forKey: "eaAuthEnv")
            
            self.log.info("Got clientToken")
            self.registerClient(clientToken: playgroundRetval.clientToken, authEnvUrl: playgroundRetval.authEnvUrl)
        }
    }
    
    private func registerClient(clientToken: String, authEnvUrl: String) {
        let clientKey = MegAuthJwkKey(keychainTagPrivate: CLIENT_KEY_TAG_PRIVATE,
                                      keychainTagPublic: CLIENT_KEY_TAG_PUBLIC,
                                      jwkUseClause: "sig")
        var jwkPKData: Data
        do {
            jwkPKData = try clientKey.jwkJsonDataFromPublicKey()
        } catch {
            return
        }
        
        MegAuthRegistrationFlow.registerClient(authServerAddress: authEnvUrl,
                                               clientToken: clientToken,
                                               authCallback: AUTH_CALLBACK_OAUTH,
                                               jwkPublicKeyData: jwkPKData,
                                               keychainKeyClientId: KEYCHAIN_CLIENT_ID) { (clientId: String?, error: Error?) in
            
            guard error == nil else {
                self.log.warning(error!)
                return
            }
            
            guard let clientId = clientId else {
                return
            }
            
            self.log.info("Client registered with id: \(clientId)")
        }
    }
    
    private func authenticate() {
        let authFlow = MegAuthFlow()
        self.authFlow = authFlow
        
        guard let authEnvUrl = UserDefaults.standard.string(forKey: "eaAuthEnvUrl"),
              let authEnv = UserDefaults.standard.string(forKey: "eaAuthEnv"),
              let audience = UserDefaults.standard.string(forKey: "eaAudience") else {
            self.log.warning("Registration parameters not found")
            return
        }
        
        authFlow.authorize(authServerAddress: authEnvUrl,
                           authEnv: authEnv,
                           authCallbackEA: AUTH_CALLBACK_EA,
                           authCallbackOauth: AUTH_CALLBACK_OAUTH,
                           audience: audience,
                           keychainKeyClientId: KEYCHAIN_CLIENT_ID,
                           alwaysShowQRViewOnController: nil) { (error: Error?) in
            
            guard error == nil else {
                print(error!)
                
                if let nsError: NSError = error as NSError? {
                    if nsError.code == MegAuthFlow.ERROR_CODE_EASY_ACCESS_APP_LAUNCH_FAILED {
                        print("Easy Access not installed?")
                    }
                }
                return
            }
        }
    }
    
    func verifyAuthWithLoginCode(_ loginCode: String) {
        guard let authFlow = self.authFlow else {
            return
        }
        
        guard let authEnvUrl = UserDefaults.standard.string(forKey: "eaAuthEnvUrl") else {
            self.log.warning("Registration parameters not found")
            return
        }
        
        guard let verifyURL = URL(string: "\(authEnvUrl)/api/v1/auth/verifyEasyaccess") else {
            self.log.warning("Could not form verify URL")
            return
        }
        
        authFlow.verify(loginCode: loginCode,
                        verifyUrl: verifyURL) { (error: Error?) in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            print("Verify complete")
        }
    }
    
    @objc private func onExampleRegisterAppTokenReceived(notification: Notification) {
        DispatchQueue.main.async {
            guard let appToken = notification.object as? String else {
                return
            }
            
            // Network might not be usable straight after switching apps
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] (timer: Timer) in
                guard let self = self else {
                    return
                }
                DispatchQueue.main.async {
                    self.getClientTokenAndRegisterClient(appToken: appToken)
                }
            }
        }
    }
    
    @objc private func onEasyaccessSuccessWithLoginCode(notification: Notification) {
        DispatchQueue.main.async {
            guard let loginCode = notification.object as? String else {
                return
            }
            
            // Network might not be usable straight after switching apps
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] (timer: Timer) in
                guard let self = self else {
                    return
                }
                DispatchQueue.main.async {
                    self.verifyAuthWithLoginCode(loginCode)
                }
                
            }
        }
    }
    
    @objc private func onEasyAccessAuthCodeReceived(notification: Notification) {
        DispatchQueue.main.async {
            guard let authFlow = self.authFlow else {
                return
            }
            guard let notificationDict = notification.object as? [String: Any] else {
                return
            }
                        
            MegAuthTokenFlow.handleAuthCodeNotificationObject(notificationObject: notificationDict,
                                                              authFlow: authFlow,
                                                              keychainKeyClientId: KEYCHAIN_CLIENT_ID,
                                                              clientKeyTagPrivate: CLIENT_KEY_TAG_PRIVATE,
                                                              clientKeyTagPublic: CLIENT_KEY_TAG_PUBLIC) { (handled: Bool,
                                                                                                            accessTokenResult: MegAuthAccessTokenResult?,
                                                                                                            error: Error?) in
                guard error == nil else {
                    print(error!)
                    return
                }
                
                guard handled else {
                    print("Warn: Auth code result not handled. No code or wrong auth state.")
                    return
                }
                
                guard let accessTokenResult = accessTokenResult else {
                    print("Error: accessTokenResult was nil")
                    return
                }
                
                self.log.info("id token validated and got access code: \(accessTokenResult.accessToken)")
                
                PlaygroundAPI.playgroundHello(accessToken: accessTokenResult.accessToken) { [weak self] (error: Error?) in
                    guard let self = self else {
                        return
                    }
                    
                    guard error == nil else {
                        self.log.warning(error!)
                        return
                    }
                    
                    self.log.info("playgroundHello ok")
                }
                
            }
        }
    }

}
