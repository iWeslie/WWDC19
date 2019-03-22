//
//  ViewController.swift
//  MindTheStone3D
//
//  Created by Weslie on 2019/3/22.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit
import SceneKit
import CoreMotion

class ViewController: UIViewController {
    
    var sceneView = SCNView()
    var scene: SCNScene!
    var cameraNode: SCNNode!
    
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupNode()
        setupHUD()
        setupMotionControl()
    }
    
    func setupScene() {
        
        self.view = sceneView
        self.scene = SCNScene(named: "GameScene.scn")!
        
        sceneView.scene = scene
        
//        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true
        
    }
    
    func setupHUD() {
        let screenFrame = UIScreen.main.bounds
        let centerPosition = CGPoint(x: screenFrame.width / 2 - 15, y: screenFrame.height / 2  - 15)
        let hudImg = UIImageView(frame: CGRect(origin: centerPosition, size: CGSize(width: 30, height: 30)))
        hudImg.image = UIImage(named: "hud")
        hudImg.contentMode = .scaleAspectFit
        self.view.addSubview(hudImg)
        
        let spaceshipImg = UIImageView(image: UIImage(named: "spaceship"))
        spaceshipImg.frame = UIScreen.main.bounds
        spaceshipImg.contentMode = .scaleAspectFill
        self.view.addSubview(spaceshipImg)
    }
    
    func setupNode() {
        cameraNode = scene.rootNode.childNode(withName: "camera", recursively: false)
    }
    
    func setupMotionControl() {
        if motionManager.isDeviceMotionAvailable {
            print("isDeviceMotionAvailable")
            motionManager.deviceMotionUpdateInterval = 0.017
            motionManager.startDeviceMotionUpdates(to: OperationQueue(), withHandler: deviceDidMove)
        }
    }
    
    func deviceDidMove(motion: CMDeviceMotion?, error: Error?) {
        if let motion = motion {
            DispatchQueue.main.async {
                self.cameraNode.orientation = motion.gaze(atOrientation: UIApplication.shared.statusBarOrientation)
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
         return true
    }
    
}

