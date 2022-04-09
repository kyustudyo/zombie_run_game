//
//  GameUtils.swift
//  The Ruins
//
//  Created by Valsamis Elmaliotis on 03/12/2017.
//  Copyright © 2017 Valsamis Elmaliotis. All rights reserved.
//

import Foundation
import SceneKit

struct GameUtils {
    
    //gives the lenght of the biggest line of a triangle based on Pythagorium
    static func distanceBetweenVectors(vector1:SCNVector3, vector2:SCNVector3) -> Float {
        
        let vector = SCNVector3Make(vector1.x-vector2.x, vector1.y-vector2.y, vector1.z-vector2.z)
        
        return sqrt(pow(vector.x,2.0) + pow(vector.y,2.0) + pow(vector.z,2.0))
    }
    
    //gives the X-Y needed to be added every step to reach one node another
    static func getCoordinatesNeededToMoveToReachNode(form vector1:SCNVector3, to vector2: SCNVector3) -> (vX:Float, vZ:Float, angle:Float) {
        
        let dx = vector2.x - vector1.x
        let dz = vector2.z - vector1.z
        let angle = atan2(dz, dx)
        
        let vx = cos(angle)
        let vz = sin(angle)
        
        return (vx, vz, angle)
    }
    
    //fix 90 degrees difference
    static func getFixedRotationAngle(with angle:Float) -> Float {
        
        return (Float.pi/2) - angle
    }
}
