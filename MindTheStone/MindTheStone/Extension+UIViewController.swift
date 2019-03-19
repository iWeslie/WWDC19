//
//  Extension+UIViewController.swift
//  MindTheStone
//
//  Created by Weslie on 2019/3/19.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit
import ARKit

extension UIViewController {
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
}
