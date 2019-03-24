//
//  DeployPortalViewController.swift
//  MindTheStone3D
//
//  Created by Weslie on 2019/3/25.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import PlaygroundSupport

public class DeployPortalViewController: UIViewController, ARSCNViewDelegate, PlaygroundLiveViewSafeAreaContainer {
    
    var sceneView = ARSCNView()
    var scene: SCNScene!
    var spawnPlane: SCNNode!
    
    var playBtn: UIButton?
    var hudImg: UIImageView?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupNode()
        setupHUD()
        
    }
    
    func setupScene() {
        self.view = sceneView
        sceneView.delegate = self
        scene = sceneView.scene

        sceneView.clipsToBounds = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.trailingAnchor),
            sceneView.topAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.bottomAnchor)
        ])
        
        let configuration = ARWorldTrackingConfiguration()
        //        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [])
        
    }
    
    func setupNode() {
        let plane = SCNPlane(width: 6, height: 10)
        let planeNode = SCNNode(geometry: plane)
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "portal.png")
        
        spawnPlane = planeNode
        scene.rootNode.addChildNode(planeNode)
        spawnPlane.position.z -= 8
        
    }
    
   
    func setupHUD() {
        let screenFrame = UIScreen.main.bounds
        let centerPosition = CGPoint(x: screenFrame.width / 2 - 30, y: screenFrame.height / 2  - 20)
        let hudImg = UIImageView(frame: CGRect(origin: centerPosition, size: CGSize(width: 60, height: 40)))
        hudImg.image = UIImage(named: "hud_small")
        hudImg.contentMode = .scaleAspectFit
        self.view.addSubview(hudImg)
        
        let spaceshipImg = UIImageView(image: UIImage(named: "spaceship"))
        spaceshipImg.frame = UIScreen.main.bounds
        spaceshipImg.contentMode = .scaleAspectFill
        self.view.addSubview(spaceshipImg)
        
        
        playBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 100, y: 160, width: 200, height: 80))
        playBtn?.setTitle("Deploy", for: .normal)
        playBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 50, weight: .thin)
        playBtn?.titleLabel?.textColor = UIColor.white
        playBtn?.addTarget(self, action: #selector(playBtnClicked), for: .touchUpInside)
        self.view.addSubview(playBtn!)
    }
    
    @objc func playBtnClicked() {
       
        spawnPlane.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        
        let skySphere = SCNSphere(radius: 20)
        skySphere.firstMaterial?.diffuse.contents = UIImage(named: "sky2.png")
        skySphere.firstMaterial?.isDoubleSided = true
        let skyNode = SCNNode(geometry: skySphere)
        sceneView.scene.rootNode.addChildNode(skyNode)
        
        playBtn?.removeFromSuperview()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            PlaygroundPage.current.assessmentStatus = .pass(message: "Portal deployed successfully! Now you know how to deploy it. Click [**Next Page**](@next) to start your travel.")
        }
    }
}
