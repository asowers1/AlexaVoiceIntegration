//
//  ViewController.swift
//  AlexaVoiceIntegration
//
//  Created by Dan Edgar on 6/1/16.
//  Copyright © 2016 Batgar, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    private let tempFilename = "\(NSTemporaryDirectory())hacker.wav"
    var simplePCMRecorder : SimplePCMRecorder
    var alexaAccessToken : String?
    private var isTalking : Bool = false
    private var player: AVAudioPlayer?
    
    @IBOutlet weak var talkingStateButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {        
        self.simplePCMRecorder = SimplePCMRecorder(numberBuffers: 1)
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        AIMobileLib.clearAuthorizationState(AIAuthenticationEventHandler(
            name: "Clear Or Logout",
            fail: {() -> Void in
                NSLog("Clear Or Logout Fail")
            },
            success: {(result : APIResult!) -> Void in
                NSLog("Clear Or Logout Success")
        }));
      
        let options = [kAIOptionScopeData: "{\"alexa:all\":{\"productID\":\"AlexaIntegration\", \"productInstanceAttributes\": {\"deviceSerialNumber\":\"amzn1.application-oa2-client.b82416e5524346c2896cc3f014a3ac67\"}}}"]
        
        // Do any additional setup after loading the view, typically from a nib.
        AIMobileLib.authorizeUserForScopes(["alexa:all"],
               delegate: AIAuthenticationEventHandler(
                    name:"Authorize",
                    fail:{ () -> Void in
                        NSLog("Failure getting authentication token")
                    },
                    success:{ (_ : APIResult!) -> Void in
                        
                        let accessTokenHandler = AIAuthenticationEventHandler(
                            name:"AccessToken",
                            fail: {() -> Void in
                                NSLog("Failure getting access token")
                            },
                            success: {(accessTokenAPIResult : APIResult!) -> Void in
                                if let accessToken = accessTokenAPIResult.result as? String {
                                    NSLog("We have an access token? Woo? - Access Token: \(accessToken)")
                                    self.talkingStateButton.enabled = true
                                    self.alexaAccessToken = accessToken
                                }
                            }
                        )
                        
                        AIMobileLib.getAccessTokenForScopes(["alexa:all"],
                            withOverrideParams: nil ,
                            delegate: accessTokenHandler
                        )
                    }
            ),
            options: options)
        
        // Have the recorder create a first recording that will get tossed so it starts faster later
        try! self.simplePCMRecorder.setupForRecording(tempFilename, sampleRate:16000, channels:1, bitsPerChannel:16, errorHandler: nil)
        try! self.simplePCMRecorder.startRecording()
        try! self.simplePCMRecorder.stopRecording()
        self.simplePCMRecorder = SimplePCMRecorder(numberBuffers: 1)
        
    }
    
   
    
    @IBAction func onStartStopTalking(sender: AnyObject) {
        toggleRecord()
    }
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toggleRecord() {
        if isTalking {
            isTalking = false
            talkingStateButton.setTitle("Start Talking", forState:UIControlState.Normal)
            
            try! self.simplePCMRecorder.stopRecording()
            self.upload()
        }
        else {
            self.simplePCMRecorder = SimplePCMRecorder(numberBuffers: 1)
            
            try! self.simplePCMRecorder.setupForRecording(tempFilename, sampleRate:16000, channels:1, bitsPerChannel:16, errorHandler: { (error:NSError) -> Void in
               try! self.simplePCMRecorder.stopRecording()
            })
            
            isTalking = true
            talkingStateButton.setTitle("Stop and Send", forState:UIControlState.Normal)
            try! self.simplePCMRecorder.startRecording()
        }
        
    }
    
    private func upload() {
        let uploader = AVSUploader()
        
        uploader.startUpload(self.alexaAccessToken!,
          audioData: NSData(contentsOfFile: tempFilename)!,
          errorHandler: {(error:NSError) in
                //TODO: Put in error handling.
          },
          progressHandler: {(progress:Double) in
                //TODO: Put in progress monitoring.
          },
          successHandler:{ (audioData: NSData) in
            do {
                
                self.player = try AVAudioPlayer(data: audioData)
                //self.player?.delegate = self
                self.player?.play()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // self.statusLabel.stringValue = "Playing response"
                })
                
            } catch let error {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //self.statusLabel.stringValue = "Playing error: \(error)"
                    //self.recordButton.enabled = true
                })
                
            }
          })
    }
    
    
    
}

