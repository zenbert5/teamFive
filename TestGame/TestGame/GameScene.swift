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
        if ((firstBody.categoryBitMask == PhysicsCategory.rock) &&
            (secondBody.categoryBitMask == PhysicsCategory.cage1)) {
            if let obj1 = firstBody.node as? SKSpriteNode,
                let obj2 = secondBody.node as? SKSpriteNode {
                cagesDestroyed += 1
                rockDidCollideWithObject(rock: obj1, object: obj2)
            }
        }

        if ((firstBody.categoryBitMask == PhysicsCategory.rock) &&
            (secondBody.categoryBitMask == PhysicsCategory.cage2)) {
            if let obj1 = firstBody.node as? SKSpriteNode,
                let obj2 = secondBody.node as? SKSpriteNode {
                cagesDestroyed += 1
                rockDidCollideWithObject(rock: obj1, object: obj2)
            }
        }

        if cagesDestroyed == 2 {
            if ((firstBody.categoryBitMask == PhysicsCategory.rock) &&
                (secondBody.categoryBitMask == PhysicsCategory.gold)) {
                if let obj1 = firstBody.node as? SKSpriteNode,
                    let obj2 = secondBody.node as? SKSpriteNode {
                    background!.addChild(gameWonLabel)
                    rockDidCollideWithObject(rock: obj1, object: obj2)
                }
            }
        }

    }
}

class GameScene: SKScene {
    weak var gameViewControllerDelegate:GameViewControllerDelegate?
    var gameStarted:Bool = false
    var hitGold:Bool = false
    var cagesDestroyed:Int = 0
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var spinnyNode : SKShapeNode?
    
    
    var animator:UIDynamicAnimator?
    let rock = SKSpriteNode(imageNamed: "rock")
    var pillar = SKSpriteNode(imageNamed: "pillar")
    let gold = SKSpriteNode(imageNamed: "gold")
    let cage1 = SKSpriteNode(imageNamed: "cage1")
    let cage2 = SKSpriteNode(imageNamed: "cage4")
    let lep = SKSpriteNode(imageNamed: "leprechaun")
    var background:SKSpriteNode?
    let gameWonLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-HeavyItalic")
    let gameLostLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-HeavyItalic")

    var ground:UIView?

    struct PhysicsCategory {
        static let none      : UInt32 = 0
        static let all       : UInt32 = UInt32.max
        static let rock   : UInt32 = 0b1       // 1
        static let pillar: UInt32 = 0b10      // 2
        static let gold: UInt32 = 0b11      // 3
        static let cage1: UInt32 = 0b100      // 4
        static let cage2: UInt32 = 0b101      // 5

    }
    
    deinit {print("gamescene deinitied")}
    
    func initRock(to view: SKView, addRock:Bool?) {
        physicsWorld.gravity = CGVector(dx:0, dy: 0)
        rock.position = CGPoint(x: -view.bounds.width/2+400, y: view.bounds.height/2+200)
        rock.physicsBody = SKPhysicsBody(rectangleOf: rock.size)
        rock.physicsBody?.isDynamic = true
        rock.physicsBody?.affectedByGravity = true
        rock.physicsBody?.categoryBitMask = PhysicsCategory.rock
        rock.physicsBody?.contactTestBitMask = PhysicsCategory.gold
        rock.physicsBody?.collisionBitMask = PhysicsCategory.none
        rock.physicsBody?.usesPreciseCollisionDetection = true

        if let add = addRock {
            if add {
                print("Drawing Rock")
                background!.addChild(rock)
            }
        }
    }
    
    func initBackground(to view: SKView) {
        let txt = SKTexture(imageNamed: "background")
        background = SKSpriteNode(texture: txt, size:size)
        background!.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background?.zPosition = 0.0
        self.addChild(background!)
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx:0, dy: 0)
        
        initBackground(to:view)
        
        rock.zPosition = 0.5
        rock.position = CGPoint(x: -view.bounds.width/2+200, y: view.bounds.height/2+200)
        rock.physicsBody = SKPhysicsBody(rectangleOf: rock.size)
        rock.physicsBody?.isDynamic = true
        rock.physicsBody?.affectedByGravity = true
        rock.physicsBody?.categoryBitMask = PhysicsCategory.rock
        rock.physicsBody?.contactTestBitMask =  PhysicsCategory.gold
        rock.physicsBody?.collisionBitMask = PhysicsCategory.none
        rock.physicsBody?.usesPreciseCollisionDetection = true

        background!.addChild(rock)

        lep.zPosition = 0.3
        lep.position = CGPoint(x: -view.bounds.width/2+480, y: view.bounds.height/2+200)
        
        background!.addChild(lep)

        gold.zPosition = 0.6
        gold.position = CGPoint(x: -view.bounds.width/2+50, y: view.bounds.height/2-920)
        gold.physicsBody = SKPhysicsBody(rectangleOf: gold.size)
        gold.physicsBody?.isDynamic = true
        gold.physicsBody?.affectedByGravity = false
        gold.physicsBody?.categoryBitMask = PhysicsCategory.gold
        gold.physicsBody?.contactTestBitMask = PhysicsCategory.rock
        gold.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        background!.addChild(gold)

        cage1.zPosition = 0.7
        cage1.position = CGPoint(x: -view.bounds.width/2+5, y: view.bounds.height/2-920)
        cage1.physicsBody = SKPhysicsBody(rectangleOf: cage1.size)
        cage1.physicsBody?.isDynamic = true
        cage1.physicsBody?.affectedByGravity = false
        cage1.physicsBody?.categoryBitMask = PhysicsCategory.cage1
        cage1.physicsBody?.contactTestBitMask = PhysicsCategory.rock
        cage1.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        background!.addChild(cage1)

        cage2.zPosition = 0.8
        cage2.position = CGPoint(x: -view.bounds.width/2+90, y: view.bounds.height/2-920)
        cage2.physicsBody = SKPhysicsBody(rectangleOf: cage2.size)
        cage2.physicsBody?.isDynamic = true
        cage2.physicsBody?.affectedByGravity = false
        cage2.physicsBody?.categoryBitMask = PhysicsCategory.cage2
        cage2.physicsBody?.contactTestBitMask = PhysicsCategory.rock
        cage2.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        background!.addChild(cage2)
        
        gameWonLabel.zPosition = 0.9
        gameWonLabel.text = "Congratulations! Leprechaun happy."
        gameWonLabel.fontSize = 30
        gameWonLabel.position = CGPoint(x:0,y:0)
        gameWonLabel.fontColor = UIColor.black

        gameLostLabel.zPosition = 0.9
        gameLostLabel.text = "You Lose. Leprechaun angry."
        gameLostLabel.fontSize = 30
        gameLostLabel.position = CGPoint(x:0,y:0)
        gameLostLabel.fontColor = UIColor.black

        physicsWorld.contactDelegate = self
    }
    
    func rockDidCollideWithObject(rock: SKSpriteNode, object: SKSpriteNode) {
        rock.removeFromParent()
        object.removeFromParent()
        gameViewControllerDelegate?.callMethod(control:"Stop", addRock:nil)
        hitGold = true

    }
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
                
        // Create shape node to use during mouse interaction
        
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
        guard let touch = touches.first else {
            return
        }
        
        gameViewControllerDelegate?.removeRock()
        gameViewControllerDelegate?.callMethod(control:"Start", addRock:hitGold)
        hitGold = false
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
        
        if gameStarted {
            //physicsWorld.gravity = CGVector(dx:0, dy: -0.3)
        }
        self.lastUpdateTime = currentTime
    }
}
