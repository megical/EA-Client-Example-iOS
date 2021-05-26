//
//  PlaygroundAPI.swift
//  EA Client Example
//
//  Created by Antti Köliö on 31.3.2021.
//

import Foundation
import SwiftyBeaver
import MegicalEasyAccess_SDK_iOS

/**
 https://playground.megical.com/test-service/docs/api
*/


public struct PlaygroundClientTokenReturnValue {
    var clientToken: String
    var audience: String
    var authEnvUrl: String
    var authEnv: String
    
    public init(clientToken: String,
                         audience: String,
                         authEnvUrl: String,
                         authEnv: String) {
        self.clientToken = clientToken
        self.audience = audience
        self.authEnvUrl = authEnvUrl
        self.authEnv = authEnv
    }
}


public struct PlaygroundAPI {
    
    public static func playgroundClientToken(appToken: String,
                                             completion: @escaping (_ returnValue: PlaygroundClientTokenReturnValue?,
                                                                    _ error: Error?) -> Void) {
        
        let bodyContent = "{ \"token\":\"\(appToken)\" }"
        guard let bodyData = bodyContent.data(using: .utf8) else {
            return
        }
        
        guard let url = URL(string: "https://playground.megical.com/test-service/api/v1/public/openIdClientData") else {
            return
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.cachePolicy = .reloadIgnoringCacheData
        req.httpBody = bodyData
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: req) { (dataOpt: Data?,
                                                            response: URLResponse?,
                                                            error: Error?) in
            
            guard error == nil else {
                SwiftyBeaver.warning(error!)
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, EAErrorUtil.error(domain: "PlaygroundAPI", code: -1, underlyingError: nil, description: "No http response"))
                return
            }
            
            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                var responseDataStr = ""
                if let data = dataOpt {
                    responseDataStr = String(data: data, encoding: .utf8) ?? ""
                }
                completion(nil, EAErrorUtil.error(domain: "PlaygroundAPI", code: -1, underlyingError: nil, description: "status code not 200 or 201 (\(httpResponse.statusCode). \(responseDataStr)"))
                return
            }
            
            guard let data = dataOpt else {
                completion(nil, EAErrorUtil.error(domain: "PlaygroundAPI", code: -1, underlyingError: nil, description: "No data"))
                return
            }
            
            var jsonObj: [String: Any]
            do {
                jsonObj = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            } catch {
                completion(nil, error)
                return
            }
            
            SwiftyBeaver.info(jsonObj)
            
            // JSON contains
            //{
            //    "appId": "test-app",
            //    "clientToken": "4881ef3c-357f-4e47-a9be-cc707187a964",
            //    "redirectUrls": [
            //    ],
            //    audience =     (
            //       "https://playground.megical.com"
            //    ),
            //    "url": "https://auth-dev.megical.com/api/v1/client"
            //    authEnvUrl: 'https://auth-dev.megical.com',
            //    authEnv: 'dev',
            //}
            
            guard let redirectUrls = jsonObj["redirectUrls"] as? [String] else {
                completion(nil, EAErrorUtil.error(domain: "PlaygroundAPI", code: -1, underlyingError: nil, description: "No redirect urls returned"))
                return
            }
            
            guard redirectUrls.filter({ (redirect: String) in
                return redirect == AUTH_CALLBACK_OAUTH
            }).count == 1 else {
                completion(nil, EAErrorUtil.error(domain: "PlaygroundAPI", code: -1, underlyingError: nil, description: "Server didn't return the redirect defined in the app"))
                return
            }

            guard let clientToken = jsonObj["clientToken"] as? String else {
                completion(nil, EAErrorUtil.error(domain: "PlaygroundAPI", code: -1, underlyingError: nil, description: "No clientToken"))
                return
            }
            
            guard let audiences = jsonObj["audience"] as? [String] else {
                completion(nil, EAErrorUtil.error(domain: "PlaygroundAPI", code: -1, underlyingError: nil, description: "No audience"))
                return
            }
            let audienceString = audiences.joined(separator: " ")
            
            guard let authEnvUrl = jsonObj["authEnvUrl"] as? String else {
                completion(nil, EAErrorUtil.error(domain: "PlaygroundAPI", code: -1, underlyingError: nil, description: "No authEnvUrl"))
                return
            }
            
            guard let authEnv = jsonObj["authEnv"] as? String else {
                completion(nil, EAErrorUtil.error(domain: "PlaygroundAPI", code: -1, underlyingError: nil, description: "No authEnv"))
                return
            }
            
            let retval = PlaygroundClientTokenReturnValue(clientToken: clientToken,
                                                          audience: audienceString,
                                                          authEnvUrl: authEnvUrl,
                                                          authEnv: authEnv)
            
            completion(retval, nil)
        }
        task.resume()
    }
    
    public static func playgroundHello(accessToken: String, completion: @escaping (_ error: Error?) -> Void) {
        
        guard let url = URL(string: "https://playground.megical.com/test-service/api/v1/private/hello") else {
            return
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.cachePolicy = .reloadIgnoringCacheData
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: req) { (dataOpt: Data?,
                                                            response: URLResponse?,
                                                            error: Error?) in
            
            guard error == nil else {
                SwiftyBeaver.warning(error!)
                completion(error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(EAErrorUtil.error(domain: "PlaygroundAPI", code: -1, underlyingError: nil, description: "No http response"))
                return
            }
            
            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                var responseDataStr = ""
                if let data = dataOpt {
                    responseDataStr = String(data: data, encoding: .utf8) ?? ""
                }
                completion(EAErrorUtil.error(domain: "PlaygroundAPI", code: -1, underlyingError: nil, description: "status code not 200 or 201 (\(httpResponse.statusCode). \(responseDataStr)"))
                return
            }
            
            if dataOpt != nil {
                SwiftyBeaver.info("Hello dataOpt: \(String(data: dataOpt!, encoding: .utf8)!)")
            }
            
            completion(nil)
        }
        task.resume()
    }
}

