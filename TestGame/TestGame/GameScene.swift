//
//  GameScene.swift
//  TestGame
//
//  Created by Jay Peters on 11/1/18.
//  Copyright © 2018 Jay Peters. All rights reserved.
//

import SpriteKit
import GameplayKit

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.rock != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.pillar != 0)) {
            if let pillar = firstBody.node as? SKSpriteNode,
                let rock = secondBody.node as? SKSpriteNode {
                rockDidCollideWithPillar(rock: rock, pillar: pillar)
            }
        }
    }
}

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var spinnyNode : SKShapeNode?
    
    
    var animator:UIDynamicAnimator?
    let rock = SKSpriteNode(imageNamed: "rock")
    var pillar = SKSpriteNode(imageNamed: "pillar")
    var ground:UIView?

    struct PhysicsCategory {
        static let none      : UInt32 = 0
        static let all       : UInt32 = UInt32.max
        static let rock   : UInt32 = 0b1       // 1
        static let pillar: UInt32 = 0b10      // 2
//        static let ground: UInt32 = 0b100      // 3
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx:0, dy: -0.3)

        rock.position = CGPoint(x: -view.bounds.width/2+50, y: view.bounds.height/2+50)
        rock.physicsBody = SKPhysicsBody(rectangleOf: rock.size)
        rock.physicsBody?.isDynamic = true
        rock.physicsBody?.affectedByGravity = true
        rock.physicsBody?.categoryBitMask = PhysicsCategory.rock
        rock.physicsBody?.contactTestBitMask = PhysicsCategory.pillar
        rock.physicsBody?.collisionBitMask = PhysicsCategory.none
        rock.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(rock)
        
        pillar.position = CGPoint(x: -view.bounds.width/2+50, y: -view.bounds.height/2)
        pillar.physicsBody = SKPhysicsBody(rectangleOf: pillar.size)
        pillar.physicsBody?.isDynamic = true
        pillar.physicsBody?.affectedByGravity = false
        pillar.physicsBody?.categoryBitMask = PhysicsCategory.pillar
        pillar.physicsBody?.contactTestBitMask = PhysicsCategory.rock
        pillar.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        addChild(pillar)
        
        physicsWorld.contactDelegate = self
        
//        let groundFrame = CGRect(x: 0, y: view.bounds.height-50, width: view.bounds.width, height: 50)
//        ground = UIView(frame:groundFrame)
//        ground?.backgroundColor = UIColor.brown
//        view.addSubview(ground!)

    }
    
    func rockDidCollideWithPillar(rock: SKSpriteNode, pillar: SKSpriteNode) {
        print("Hit")
        rock.removeFromParent()
        pillar.removeFromParent()
    }
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
                
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        // 1 - Choose one of the touches to work with
//        guard let touch = touches.first else {
//            return
//        }
//        let touchLocation = touch.location(in: self)
//        
//        // 2 - Set up initial location of projectile
//        let projectile = SKSpriteNode(imageNamed: "projectile")
//        projectile.position = player.position
//        
//        // 3 - Determine offset of location to projectile
//        let offset = touchLocation - projectile.position
//        
//        // 4 - Bail out if you are shooting down or backwards
//        if offset.x < 0 { return }
//        
//        // 5 - OK to add now - you've double checked position
//        addChild(projectile)
//        
//        // 6 - Get the direction of where to shoot
//        let direction = offset.normalized()
//        
//        // 7 - Make it shoot far enough to be guaranteed off screen
//        let shootAmount = direction * 1000
//        
//        // 8 - Add the shoot amount to the current position
//        let realDest = shootAmount + projectile.position
//        
//        // 9 - Create the actions
//        let actionMove = SKAction.move(to: realDest, duration: 2.0)
//        let actionMoveDone = SKAction.removeFromParent()
//        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
//    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
