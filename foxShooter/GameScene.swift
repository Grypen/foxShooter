//
//  GameScene.swift
//  foxShooter
//
//  Created by Edvard Hedlund on 2019-01-16.
//  Copyright © 2019 Edvard Hedlund. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var fox = SKSpriteNode()
    var foxRun: SKAction?
    
    override func didMove(to view: SKView) {
        
        if let node = self.childNode(withName: "fox") as? SKSpriteNode{
            fox = node
        }
        
        foxRun = SKAction(named: "foxRun")
        fox.removeAllActions()
        
    }
    
    func runFox(_ touches: Set<UITouch>){
        if let touch = touches.first{
            let nodeLocation = fox.position
            let touchPoint = touch.location(in: view)
            let touchLocation = convertPoint(fromView: touchPoint)
            
            if let foxAction = foxRun{
                fox.run(foxAction)
            }
            
            let a = touchLocation.x - nodeLocation.x
            
            if a > 0 {
                fox.xScale = -0.5
            } else {
                fox.xScale = 0.5
            }
            /*
             let moveAction = SKAction.moveBy(x: a, y: 0, duration: 2)
             fox.run(moveAction)
             
             fox.run(moveAction, completion: {()-> Void in
             self.fox.removeAllActions()
             self.fox.texture = SKTexture(imageNamed: "fox.png")
             })
             */
            
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       runFox(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
       
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
       
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
