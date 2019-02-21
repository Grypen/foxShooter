//
//  GameScene.swift
//  foxShoot
//
//  Created by Edvard Hedlund on 2019-02-20.
//  Copyright © 2019 Edvard Hedlund. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    

    var player: SKSpriteNode?
    var ground: SKSpriteNode?
    var left: SKSpriteNode?
    var right: SKSpriteNode?
    var shoot: SKSpriteNode?
    var leftWall: SKSpriteNode?
    var rightWall: SKSpriteNode?
    var cloud: SKSpriteNode?
    var background = SKSpriteNode(imageNamed: "background")
    
    private var foxWalkingFrames: [SKTexture] = []
    private var baloonHitFrames: [SKTexture] = []

    var baloonTimer: Timer?
    var cloudTimer: Timer?
    
    var score = 0
    var scoreLabel: SKLabelNode?
    var yourScoreLabel: SKLabelNode?
    var pointsLabel: SKLabelNode?
    var floatingPointsLabel: SKLabelNode?
    
    let playerCategory: UInt32 = 0x1 << 1
    let baloonCategory: UInt32 = 0x1 << 2
    let boundsCategory: UInt32 = 0x1 << 4
    let arrowCategory: UInt32 = 0x1 << 5
    let cloudCategory: UInt32 = 0x1 << 6
    
    var baloonTimeInterval: Double = 1.2
    
    override func didMove(to view: SKView) {
        
        self.view?.isMultipleTouchEnabled = true
        physicsWorld.contactDelegate = self
        
        background.position = CGPoint(x: 0, y: 0)
        background.size = (scene?.size)!
        addChild(background)
        background.zPosition = -1
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        scoreLabel?.text = "SCORE        0"
        scoreLabel?.zPosition = 10
        
        right = childNode(withName: "buttonRight") as? SKSpriteNode
        right?.zPosition = 5
        left = childNode(withName: "buttonLeft") as? SKSpriteNode
        left?.zPosition = 5
        shoot = childNode(withName: "shoot") as? SKSpriteNode
        shoot?.zPosition = 5
        buildFox()
        getBaloonHitFrames()
        
        startTimers(baloonTimeInterval: baloonTimeInterval)
        cloudTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {
            timer in
            self.createCloud()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touches = self.atPoint(location)
            
            if (touches.name == "buttonRight") {
                player?.removeAction(forKey: "buttonLeft")
                movePlayer(moveBy: 1000, forTheKey: "buttonRight")
            }
            if (touches.name == "buttonLeft") {
                player?.removeAction(forKey: "buttonRight")
                movePlayer(moveBy: -1000, forTheKey: "buttonLeft")
            }
            if (touches.name == "shoot") {
                createArrow()
            }
            if (touches.name == "shoot" && touches.name == "buttonRight") {
                player?.removeAction(forKey: "buttonLeft")
                movePlayer(moveBy: 1000, forTheKey: "buttonRight")
                createArrow()
            }
            if (touches.name == "shoot" && touches.name == "buttonLeft") {
                player?.removeAction(forKey: "buttonRight")
                movePlayer(moveBy: -1000, forTheKey: "buttonLeft")
                createArrow()
            }
            if touches.name == "replay" {
                for child in self.children {
                    if child.name == "myBaloon"  {
                        child.removeFromParent()
                    }
                }
                score = 0
                baloonTimeInterval = 1
                scoreLabel?.text = "SCORE        " + "\(score)"
                yourScoreLabel?.removeFromParent()
                pointsLabel?.removeFromParent()
                scene?.isPaused = false
                startTimers(baloonTimeInterval: baloonTimeInterval)
                cloudTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {
                    timer in
                    self.createCloud()
                })
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touches = self.atPoint(location)
            
            
            if (touches.name == "buttonRight") {
                player?.removeAction(forKey: "buttonRight")
                player?.removeAction(forKey: "walkingFox")
            } else if (touches.name == "buttonLeft") {
                player?.removeAction(forKey: "buttonLeft")
                player?.removeAction(forKey: "walkingFox")
            } else if (touches.name == "shoot"){
                
            }
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == baloonCategory, contact.bodyB.categoryBitMask == arrowCategory {
            score += 20
            baloonHit(sprite: contact.bodyA.node!, points: 20)
            contact.bodyB.node?.removeFromParent()
            
        }
        if contact.bodyB.categoryBitMask == baloonCategory, contact.bodyA.categoryBitMask == arrowCategory {
            score += 20
            baloonHit(sprite: contact.bodyB.node!, points: 20)
            contact.bodyA.node?.removeFromParent()
        }
        
        if contact.bodyA.categoryBitMask == playerCategory, contact.bodyB.categoryBitMask == baloonCategory {
        }
        if contact.bodyA.categoryBitMask == baloonCategory, contact.bodyB.categoryBitMask == playerCategory {
        }
        scoreLabel?.text = "SCORE        " + "\(score)"
    }
    
    func createBaloon() {
        let baloons = ["balloon1", "balloon2", "balloon3", "balloon4", "balloon5"]
        let selector = rng(max: 5, min: 0)
        let baloon = SKSpriteNode(imageNamed: baloons[Int(selector - 1)])
        baloon.name = "myBaloon"
        baloon.zPosition = 4
        baloon.physicsBody = SKPhysicsBody(rectangleOf: baloon.size)
        baloon.physicsBody?.affectedByGravity = false
        baloon.physicsBody?.categoryBitMask = baloonCategory
        baloon.physicsBody?.contactTestBitMask = arrowCategory
        baloon.physicsBody?.collisionBitMask = 0
        addChild(baloon)
        
        spawnBaloon(sprite: baloon)
    }
    
    func getBaloonHitFrames() {
        let baloonAnimatedAtlas = SKTextureAtlas(named: "baloon")
        var exFrames: [SKTexture] = []
        let explosionTextureName = "balloon_explode"
        exFrames.append(baloonAnimatedAtlas.textureNamed(explosionTextureName))
        
        baloonHitFrames = exFrames
    }
    
    func baloonHit(sprite: SKNode, points: Int) {
        sprite.removeAllActions()
        sprite.physicsBody = nil
        let popSound = SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false)
        let explode = SKAction.animate(with: baloonHitFrames,
                                       timePerFrame: 0.1,
                                       resize: false,
                                       restore: true)
        let seq = SKAction.sequence([popSound, explode, SKAction.removeFromParent()])
        
        sprite.run(seq, withKey: "baloonHit")
        
        showPoints(sprite: sprite, points: points)
        
    }
    
    func createArrow() {
        let arrow = SKSpriteNode(imageNamed: "myArrow")
        arrow.zPosition = 4
        arrow.physicsBody = SKPhysicsBody(rectangleOf: arrow.size)
        arrow.physicsBody?.affectedByGravity = false
        arrow.physicsBody?.categoryBitMask = arrowCategory
        arrow.physicsBody?.contactTestBitMask = baloonCategory
        arrow.physicsBody?.collisionBitMask = 0
        addChild(arrow)
        spawnArrow(sprite: arrow)
    }
    
    func createCloud() {
        let selector = rng(max: 2, min: 0)
        if selector == 1 {
            cloud = SKSpriteNode(imageNamed: "cloudA")
        }
        if selector == 2 {
            cloud = SKSpriteNode(imageNamed: "cloudB")
        }
        cloud?.zPosition = 1
        cloud?.physicsBody = SKPhysicsBody(rectangleOf: (cloud?.size)!)
        cloud?.physicsBody?.affectedByGravity = false
        cloud?.physicsBody?.categoryBitMask = cloudCategory
        cloud?.physicsBody?.contactTestBitMask = cloudCategory
        cloud?.physicsBody?.collisionBitMask = 0
        addChild(cloud!)
        spawnCloud(sprite: cloud!)
    }
    
    func spawnBaloon(sprite: SKSpriteNode) {
        
        let maxX = size.width / 2 - sprite.size.width / 2
        let minX = -size.width / 2 + sprite.size.width
        
        let range = maxX - minX
        let posX = maxX - CGFloat(arc4random_uniform(UInt32(range)))
        sprite.position = CGPoint(x: posX, y: size.height / 2 + sprite.size.height)
        
        let moveLeft = SKAction.moveBy(x: -size.width/20 , y: -size.height/2.5, duration: 4)
        let moveRight = SKAction.moveBy(x: size.width/20 , y: -size.height/2.5, duration: 4)
        let selector = arc4random_uniform(4)
        let number = 4 - selector
        if number == 1 {
            sprite.run(SKAction.sequence([moveLeft, moveRight, SKAction.removeFromParent()]))
        }
        if number == 2 {
            sprite.run(SKAction.sequence([moveRight, moveLeft, SKAction.removeFromParent()]))
        }
        if number == 3 {
            sprite.run(SKAction.sequence([moveRight, moveRight, SKAction.removeFromParent()]))
        }
        if number == 4 {
            sprite.run(SKAction.sequence([moveLeft, moveLeft, SKAction.removeFromParent()]))
        }
        
    }
    
    func spawnArrow(sprite: SKSpriteNode) {
        
        sprite.position = CGPoint(x: (player?.position.x)!, y: (player?.position.y)! - (player?.position.y)! / 2)
        
        let fire = SKAction.moveBy(x: 0, y: size.height, duration: 0.5)
        sprite.run(SKAction.sequence([fire, SKAction.removeFromParent()]))
        
    }
    
    func spawnCloud(sprite: SKSpriteNode) {
        
        let maxY = size.height / 2 - sprite.size.height / 2
        let minY = -size.height / 2 + 6 * sprite.size.height
        
        let range = maxY - minY
        let posY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        sprite.position = CGPoint(x: size.width / 2 + sprite.size.width, y: posY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - 2 * sprite.size.width, y: 0, duration: 15)
        sprite.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
        
    }
    
    func startTimers(baloonTimeInterval: Double) {
        baloonTimer = Timer.scheduledTimer(withTimeInterval: baloonTimeInterval, repeats: true, block: {
            timer in
            self.createBaloon()
        })
    }
    
    func movePlayer(moveBy: CGFloat, forTheKey: String) {
        let moveAction = SKAction.moveBy(x: moveBy, y: 0, duration: 1)
        let repeatForEver = SKAction.repeatForever(moveAction)
        let seq = SKAction.sequence([moveAction, repeatForEver])
        player?.run(seq, withKey: forTheKey)
        animateFox()
        
        if forTheKey == "buttonRight" {
            player?.xScale = abs((player?.xScale)!) * -1.0
        }
        if forTheKey == "buttonLeft" {
            player?.xScale = abs((player?.xScale)!) * 1.0
        }
        
    }
    func buildFox() {
        let foxAnimatedAtlas = SKTextureAtlas(named: "fox")
        var walkFrames: [SKTexture] = []
        
        let numImages = foxAnimatedAtlas.textureNames.count
        for i in 0...numImages - 1 {
            let foxTextureName = "fox\(i)"
            walkFrames.append(foxAnimatedAtlas.textureNamed(foxTextureName))
        }
        foxWalkingFrames = walkFrames
        let firstFrameTexture = foxWalkingFrames[0]
        player = childNode(withName: "player") as? SKSpriteNode
        player?.texture = firstFrameTexture
        player?.size = firstFrameTexture.size()
        
        player?.zPosition = 4
        player?.physicsBody?.usesPreciseCollisionDetection = true
        player?.physicsBody?.categoryBitMask = playerCategory
        player?.physicsBody?.collisionBitMask = boundsCategory
        ground = childNode(withName: "ground") as? SKSpriteNode
        ground?.physicsBody?.categoryBitMask = boundsCategory
        ground?.physicsBody?.collisionBitMask = playerCategory
        leftWall = childNode(withName: "leftWall") as? SKSpriteNode
        leftWall?.physicsBody?.categoryBitMask = boundsCategory
        leftWall?.physicsBody?.collisionBitMask = playerCategory
        rightWall = childNode(withName: "rightWall") as? SKSpriteNode
        rightWall?.physicsBody?.categoryBitMask = boundsCategory
        rightWall?.physicsBody?.collisionBitMask = playerCategory
    }
    
    
    func animateFox() {

        player?.run(SKAction.repeatForever(
            SKAction.animate(with: foxWalkingFrames,
                             timePerFrame: 0.1,
                             resize: false,
                             restore: true)),
                    withKey:"walkingFox")
        if player?.texture == nil {
            let atlas = SKTextureAtlas(named: "fox")
            let texture = atlas.textureNamed("fox0")
            player?.texture = texture
        }
    }
    
    func rng (max: Int, min: Int) -> Double {
        let max = max
        let min = min
        let range = max - min
        let number = Double(max) - Double(arc4random_uniform(UInt32(range)))
        return number
        
    }
    
    func showPoints (sprite: SKNode, points: Int) {
        if points > 0 {
            floatingPointsLabel = SKLabelNode(text: "+\(points)")
        } else {
            floatingPointsLabel = SKLabelNode(text: "\(points)")
        }
        floatingPointsLabel?.position = sprite.position
        floatingPointsLabel?.zPosition = 11
        floatingPointsLabel?.fontName = "Arial"
        floatingPointsLabel?.fontSize = 30
        addChild(floatingPointsLabel!)
        let goUp = SKAction.moveBy(x: 0, y: 30, duration: 1)
        floatingPointsLabel?.run(SKAction.sequence([goUp, SKAction.removeFromParent()]))
        
    }
    
}
