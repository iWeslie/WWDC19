//
//  CoinNode.swift
//  MindTheStone
//
//  Created by Weslie on 2019/3/21.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit
import SceneKit

public class CoinNode: SCNNode {
	public override init() {
		super.init()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public static func spawnCoin() -> CoinNode {
		let coinNode = CoinNode()
		coinNode.name = "coin"
		
		let cylinder = SCNCylinder(radius: 0.2, height: 0.03)
		
		cylinder.firstMaterial?.diffuse.contents = UIImage(named: "coin.png")
		coinNode.geometry = cylinder
		
		let shape = SCNPhysicsShape(geometry: SCNSphere(radius: 0.2), options: nil)
		coinNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
		coinNode.physicsBody?.isAffectedByGravity = false
		
		coinNode.physicsBody?.categoryBitMask = CollisionCategory.coin.rawValue
		coinNode.physicsBody?.contactTestBitMask = CollisionCategory.lazer.rawValue
		
		return coinNode
	}
    
    public static func spawnDiamond() -> CoinNode {
        let diamondNode = CoinNode()
        diamondNode.name = "diamond"
        
        let diamond = SCNScene(named: "diamond.scn")?.rootNode.childNodes.first?.geometry
        diamondNode.scale = SCNVector3(x: 0.2, y: 0.2, z: 0.2)
        diamondNode.geometry = diamond
        
        let shape = SCNPhysicsShape(geometry: SCNSphere(radius: 0.2), options: nil)
        diamondNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        diamondNode.physicsBody?.isAffectedByGravity = false
        
        diamondNode.physicsBody?.categoryBitMask = CollisionCategory.coin.rawValue
        diamondNode.physicsBody?.contactTestBitMask = CollisionCategory.lazer.rawValue
        
        return diamondNode
    }
}

