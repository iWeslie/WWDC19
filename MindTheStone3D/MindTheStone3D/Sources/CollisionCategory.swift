//
//  CollisionCategory.swift
//  MindTheStone
//
//  Created by Weslie on 2019/3/19.
//  Copyright © 2019 weslie. All rights reserved.
//

public enum CollisionCategory: Int {
	case lazer	= 0b0001
	case stone  = 0b0010
	case coin 	= 0b0100
	case ship 	= 0b1000
}
