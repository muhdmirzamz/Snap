//
//  Line.swift
//  Snap
//
//  Created by Muhd Mirza on 19/1/17.
//  Copyright © 2017 muhdmirzamz. All rights reserved.
//

import Foundation
import CoreGraphics

public class Line {
	var startPoint: CGPoint
	var endPoint: CGPoint
	
	init(startPoint: CGPoint, endPoint: CGPoint) {
		self.startPoint = startPoint
		self.endPoint = endPoint
	}
}
