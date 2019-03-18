//
//  GameViewController.swift
//  MindTheStone
//
//  Created by Weslie on 2019/3/17.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class GameViewController: UIViewController {
    
	
	var scene: SCNScene!
    public var sceneView: ARSCNView = ARSCNView()
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
        
        self.view = sceneView
        
//        sceneView.clipsToBounds = true
//        sceneView.translatesAutoresizingMaskIntoConstraints = false
        
//        NSLayoutConstraint.activate([
//            sceneView.leadingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.leadingAnchor),
//            sceneView.trailingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.trailingAnchor),
//            sceneView.topAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.topAnchor),
//            sceneView.bottomAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.bottomAnchor)
//            ])
        
        sceneView.delegate = self
        
        let scene = SCNScene(named: "art.scnassets/Scene/GameScene.scn")!
        sceneView.scene = scene
		
		setupHUD()
		
		setupTimer()
        
        // allows the user to manipulate the camera
        sceneView.allowsCameraControl = true
		
        // show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(fireLazer))
        sceneView.addGestureRecognizer(tapGesture)
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
		
		let force = SCNVector3(x: 0, y: 0 , z: -30)
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

extension GameViewController: ARSCNViewDelegate {
    
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
