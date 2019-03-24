//
//  StoneNode.swift
//  MindTheStone
//
//  Created by Weslie on 2019/3/18.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit
import SceneKit

public class StoneNode: SCNNode {
        
	public override init() {
		super.init()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public static func spawnStone() -> StoneNode {
		let stoneNode = StoneNode()
		stoneNode.name = "stone"
        
        let sphere = SCNScene(named: "stone_\(Int.random(in: 2...5)).scn")?.rootNode.childNodes.first?.geometry
        sphere?.firstMaterial?.diffuse.contents = UIImage(named: "stone_\(Int.random(in: 1...8)).jpg")
        stoneNode.scale = SCNVector3(x: 0.2, y: 0.2, z: 0.2)
		
        stoneNode.geometry = sphere
		let shape = SCNPhysicsShape(geometry: SCNSphere(radius: 0.25), options: nil)
		stoneNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
		stoneNode.physicsBody?.isAffectedByGravity = false
		
		stoneNode.physicsBody?.categoryBitMask = CollisionCategory.stone.rawValue
		stoneNode.physicsBody?.contactTestBitMask = CollisionCategory.lazer.rawValue | CollisionCategory.ship.rawValue
		
		return stoneNode
	}
}
