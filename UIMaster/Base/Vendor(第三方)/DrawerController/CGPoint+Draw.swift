//
//  CGPointExtension.swift
//  Pods
//
//  Created by Millman YANG on 2017/4/1.
//
//

import UIKit

extension CGPoint {
    func distance(point: CGPoint?) -> CGFloat {
        if let pointTemp = point {
            let xDist = self.x - pointTemp.x
            let yDist = self.y - pointTemp.y
            return CGFloat(sqrt( xDist * xDist) + (yDist * yDist) )
        }
        return .greatestFiniteMagnitude
    }
}
