//
//  FindYourShipViewController.swift
//  FindYourShip
//
//  Created by Weslie on 2019/3/22.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import PlaygroundSupport

public class FindYourShipViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer {

    var sceneView = ARSCNView()
    
    var updateCount = 0 {
        didSet {
            if updateCount >= 50 {
                playBtn?.isHidden = false
            }
        }
    }
    var planeNode: SCNNode?
    var scene: SCNScene!

    var playBtn: UIButton?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = false
        
        self.view = sceneView
        
        sceneView.clipsToBounds = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.trailingAnchor),
            sceneView.topAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.bottomAnchor)
            ])
        
        playBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 100, y: 160, width: 200, height: 80))
        playBtn?.setTitle("Land", for: .normal)
        playBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 50, weight: .thin)
        playBtn?.titleLabel?.textColor = UIColor.white
        playBtn?.addTarget(self, action: #selector(playBtnClicked), for: .touchUpInside)
        self.view.addSubview(playBtn!)
        playBtn?.isHidden = true
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        resetAll()
    }

    @objc func playBtnClicked() {
        if updateCount >= 50 {
            sceneView.debugOptions = []
            stopTracking()
            planeNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            
            let scene = SCNScene(named: "ship1.scn")!
            let ship = scene.rootNode
            ship.transform = SCNMatrix4MakeRotation(Float.pi / 2, 1, 0, 0)
            
            planeNode?.addChildNode(ship)
            
            playBtn?.removeFromSuperview()

            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                PlaygroundPage.current.assessmentStatus = .pass(message: "**Nice!** 🎊 Your spaceship is landed. Now board your spaceship 🚀. Click [**Next Page**](@next) to deploy a portal to travel to outer space.")
            }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}

extension FindYourShipViewController {
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    private func stopTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .init(rawValue: 0)
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
    }
    
    private func resetAll() {
        resetTracking()
        updateCount = 0
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    private func createPlaneNode(center: vector_float3, extent: vector_float3) -> SCNNode {
        
        let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
        
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.yellow.withAlphaComponent(0.4)
        plane.materials = [planeMaterial]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(center.x, 0, center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        return planeNode
    }
}

extension FindYourShipViewController: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor, node.childNodes.count < 1, updateCount < 1 {
            print("detected plane")
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            plane.firstMaterial?.diffuse.contents = UIColor.red
            
            let debugPlaneNode = createPlaneNode(center: planeAnchor.center, extent: planeAnchor.extent)
            debugPlaneNode.name = "debugPlaneNode"
            
            planeNode = debugPlaneNode
            
            node.addChildNode(debugPlaneNode)
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        updateCount += 1
        
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
}
