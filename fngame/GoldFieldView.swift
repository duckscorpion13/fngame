//
//  GoldView.swift
//  Asteroids
//
//  Created by DerekYang on 2018/1/3.
//  Copyright © 2018年 Stanford University. All rights reserved.
//

import UIKit

class GoldFieldView: UIView
{

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    // apply this behavior to all asteroids
    var goldBehavior: GoldBehavior? {
        didSet {
            for asteroid in golds {
                oldValue?.removeGold(asteroid)
                goldBehavior?.addGold(asteroid)
            }
        }
    }
    
    // get all of our asteroids
    // by converting our subviews array
    // into an array of all subviews that are AsteroidView
    private var golds: [GoldView] {
        return subviews.flatMap { $0 as? GoldView }
    }
    
    var scale: CGFloat = 0.002  // size of average asteroid (compared to bounds.size)
//    var minAsteroidSize: CGFloat = 0.25 // compared to average
//    var maxAsteroidSize: CGFloat = 2.00 // compared to average
    
    func addGolds(count: Int, exclusionZone: CGRect = CGRect.zero) {
        assert(!bounds.isEmpty, "can't add asteroids to an empty field")
        let averageAsteroidSize = bounds.size * scale
        for _ in 0..<count {
            let asteroid = GoldView()
            asteroid.frame.size = (asteroid.frame.size / (asteroid.frame.size.area / averageAsteroidSize.area))// * CGFloat.random(in: minAsteroidSize..<maxAsteroidSize)
            repeat {
                asteroid.frame.origin = bounds.randomPoint
            } while !exclusionZone.isEmpty && asteroid.frame.intersects(exclusionZone)
            addSubview(asteroid)
            goldBehavior?.addGold(asteroid)
        }
    }

}
