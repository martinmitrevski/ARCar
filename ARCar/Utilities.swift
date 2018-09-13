//
//  Utilities.swift
//  ARCar
//
//  Created by Martin Mitrevski on 12.09.18.
//  Copyright © 2018 Mitrevski. All rights reserved.
//

import Foundation
import SceneKit

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    
}
extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
