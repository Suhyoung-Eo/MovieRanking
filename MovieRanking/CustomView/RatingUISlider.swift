//
//  RatingUISlider.swift
//  MovingRanking
//
//  Created by Suhyoung Eo on 2022/02/07.
//

import UIKit

class RatingUISlider: UISlider {

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let width = self.frame.size.width
        let tapPoint = touch.location(in: self)
        let fPercent = tapPoint.x/width
        let nNewValue = self.maximumValue * Float(fPercent)
        if nNewValue != self.value {
            self.value = nNewValue
        }
        return true
    }
}
