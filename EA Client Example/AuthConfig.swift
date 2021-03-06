//
//  AuthConfig.swift
//  EA Client Example
//
//  Created by Antti Köliö on 25.3.2021.
//

import Foundation


fileprivate let urlScheme = "com.megical.easyaccess.example"
fileprivate let eaRegisterCallbackPath = "register"
fileprivate let eaAuthCallbackPath = "ea-callback-auth"
fileprivate let eaSignCallbackPath = "ea-callback-sign"
fileprivate let oauthCallbackPath = "oauth-callback"

let CLIENT_KEY_TAG_PRIVATE = "com.megical.example.client.private"
let CLIENT_KEY_TAG_PUBLIC = "com.megical.example.client.public"
let CLIENT_TYPE = "easyaccessDev"
let AUTH_CALLBACK_EA = "\(urlScheme):/\(eaAuthCallbackPath)"
let SIGN_CALLBACK_EA = "\(urlScheme):/\(eaSignCallbackPath)"
let AUTH_CALLBACK_OAUTH = "\(urlScheme):/\(oauthCallbackPath)"
let AUTH_CALLBACK_REGISTER = "\(urlScheme):/\(eaRegisterCallbackPath)"
let KEYCHAIN_CLIENT_ID = "exampleAuthClientId"
let NOTIFICATION_NAME_REGISTER_APP_TOKEN_RECEIVED = "NOTIFICATION_NAME_REGISTER_APP_TOKEN_RECEIVED"
let NOTIFICATION_NAME_EASY_ACCESS_AUTH_SUCCESS = "NOTIFICATION_NAME_EASY_ACCESS_AUTH_SUCCESS"
let NOTIFICATION_NAME_EASY_ACCESS_SIGN_SUCCESS = "NOTIFICATION_NAME_EASY_ACCESS_SIGN_SUCCESS"
let NOTIFICATION_NAME_AUTH_CODE_RECEIVED = "NOTIFICATION_NAME_AUTH_CODE_RECEIVED"
