//
//  AuthConfig.swift
//  EA Client Example
//
//  Created by Antti Köliö on 25.3.2021.
//

import Foundation


fileprivate let urlScheme = "com.megical.ea.example"
let eaCallbackPath = "ea-callback"
fileprivate let oauthCallbackPath = "oauth-callback"

let AUTH_SERVER_ADDRESS = "https://auth-dev.megical.com"
let AUTH_VERIFY_URL = "\(AUTH_SERVER_ADDRESS)/api/v1/auth/verifyEasyaccess"
let CLIENT_KEY_TAG_PRIVATE = "com.megical.example.client.private"
let CLIENT_KEY_TAG_PUBLIC = "com.megical.example.client.public"
let APP_ID = "com.megical.example"
let CLIENT_TYPE = "easyaccessDev"
let AUDIENCE = "https://megical.com"
let AUTH_CALLBACK_EA = "\(urlScheme):/\(eaCallbackPath)"
let AUTH_CALLBACK_OAUTH = "\(urlScheme):/\(oauthCallbackPath)"
let KEYCHAIN_CLIENT_ID = "exampleAuthClientId"
let NOTIFICATION_NAME_EASY_ACCESS_SUCCESS = "easyaccessSuccessWithLoginCode"
let NOTIFICATION_NAME_AUTH_CODE_RECEIVED = "easyAccessAuthCodeReceived"
