//
//  ViewController.swift
//  Test
//
//  Created by Weslie on 2019/3/17.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    
    @IBOutlet weak var cloudImg: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cloudImg.alpha = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1.0) {
            self.cloudImg.alpha = 1
        }
        
     
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.toValue = CGFloat.pi
        rotate.duration = 0.6
        rotate.isCumulative = true
        rotate.repeatCount = Float.infinity
        
        containerView.subviews.forEach { $0.layer.add(rotate, forKey: "rotate")}
//        aimImg.layer.add(rotate, forKey: "rotate")
        
    }


}

