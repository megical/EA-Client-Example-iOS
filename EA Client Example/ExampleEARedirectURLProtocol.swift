//
//  ExampleEARedirectURLProtocol.swift
//  EA Client Example
//
//  Created by Antti Köliö on 25.3.2021.
//

import Foundation
import MegicalEasyAccess_SDK_iOS

class ExampleEARedirectURLProtocol: EARedirectURLProtocolBase {

    override class func oauthCallback() -> String {
        return AUTH_CALLBACK_OAUTH
    }
    
    override class func authCodeReceivedNotificationName() -> String {
        return NOTIFICATION_NAME_AUTH_CODE_RECEIVED
    }
}
