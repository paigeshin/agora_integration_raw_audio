//
//  PermissionManager.swift
//  AgoraIntegration
//
//  Created by paige on 2022/03/27.
//

import UIKit
import AVFoundation

class PermissionManager {
    

    func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            // Execute some code...
        }
    }
    
    func requestMicrophoneAccess(){
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            // Execute some code...
        }
        
    }

}
