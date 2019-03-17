//
//  Birth.swift
//  Test
//
//  Created by Weslie on 2019/3/17.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit

public class Birth: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: 768, height: 576)
        
        generateMolecularCloud()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func generateMolecularCloud() {
        let cloudImg = UIImageView(frame: self.frame)
        cloudImg.image = UIImage(named: "m42.jpg")
        cloudImg.contentMode = .scaleAspectFill
        cloudImg.alpha = 0
        self.addSubview(cloudImg)
        
        UIView.animate(withDuration: 1.0, delay: 1.0, options: [], animations: {
            cloudImg.alpha = 1
        }) { (_) in
            
        }
    }
    
}
