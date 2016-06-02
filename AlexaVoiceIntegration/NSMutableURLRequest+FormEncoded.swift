//
//  NSMutableURLRequest+FormEncoded.swift
//  AlexaVoiceIntegration
//
//  Created by Dan Edgar on 6/1/16.
//  Copyright © 2016 Batgar, Inc. All rights reserved.
//

import Foundation

extension NSMutableURLRequest {
    
    /// Percent escape
    ///
    /// Percent escape in conformance with W3C HTML spec:
    ///
    /// See http://www.w3.org/TR/html5/forms.html#application/x-www-form-urlencoded-encoding-algorithm
    ///
    /// - parameter string:   The string to be percent escaped.
    /// - returns:            Returns percent-escaped string.
    
    private func percentEscapeString(string: String) -> String {
        let characterSet = NSCharacterSet(charactersInString: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._* ")
        
        return string
            .stringByAddingPercentEncodingWithAllowedCharacters(characterSet)!
            .stringByReplacingOccurrencesOfString(" ", withString: "+", options: [], range: nil)
    }
    
    /// Encode the parameters for `application/x-www-form-urlencoded` request
    ///
    /// - parameter parameters:   A dictionary of string values to be encoded in POST request
    
    func encodeParameters(parameters: [String : String]) {
        HTTPMethod = "POST"
        
        HTTPBody = parameters
            .map { "\(percentEscapeString($0))=\(percentEscapeString($1))" }
            .joinWithSeparator("&")
            .dataUsingEncoding(NSUTF8StringEncoding)
    }
}
