//
//  ViewController.swift
//  fngame
//
//  Created by DerekYang on 2018/1/3.
//  Copyright © 2018年 LBD. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    //    let cmmgr = CMMotionManager()
    
    @IBOutlet var lblGoal: UILabel!
    private var asteroidField: AsteroidFieldView!
    private var goldField: GoldFieldView!
    
    private var ship: SpaceshipView!
    
    private lazy var animatorAsteroid: UIDynamicAnimator = UIDynamicAnimator(referenceView: self.asteroidField)
    private lazy var animatorGoid: UIDynamicAnimator = UIDynamicAnimator(referenceView: self.goldField)
    
    private var asteroidBehavior = AsteroidBehavior()
    
    private var goldBehavior = GoldBehavior()
    
    var goal = 0 {
        didSet {
            DispatchQueue.main.async {
                [weak self] in
                if let strongSelf = self {
                    strongSelf.lblGoal.text = "\(strongSelf.goal)"
                }
            }
        }
    }
    
    // MARK: View Controller Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initializeIfNeeded()
        animatorAsteroid.addBehavior(asteroidBehavior)
        asteroidBehavior.pushAllAsteroids()
        
        animatorGoid.addBehavior(goldBehavior)
        goldBehavior.pushAllGolds()
        
        //        cmmgr.startDeviceMotionUpdates(to: OperationQueue(),
        //                                        withHandler: { (motion, _) in
        //                                            if let _motion = motion {
        //                                                let attitude = _motion.attitude
        //                                                print("\(attitude.yaw)")
        ////                                                    print("\(tmp.x),\(tmp.y),\(tmp.z)")
        //                                            }
        //        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animatorAsteroid.removeBehavior(asteroidBehavior)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        asteroidField?.center = view.bounds.mid
        repositionShip()
    }
    
    private func initializeIfNeeded() {
        if asteroidField == nil {
            asteroidField = AsteroidFieldView(frame: CGRect(center: view.bounds.mid, size: view.bounds.size * Constants.asteroidFieldMagnitude))
            view.addSubview(asteroidField)
            let shipSize = view.bounds.size.minEdge * Constants.shipSizeToMinBoundsEdgeRatio
            ship = SpaceshipView(frame: CGRect(squareCenteredAt: asteroidField.center, size: shipSize))
            ship.delegate = self
            view.addSubview(ship)
            
            asteroidField.addAsteroids(count: Constants.initialAsteroidCount, exclusionZone: ship.convert(ship.bounds, to: asteroidField))
            asteroidField.asteroidBehavior = asteroidBehavior
        }
        
        if goldField == nil {
            goldField = GoldFieldView(frame: CGRect(center: view.bounds.mid, size: view.bounds.size))// * Constants.asteroidFieldMagnitude))
            view.addSubview(goldField)
            goldField.addGolds(count: Constants.initialGoldCount, exclusionZone: ship.convert(ship.bounds, to: goldField))
            goldField.goldBehavior = goldBehavior
            
            
        }
        
        repositionShip()
    }
    
    private func repositionShip() {
        if asteroidField != nil {
            ship.center = asteroidField.center
            asteroidBehavior.setBoundary(ship.shieldBoundary(in: asteroidField), named: Constants.shipBoundaryName) {
                [weak self] in
                if let ship = self?.ship {
                    if !ship.shieldIsActive {
                        ship.shieldIsActive = true
                        ship.shieldLevel -= Constants.Shield.activationCost
                        if let strongSelf = self {
                            Timer.scheduledTimer(timeInterval: Constants.Shield.duration,
                                                 target: strongSelf,
                                                 selector: #selector(self?.updateTime),
                                                 userInfo: nil,
                                                 repeats: true)
                        }
                        //                        (withTimeInterval: Constants.Shield.duration, repeats: false) { timer in
                        //                            ship.shieldIsActive = false
                        //                            if ship.shieldLevel == 0 {
                        //                                ship.shieldLevel = 100
                        //                            }
                        //                        }
                    }
                }
            }
        }
        if goldField != nil {
            ship.center = goldField.center
            goldBehavior.setBoundary(ship.shieldBoundary(in: goldField), named: Constants.shipBoundaryName) {
                [weak self] in
                if let ship = self?.ship {
                    if !ship.shieldIsActive {
                        ship.shieldIsActive = true
                        ship.shieldLevel += 1
                        
                        if let strongSelf = self {
                            strongSelf.goal += 1
                            Timer.scheduledTimer(timeInterval: Constants.Shield.duration,
                                                 target: strongSelf,
                                                 selector: #selector(self?.updateTime),
                                                 userInfo: nil,
                                                 repeats: true)
                        }
                        //                        (withTimeInterval: Constants.Shield.duration, repeats: false) { timer in
                        //                            ship.shieldIsActive = false
                        //                            if ship.shieldLevel == 0 {
                        //                                ship.shieldLevel = 100
                        //                            }
                        //                        }
                    }
                }
            }
        }
    }
    @objc private func updateTime()
    {
        ship.shieldIsActive = false
        if ship.shieldLevel == 0 {
            ship.shieldLevel = 100
        }
    }
    // MARK: Firing Engines
    
    @IBAction func burn(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began,.changed:
            ship.direction = (sender.location(in: view) - ship.center).angle
            burn()
        case .ended:
            endBurn()
        default: break
        }
    }
    
    private func burn() {
        ship.enginesAreFiring = true
        asteroidBehavior.acceleration.angle = ship.direction - CGFloat.pi
        asteroidBehavior.acceleration.magnitude = Constants.burnAcceleration
    }
    
    private func endBurn() {
        ship.enginesAreFiring = false
        asteroidBehavior.acceleration.magnitude = 0
    }
    
    // MARK: Constants
    
    private struct Constants {
        static let initialAsteroidCount = 60
        static let initialGoldCount = 20
        static let shipBoundaryName = "Ship"
        static let shipSizeToMinBoundsEdgeRatio: CGFloat = 1/5
        static let asteroidFieldMagnitude: CGFloat = 10             // as a multiple of view.bounds.size
        static let normalizedDistanceOfShipFromEdge: CGFloat = 0.2
        static let burnAcceleration: CGFloat = 0.307                 // points/s/s
        struct Shield {
            static let duration: TimeInterval = 1.0       // how long shield stays up
            static let updateInterval: TimeInterval = 0.2 // how often we update shield level
            static let regenerationRate: Double = 5       // per second
            static let activationCost: Double = 25        // per activation
            static var regenerationPerUpdate: Double
            { return Constants.Shield.regenerationRate * Constants.Shield.updateInterval }
            static var activationCostPerUpdate: Double
            { return Constants.Shield.activationCost / (Constants.Shield.duration/Constants.Shield.updateInterval) }
        }
        static let defaultShipDirection: [UIInterfaceOrientation:CGFloat] = [
            .portrait : CGFloat.up,
            .portraitUpsideDown : CGFloat.down,
            .landscapeLeft : CGFloat.right,
            .landscapeRight : CGFloat.left
        ]
        static let normalizedAsteroidFieldCenter: [UIInterfaceOrientation:CGPoint] = [
            .portrait : CGPoint(x: 0.5, y: 1.0-Constants.normalizedDistanceOfShipFromEdge),
            .portraitUpsideDown : CGPoint(x: 0.5, y: Constants.normalizedDistanceOfShipFromEdge),
            .landscapeLeft : CGPoint(x: Constants.normalizedDistanceOfShipFromEdge, y: 0.5),
            .landscapeRight : CGPoint(x: 1.0-Constants.normalizedDistanceOfShipFromEdge, y: 0.5),
            .unknown : CGPoint(x: 0.5, y: 0.5)
        ]
    }
}

extension ViewController: SpaceshipViewDelegate
{
    func handleGameOver()
    {
        self.performSegue(withIdentifier: "Unwind2StartVC", sender: self)
    }
}

//extension AsteroidsViewController: CLLocationManagerDelegate
//{
//    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        if newHeading.headingAccuracy < 0 {
//            print("請進行校正並遠離磁性干擾源")
//        } else {
//            print("目前面向 \(newHeading.magneticHeading)")
//            ship.direction = CGFloat(newHeading.magneticHeading/360)*CGFloat.pi
//            burn()
//        }
//    }
//}

