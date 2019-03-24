//
//  Extension+UIViewController.swift
//  MindTheStone
//
//  Created by Weslie on 2019/3/19.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit
import ARKit

public extension UIViewController {
	func fetchUserLocation(in frame: ARFrame?) -> (direction: SCNVector3, position: SCNVector3) {
		if let _ = frame {
			let matrix = SCNMatrix4(frame!.camera.transform)
			let direction = SCNVector3(-matrix.m31, -matrix.m32, -matrix.m33)
			let currentVector = SCNVector3(matrix.m41, matrix.m42, matrix.m43)
			return (direction, currentVector)
		} else {
			return (SCNVector3Zero, SCNVector3Zero)
		}
	}
    
    func playSound(_ type: SoundType) {
        SoundHelper.shared.playSound(of: type)
    }
}
import Foundation
import SceneKit
import AudioToolbox

public enum SoundType: String {
    // case background
    case bullet
    case hitStone
    case hitCoin
    case hitDiamond
    case hitShip
    case win
    case lose
}

public class SoundHelper: NSObject {
    
    public static let shared: SoundHelper = SoundHelper()
    
    private var soundIds: [SoundType: SystemSoundID] = [:]
    
    private override init() {
        
        for type in [
            // SoundType.background,
            SoundType.bullet,
            SoundType.hitStone,
            SoundType.hitCoin,
            SoundType.hitDiamond,
            SoundType.hitShip,
            SoundType.win,
            SoundType.lose
            ] {
                var soundID: SystemSoundID = 0
                let path = Bundle.main.path(forResource: type.rawValue, ofType: "wav")
                let baseURL = NSURL(fileURLWithPath: path!)
                AudioServicesCreateSystemSoundID(baseURL, &soundID)
                
                soundIds[type] = soundID
        }
    }
    
    public func playSound(of type: SoundType) {
        AudioServicesPlaySystemSound(soundIds[type]!)
    }
    
}
