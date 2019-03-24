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
		
		let sphere = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.01)
		
		sphere.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/Texture/stone_2.jpg")
		stoneNode.geometry = sphere
		
		let shape = SCNPhysicsShape(geometry: SCNSphere(radius: 0.25), options: nil)
		stoneNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
		stoneNode.physicsBody?.isAffectedByGravity = false
		
		stoneNode.physicsBody?.categoryBitMask = CollisionCategory.stone.rawValue
		stoneNode.physicsBody?.contactTestBitMask = CollisionCategory.lazer.rawValue | CollisionCategory.ship.rawValue
		
		return stoneNode
	}
}
