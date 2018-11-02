//
//  GameViewController.swift
//  TestGame
//
//  Created by Jay Peters on 11/1/18.
//  Copyright © 2018 Jay Peters. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreGraphics
import CoreMotion

class GameViewController: UIViewController {
    
    var gameStarted = false
    var lastAttitude:CMAttitude?
    var motionManager: CMMotionManager?
    
    func degreesFromRadians(_ radiant: Double) -> Double? {
        return radiant * 180/Double.pi
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var rollRate: Double?
        var rocks: Int = 3
        
        motionManager = CMMotionManager()
//        let boundaries = UICollisionBehavior(items: [rock!, ground!])
//        boundaries.translatesReferenceBoundsIntoBoundary = true
        
//        animator?.addBehavior(boundaries)

        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if var sceneNode = scene.rootNode as! GameScene? {
                
                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    view.ignoresSiblingOrder = true
                }
                
                if let manager = motionManager {
                    if manager.isDeviceMotionAvailable {
                        let motionQ = OperationQueue()
                        //let motionQ = DispatchQueue(label: "rockQueue", attributes: .concurrent)
                        manager.deviceMotionUpdateInterval = 0.05
                        manager.startDeviceMotionUpdates(to: motionQ, withHandler: {
                            (data: CMDeviceMotion?, error: Error?) in
                            if let myData = data {
                                if !sceneNode.gameStarted {
                                    if let last = self.lastAttitude {
                                        if self.degreesFromRadians(last.pitch)! - self.degreesFromRadians(myData.attitude.pitch)! >= 30 {
                                            sceneNode.gameStarted = true
                                            self.gameStarted = true
                                            print(self.degreesFromRadians(last.pitch) ?? 0.0, self.degreesFromRadians(myData.attitude.pitch) as Any)
                                        }
                                    }
                                }
                                _ = myData.attitude
                                if !self.gameStarted {
                                    print("attitude", data?.attitude as Any)
//                                    print("pitch", self.degreesFromRadians(attitude.pitch) ?? 0.0)
                                } else {
                                    // check if node is in scene
                                    if (!sceneNode.intersects(sceneNode.rock)) {
                                        print("Elvis has left the building")
                                        if rocks == 0 {
                                            // gameover
                                        } else {
                                            // reinit game
                                            rocks -= 1

                                            // need to show rock again
                                            if let view = self.view as! SKView? {
                                                DispatchQueue.main.async(){
                                                    sceneNode.initRock(to:view)
                                                }
                                            }
                                           // self.gameStarted = false
                                           // sceneNode.gameStarted = false
                                        }
                                    }
                                    if let last = self.lastAttitude {
                                          print("roll -->", self.degreesFromRadians(last.roll)!)
                                          print("previous -->", self.degreesFromRadians(myData.attitude.roll)!)
                                        
//                                        if last.roll > 0 {
//                                            rollRate = last.roll/1.5
//                                        } else {
//                                            rollRate = last.roll/2
//                                        }
//                                        if let roll = rollRate {
//                                            print("roll rate -->", roll)
                                            sceneNode.physicsWorld.gravity = CGVector(dx: last.roll, dy: -0.4)
//                                        }
                                    }
                                   
                                }
                                self.lastAttitude = myData.attitude
                            }
                        })
                    }
                    else {
                        // alert user the capability is missing
                        print("no device motion capability")
                    }
                }

            }
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
