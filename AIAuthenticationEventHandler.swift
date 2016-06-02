//
//  AIAuthenticationEventHandler.swift
//  AlexaVoiceIntegration
//
//  Created by Dan Edgar on 6/2/16.
//  Copyright © 2016 Batgar, Inc. All rights reserved.
//

import Foundation

class AIAuthenticationEventHandler : NSObject, AIAuthenticationDelegate {
    init(name : String,
         fail: () -> Void,
         success: (APIResult!) -> Void) {
        eventHandlerName = name
        failHandler = fail
        successHandler = success
    }
    
    let eventHandlerName : String
    let failHandler : () -> Void
    let successHandler : (APIResult!) -> Void
    
    
    @objc func requestDidFail(errorResponse: APIError!) {
        NSLog("\(eventHandlerName) - \(errorResponse.error.message)")
        failHandler()
    }
    
    @objc func requestDidSucceed(apiResult: APIResult!) {
        NSLog("\(eventHandlerName) - \(apiResult.result)")
        successHandler(apiResult)
    }
}