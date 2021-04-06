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
public struct PlaygroundAPI {
    
    public static func playgroundClientToken(appToken: String,
                                             completion: @escaping (_ clientToken: String?, _ error: Error?) -> Void) {
        
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
            //        "megical:callback",
            //        "https://megical_callback",
            //        "com.megical.ea.example:/oauth-callback"
            //    ],
            //    "url": "https://auth-dev.megical.com/api/v1/client"
            //}

            guard let clientToken = jsonObj["clientToken"] as? String else {
                completion(nil, EAErrorUtil.error(domain: "PlaygroundAPI", code: -1, underlyingError: nil, description: "No clientToken"))
                return
            }
            
            completion(clientToken, nil)
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

