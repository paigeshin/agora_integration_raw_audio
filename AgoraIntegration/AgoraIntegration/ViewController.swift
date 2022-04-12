//
//  ViewController.swift
//  AgoraIntegration
//
//  Created by paige on 2022/03/27.
//

import UIKit
import AgoraRtcKit

class ViewController: UIViewController {

    lazy var startButton: UIButton = {
        let button: UIButton = UIButton()
        button.backgroundColor = .brown
        button.setTitle("Start Audio Streaming", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startEvent(_:)), for: .touchUpInside)
        return button
    }()
    
    var isSpeakerOn: Bool = true
    
    lazy var speakerButton: UIButton = {
        let button: UIButton = UIButton()
        button.backgroundColor = .blue
        button.setTitle("Off", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(speakerEvent(_:)), for: .touchUpInside)
        return button
    }()
    
    let permissionManager: PermissionManager = PermissionManager()
    var agoraKit: AgoraRtcEngineKit?
    var channel: AgoraRtcChannel?
    
    override func loadView() {
        super.loadView()
        view.addSubview(startButton)
        view.addSubview(speakerButton)
        
        startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48).isActive = true
        startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48).isActive = true
        startButton.heightAnchor.constraint(equalToConstant: 49).isActive = true
        startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startButton.layer.cornerRadius = 8
        
        speakerButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        speakerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        speakerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -16).isActive = true
        speakerButton.layer.contents = 8
    }
    
    @objc
    func speakerEvent(_ sender: UIButton) {
        isSpeakerOn = !isSpeakerOn
        let title: String = isSpeakerOn ? "Off" : "On"
        speakerButton.setTitle(title, for: .normal)
        agoraKit?.enableLocalAudio(isSpeakerOn)
    }
    
    @objc
    func startEvent(_ sender: UIButton) {
        // MARK: INSTANIATE AGORA CHANNEL
        let mediaOptions: AgoraRtcChannelMediaOptions = AgoraRtcChannelMediaOptions()
        // allow user to provide audio
        mediaOptions.publishLocalAudio = true
        mediaOptions.autoSubscribeAudio = true
        channel = agoraKit?.createRtcChannel(kTempChannelName)
  
        // MARK: JOIN
        channel?.join(byToken: kTempToken, info: nil, uid: 0, options: mediaOptions)
        
        
        startButton.setTitle("Joined", for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if kAppId.isEmpty {
            fatalError("You must provide app id in Config.swift")
        }
        
        if kTempToken.isEmpty {
            fatalError("You must provide token in Config.swift")
        }
        
        if kTempChannelName.isEmpty {
            fatalError("You must provide channel name in Config.swift")
        }
        
        // MARK: REQUEST NECESSARY PERMISSIONS
        permissionManager.requestCameraAccess()
        permissionManager.requestMicrophoneAccess()
        
        // MARK: INSTANTIATE AGORA ENGINE
        let config: AgoraRtcEngineConfig = AgoraRtcEngineConfig()
        config.appId = kAppId
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        
        // MARK: SET CLIENT ROLE
        agoraKit?.setClientRole(.broadcaster)
        
        // MARK: TO RETRIEVE AUDIO DATA
        agoraKit?.setAudioDataFrame(self)
                
        // Set audio route to speaker
        agoraKit?.setDefaultAudioRouteToSpeakerphone(true)
        
        // Audio Volume
        agoraKit?.enableAudioVolumeIndication(1000, smooth: 3, report_vad: true)
        
 
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        agoraKit?.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
        agoraKit?.setAudioDataFrame(nil)
    }

}

// Callbacks for AgoraRtcEngineDelegate
extension ViewController: AgoraRtcEngineDelegate {
    // This callback is triggered when a remote user joins the channel
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {

    }
}
 

// Callbacks for AudioDataFrame
extension ViewController: AgoraAudioDataFrameProtocol {
    
    // playback, mixed, record, beforeMixing
    func getObservedAudioFramePosition() -> AgoraAudioFramePosition {
        return .playback
    }
    
    // Get Data
    func onRecord(_ frame: AgoraAudioFrame) -> Bool {
        return true
    }
    
    // Get Data
    func onPlaybackAudioFrame(_ frame: AgoraAudioFrame) -> Bool {
        return true
    }
    
    // Get Data
    func onPlaybackAudioFrame(beforeMixingEx frame: AgoraAudioFrame, channelId: String, uid: UInt) -> Bool {
        return true
    }
    
    // Get Data
    func onPlaybackAudioFrame(beforeMixing frame: AgoraAudioFrame, uid: UInt) -> Bool {
        return true
    }
    
    // Get Data
    func onMixedAudioFrame(_ frame: AgoraAudioFrame) -> Bool {
        return true
    }

    // Implement the getRecordAudioParams callback, and set the audio recording format in the return value of this callback.
    func getRecordAudioParams() -> AgoraAudioParam {
        let param = AgoraAudioParam()
        param.channel = 1
        param.mode = .readOnly
        param.sampleRate = 44100
        param.samplesPerCall = 1024
        return param
    }
    
    // Implement the getMixedAudioParams callback, and set the mixed audio format in the return value of this callback.
    func getMixedAudioParams() -> AgoraAudioParam {
        let param = AgoraAudioParam()
        param.channel = 1
        param.mode = .readOnly
        param.sampleRate = 44100
        param.samplesPerCall = 1024
        return param
    }
    
    // Implement the getMixedAudioParams callback, and set the playback audio format in the return value of this callback.
    func getPlaybackAudioParams() -> AgoraAudioParam {
        let param = AgoraAudioParam()
        param.channel = 1
        param.mode = .readOnly
        param.sampleRate = 44100
        param.samplesPerCall = 1024
        return param
    }
    
}
