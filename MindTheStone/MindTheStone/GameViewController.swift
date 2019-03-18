//
//  GameViewController.swift
//  MindTheStone
//
//  Created by Weslie on 2019/3/17.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
	
	var scene: SCNScene!
	var scnView: SCNView!
	var wallNode: SCNNode!
	
	var centerPosition: CGPoint!
	
	private var stones = Set<StoneNode>()
	
	private lazy var generator: Timer = {
		return Timer(timeInterval: 1.0, repeats: true) { [weak self](_) in
			self?.spawnStone()
		}
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        scene = SCNScene(named: "art.scnassets/Scene/GameScene.scn")!
		
        
//        // create and add a camera to the scene
//        let cameraNode = SCNNode()
//        cameraNode.camera = SCNCamera()
//        scene.rootNode.addChildNode(cameraNode)
//
//        // place the camera
//        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
//
//        // create and add a light to the scene
//        let lightNode = SCNNode()
//        lightNode.light = SCNLight()
//        lightNode.light!.type = .omni
//        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
//        scene.rootNode.addChildNode(lightNode)
//
//        // create and add an ambient light to the scene
//        let ambientLightNode = SCNNode()
//        ambientLightNode.light = SCNLight()
//        ambientLightNode.light!.type = .ambient
//        ambientLightNode.light!.color = UIColor.darkGray
//        scene.rootNode.addChildNode(ambientLightNode)
//
		
        // retrieve the SCNView
        scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
		
		scnView.delegate = self
		
		setupHUD()
		
		setupTimer()
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
		
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(fireLazer))
        scnView.addGestureRecognizer(tapGesture)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		spawnStone()
	}
	
	func setupNode() {
		wallNode = scene.rootNode.childNode(withName: "wall", recursively: false)
	}
	
	func setupTimer() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [unowned self] in
			RunLoop.main.add(self.generator, forMode: RunLoop.Mode.common)
		}
	}
	
	@objc func fireLazer() {
		
		let geometry = SCNSphere(radius: 0.1)
		geometry.firstMaterial?.diffuse.contents = UIColor.blue

		let geometryNode = SCNNode(geometry: geometry)
		
		geometryNode.position = SCNVector3(x: 6, y: 4, z: 0)
		
		let lazer = SCNParticleSystem(named: "lazer.scnp", inDirectory: nil)!
		
		let force = SCNVector3(x: 0, y: 0 , z: -8)
		geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
		geometryNode.physicsBody?.applyForce(force, asImpulse: true)
		geometryNode.physicsBody?.isAffectedByGravity = false
		
		geometryNode.addParticleSystem(lazer)

		
		scene.rootNode.addChildNode(geometryNode)
	}
	
	func setupHUD() {
		let screenFrame = UIScreen.main.bounds
		centerPosition = CGPoint(x: screenFrame.width / 2 - 15, y: screenFrame.height / 2  - 15)
		let img = UIImageView(frame: CGRect(origin: centerPosition, size: CGSize(width: 30, height: 30)))
		img.image = UIImage(named: "hud")
		img.contentMode = .scaleAspectFit
		self.view.addSubview(img)
	}
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}

extension GameViewController: SCNSceneRendererDelegate {
	@objc func spawnStone() {
		
		let x: Float = Float(arc4random() % 10)
		let y: Float = Float(arc4random() % 10)
		let z: Float = -8
		
		let stoneNode = StoneNode.spawnStone()
		stoneNode.position = SCNVector3(x, y, z)
		
		self.stones.insert(stoneNode)
		let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
		physicsBody.isAffectedByGravity = false
		physicsBody.applyForce(SCNVector3(0, 0, 5), asImpulse: true)
		physicsBody.mass = 0.1
		
		
		stoneNode.physicsBody = physicsBody
		
		scene.rootNode.addChildNode(stoneNode)
	}
	
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		print("redner")
	}
}
