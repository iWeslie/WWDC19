//
//  ViewController.swift
//  MindTheStone3D
//
//  Created by Weslie on 2019/3/22.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    var sceneView = ARSCNView()
    var scene: SCNScene!
    var spawnPlane: SCNNode!
    var shipNode: SCNNode!
    
    var playBtn: UIButton?
    var hudImg: UIImageView?
    
    var scoreBtn: UIButton?
    var lifeBtn: UIButton?
    var score = 0
    var life = 3
    
    private var stones = Set<StoneNode>()
    

    private lazy var stoneGenerator: Timer = {
        return Timer(timeInterval: 1.0, repeats: true) {_ in
            self.spawnStone()
        }
    }()
    
    private lazy var coinGenerator: Timer = {
        return Timer(timeInterval: 5.0, repeats: true) {_ in
            self.spawnCoin()
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupNode()
        setupHUD()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let (direction, currentVector) = fetchUserLocation(in: self.sceneView.session.currentFrame)
        let geometryNode = LazerNode.fireLazer(acc: direction)
        geometryNode.position = currentVector
        geometryNode.physicsBody?.applyForce(direction * 20, asImpulse: true)
        scene.rootNode.addChildNode(geometryNode)
    }
    
    func setupScene() {
        self.view = sceneView
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        scene = sceneView.scene
        
        let configuration = ARWorldTrackingConfiguration()
//        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [])

    }
    
    func setupNode() {
        let plane = SCNPlane(width: 5, height: 4)
        let planeNode = SCNNode(geometry: plane)
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow.withAlphaComponent(0.3)
        
        spawnPlane = planeNode
        scene.rootNode.addChildNode(planeNode)
        spawnPlane.position.z -= 8
        
        let shipGeometry = SCNBox(width: 1, height: 1, length: 0.01, chamferRadius: 0.2)
        shipGeometry.firstMaterial?.diffuse.contents = UIColor.clear
        
        let shipNode = SCNNode(geometry: shipGeometry)
        let shape = SCNPhysicsShape(geometry: shipGeometry, options: nil)
        shipNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        shipNode.physicsBody?.isAffectedByGravity = false
        shipNode.physicsBody?.categoryBitMask = CollisionCategory.ship.rawValue
        shipNode.physicsBody?.contactTestBitMask = CollisionCategory.stone.rawValue
        scene.rootNode.addChildNode(shipNode)
        self.shipNode = shipNode
    }
    
    func setupTimer() {
        DispatchQueue.main.async {
            RunLoop.main.add(self.stoneGenerator, forMode: RunLoop.Mode.common)
            RunLoop.main.add(self.coinGenerator, forMode: RunLoop.Mode.common)
        }
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
        
        let leftHUD = UIImageView(frame: CGRect(x: 20, y: 60, width: 200, height: 325))
        leftHUD.image = UIImage(named: "left_hud")
        leftHUD.contentMode = .scaleAspectFill
        self.view.addSubview(leftHUD)
        
        playBtn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 30))
        playBtn?.setTitle("Play", for: .normal)
        playBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        playBtn?.titleLabel?.textColor = UIColor.red
        playBtn?.addTarget(self, action: #selector(playBtnClicked), for: .touchUpInside)
        self.view.addSubview(playBtn!)
        
        
        let lifeBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 200, y: 40, width: 200, height: 80))
        lifeBtn.setTitle("❤️ \(life)", for: .normal)
        lifeBtn.isUserInteractionEnabled = false
        lifeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .light)
        lifeBtn.titleLabel?.textColor = UIColor.white
        self.lifeBtn = lifeBtn
        self.view.addSubview(lifeBtn)
        
        let scoreBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 200, y: 120, width: 200, height: 80))
        scoreBtn.setTitle("🎯 0", for: .normal)
        scoreBtn.isUserInteractionEnabled = false
        scoreBtn.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .light)
        scoreBtn.titleLabel?.textColor = UIColor.white
        self.scoreBtn = scoreBtn
        self.view.addSubview(scoreBtn)
    }
    
    @objc func playBtnClicked() {
        setupTimer()
        
        spawnPlane.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        
        let skySphere = SCNSphere(radius: 20)
        skySphere.firstMaterial?.diffuse.contents = UIImage(named: "stars.jpg")
        skySphere.firstMaterial?.isDoubleSided = true
        let skyNode = SCNNode(geometry: skySphere)
        sceneView.scene.rootNode.addChildNode(skyNode)
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
         return true
    }
}

// MARK: - SCNSceneRendererDelegate
extension ViewController: SCNSceneRendererDelegate, ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        for stone in stones {
            if stone.presentation.position.z > 10 {
                stone.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
                self.stones.remove(stone)
            }
        }
        
        let cameraPosition = fetchUserLocation(in: self.sceneView.session.currentFrame).position
        shipNode.position = cameraPosition
        
        
//        for stone in stones {
//            if stone.presentation.position.z > 10 {
//                stone.removeFromParentNode()
//                self.stones.remove(stone)
//            }
//
//        }
//
//        scene.rootNode.enumerateChildNodes { (node, stop) in
//            if let stone = node as? StoneNode, stone.hit {
//                node.runAction(SCNAction.removeFromParentNode())
//            }
//
//            if node.presentation.position.z > 10 {
//
//            }
//        }
//        var nodeToRemove = [StoneNode]()
////        for stone in stones where stone.hit || stone.presentation.position.z > 10 {
//        for stone in stones where stone.presentation.position.z > 10 {
//            nodeToRemove.append(stone)
//        }

//        DispatchQueue.main.async {
////            nodeToRemove.forEach {
////                $0.removeFromParentNode()
////                self.stones.remove($0)
////            }
//            for stone in self.stones where stone.presentation.position.z > 5 {
//                stone.removeFromParentNode()
//            }
//        }
//        if let stoneNode = scene.rootNode.childNode(withName: "stone", recursively: true) {
//            if stoneNode.presentation.position.z > 8 {
//                print("remove")
//
//                stoneNode.childNodes.first?.removeFromParentNode()
//                stoneNode.removeFromParentNode()
//            }
//        }

        
//        scene.rootNode.childNodes.forEach { (node) in
//            if node.presentation.position.z > 8 {
//                node.removeFromParentNode()
//            }
//        }
    }
    
}

// MARK: - SCNPhysicsContactDelegate
extension ViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.lazer.rawValue {
            let lazerNode = contact.nodeB
            lazerNode.removeFromParentNode()
            
            let particleSystem = SCNParticleSystem(named: "explosion", inDirectory: nil)
            let systemNode = SCNNode()
            systemNode.addParticleSystem(particleSystem!)
            
            contact.nodeA.addChildNode(systemNode)
            contact.nodeA.physicsBody = SCNPhysicsBody()
            contact.nodeA.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            
            
            
            
            if contact.nodeA.name == "stone" {
                score += 1
            } else if contact.nodeA.name == "coin" {
                score += 10
            }
            
            DispatchQueue.main.async {
                self.scoreBtn?.setTitle("🎯 \(self.score)", for: .normal)
            }
//
//            let removeAction = SCNAction.removeFromParentNode()
//            contact.nodeA.runAction(SCNAction.sequence([removeAction]))
            
//            contact.nodeA.removeFromParentNode()
//            let stoneNode = contact.nodeA
//            let makeClear = SCNAction.run { _ in
//                stoneNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
//            }
//
//
//            let showExplosion = SCNAction.run { _ in
//                let particleSystem = SCNParticleSystem(named: "explosion", inDirectory: nil)
//                let systemNode = SCNNode()
//                systemNode.addParticleSystem(particleSystem!)
//                systemNode.position = stoneNode.position
//                self.sceneView.scene.rootNode.addChildNode(systemNode)
//            }
//
//            let removeAction = SCNAction.removeFromParentNode()
//
//            stoneNode.runAction(SCNAction.sequence([makeClear, showExplosion, removeAction]))
//            if let stone = contact.nodeA as? StoneNode {
//                stone.hit = true
//            }

        }
        
        if contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.stone.rawValue {
            if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.ship.rawValue {
                print("hit ship")
                
                contact.nodeB.removeFromParentNode()
                DispatchQueue.main.async {
                    self.stoneHitShip()
                }
                
                life -= 1
                if life >= 0 {
                    DispatchQueue.main.async {
                        self.lifeBtn?.setTitle("❤️ \(self.life)", for: .normal)
                    }
                } else {
                    print("You lose")
                    
                    // TODO: - stop game
                }
            }
        }
        
    }
}



extension ViewController {
    private func spawnStone() {
        let x = Float.random(in: -3...3)
        let y = Float.random(in: -3...3)
        let z = spawnPlane.position.z
        
        let stoneNode = StoneNode.spawnStone()
        stoneNode.position = SCNVector3(x, y, z)
        self.stones.insert(stoneNode)
        
        let randomOffsetForce = CGFloat.random(in: -0.01...0.01)
        stoneNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 0, z: 0, duration: TimeInterval.random(in: 0.1...1))))
        
        stoneNode.runAction(SCNAction.move(by: SCNVector3(x: 0, y: 0, z: 20), duration: TimeInterval.random(in: 5...50)))
        stoneNode.runAction(SCNAction.sequence([
            SCNAction.move(by: SCNVector3(x: 0, y: 0, z: 20), duration: 30),
            ]))
        //        stoneNode.physicsBody?.applyForce(SCNVector3(randomOffsetForce, randomOffsetForce, randomOffsetForce), asImpulse: true)
        
        spawnPlane.addChildNode(stoneNode)
    }
    
    private func spawnCoin() {
        let x = Float.random(in: -3...3)
        let y = Float.random(in: -3...3)
        let z = spawnPlane.position.z
        
        let coinNode = CoinNode.spawnCoin()
        coinNode.position = SCNVector3(x, y, z)
        coinNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 0, z: 0, duration: 0.4)))
        coinNode.runAction(SCNAction.move(by: SCNVector3(x: 0, y: 0, z: 30), duration: 20))
        
        spawnPlane.addChildNode(coinNode)
    }
    
    private func stoneHitShip() {
        let coverView = UIView(frame: UIScreen.main.bounds)
        coverView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        self.view.addSubview(coverView)
        UIView.animate(withDuration: 0.5, animations: {
            coverView.alpha = 0
        }) { (_) in
            coverView.removeFromSuperview()
        }
    }
    
    private func removeNodeWithExplosion(_ node: SCNNode) {
        let particleSystem = SCNParticleSystem(named: "explosion", inDirectory: nil)
        let systemNode = SCNNode()
        systemNode.addParticleSystem(particleSystem!)
        systemNode.position = node.position
        sceneView.scene.rootNode.addChildNode(systemNode)
        //        nodeA.addChildNode(systemNode)
        node.removeFromParentNode()
    }
}
