//
//  ViewController.swift
//  EA Client Example
//
//  Created by Antti Köliö on 25.3.2021.
//

import UIKit
import MegicalEasyAccess_SDK_iOS

class ViewController: UIViewController {
    
    private let bRegister = UIButton(type: .roundedRect)
    private let bAuth = UIButton(type: .roundedRect)
    private var authFlow: MegAuthFlow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EALog.config() // default logging conf, you can do this yourself also
        
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
            // get this from the service we are authenticating against
            let clientToken = "91b06ab0-9c8d-4483-b716-5b130c3eb212"
            self.registerClient(clientToken)
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

    private func registerClient(_ clientToken: String) {
        let clientKey = MegAuthJwkKey(keychainTagPrivate: CLIENT_KEY_TAG_PRIVATE,
                                      keychainTagPublic: CLIENT_KEY_TAG_PUBLIC,
                                      jwkUseClause: "sig")
        var jwkPKData: Data
        do {
            jwkPKData = try clientKey.jwkJsonDataFromPublicKey()
        } catch {
            return
        }
        
        MegAuthRegistrationFlow.registerClient(authServerAddress: AUTH_SERVER_ADDRESS,
                                               clientToken: clientToken,
                                               clientType: CLIENT_TYPE,
                                               appId: APP_ID,
                                               authCallback: AUTH_CALLBACK_OAUTH,
                                               jwkPublicKeyData: jwkPKData,
                                               keychainKeyClientId: KEYCHAIN_CLIENT_ID) { (clientId: String?, error: Error?) in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let clientId = clientId else {
                return
            }
            
            print("Client registered with id: \(clientId)")
        }
    }
    
    private func authenticate() {
        let authFlow = MegAuthFlow()
        self.authFlow = authFlow
        
        authFlow.authorize(authServerAddress: AUTH_SERVER_ADDRESS,
                           authCallbackEA: AUTH_CALLBACK_EA,
                           authCallbackOauth: AUTH_CALLBACK_OAUTH,
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
        
        guard let verifyURL = URL(string: AUTH_VERIFY_URL) else {
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
                
                print("id token validated and got access code: \(accessTokenResult.accessToken)")
                
            }
        }
    }

}
