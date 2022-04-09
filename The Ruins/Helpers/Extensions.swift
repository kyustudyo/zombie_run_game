//
//  Extensions.swift
//  The Ruins
//
//  Created by Valsamis Elmaliotis on 30/11/2017.
//  Copyright © 2017 Valsamis Elmaliotis. All rights reserved.
//

import Foundation
import SceneKit

extension float2 {
    
    init(_ v: CGPoint) {
        
        self.init(Float(v.x), Float(v.y))
    }
}

extension SCNPhysicsContact {
    
    func match(_ category:Int, block:(_ matching:SCNNode, _ other:SCNNode) -> Void) {
        
        if self.nodeA.physicsBody!.categoryBitMask == category {
            
            block(self.nodeA, self.nodeB)
        }
        
        if self.nodeB.physicsBody!.categoryBitMask == category {
            
            block(self.nodeB, self.nodeA)
        }
    }
}
