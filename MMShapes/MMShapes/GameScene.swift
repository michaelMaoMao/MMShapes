//
//  GameScene.swift
//  MMShapes
//
//  Created by MichaelMao on 17/1/14.
//  Copyright © 2017年 MichaelMao. All rights reserved.
//

import SpriteKit

var obstacles: [SKNode] = []
var rightobstacles: [SKNode] = []
let obstacleSpacing: CGFloat = 800
let cameraNode = SKCameraNode()

let scoreLabel = SKLabelNode()
var score = 0

class GameScene: SKScene {
    
    struct PhysicsCategory {
        static let Player: UInt32 = 1
        static let Obstatcle: UInt32 = 2
        static let Edge: UInt32 = 4
    }
    
    let colors = [SKColor.yellowColor(), SKColor.blueColor(), SKColor.redColor(), SKColor.purpleColor()]
    let player = SKShapeNode(circleOfRadius:40)
    
    override func didMoveToView(view: SKView) {
        setupPlayerAndObstacles()
        
        let playerBody = SKPhysicsBody(circleOfRadius: 30)
        playerBody.mass = 1.5
        playerBody.categoryBitMask = PhysicsCategory.Player
        playerBody.collisionBitMask = 4
        player.physicsBody = playerBody
        
        let ledge = SKNode()
        ledge.position = CGPointMake(size.width/2, 160)
        let ledgeBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(200, 10))
        ledgeBody.dynamic = false;
        ledgeBody.categoryBitMask = PhysicsCategory.Edge;
        ledge.physicsBody = ledgeBody;
        addChild(ledge)
        
        physicsWorld.gravity.dy = -22
        physicsWorld.contactDelegate = self
        
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        
        scoreLabel.position = CGPoint(x: -300, y: -900)
        scoreLabel.fontColor = UIColor.whiteColor()
        scoreLabel.fontSize = 150
        scoreLabel.text = String(score)
        cameraNode.addChild(scoreLabel)
    }
    
    func setupPlayerAndObstacles() {
        addPlayer()
        addObstacle()
        addObstacle()
        addObstacle()
    }
    
    func addObstacle() {
        let choice = Int(arc4random_uniform(1))
        switch choice {
        case 0:
            addCrossesObstacle()
        case 1:
            addSquareObstacle()
        case 2:
            addCircleObstacle()
        default:
            print("something went wrong")
        }
    }
    
    func addCircleObstacle() {
        //1
        let path = UIBezierPath()
        //2
        path.moveToPoint(CGPoint(x:0, y:-200))
        //3
        path.addLineToPoint(CGPointMake(0, -160))
        //4
        path.addArcWithCenter(CGPointZero, radius: 160, startAngle: CGFloat(3.0 * M_PI_2), endAngle: 0, clockwise: true)
        //5
        path.addLineToPoint(CGPointMake(200, 0))
        path.addArcWithCenter(CGPointZero, radius: 200, startAngle: 0.0, endAngle: CGFloat(3.0 * M_PI_2), clockwise: false)
        
        let obstacle = obstacleByDuplicatingPath(path, clockwise: true)
        obstacles.append(obstacle)
        obstacle.position = CGPoint(x: size.width/2, y: obstacleSpacing * CGFloat(obstacles.count))
        addChild(obstacle)
        
        //rotate the circle
        let rotateAction = SKAction.rotateByAngle(2.0 * CGFloat(M_PI), duration: 8.0)
        obstacle.runAction(SKAction.repeatActionForever(rotateAction))
    }
    
    func addSquareObstacle() {
        let path = UIBezierPath(roundedRect: CGRect(x: -200, y: -200,
            width: 400, height: 40),
                                cornerRadius: 20)
        
        let obstacle = obstacleByDuplicatingPath(path, clockwise: false)
        obstacles.append(obstacle)
        obstacle.position = CGPoint(x: size.width/2, y: obstacleSpacing * CGFloat(obstacles.count))
        addChild(obstacle)
        
        let rotateAction = SKAction.rotateByAngle(-2.0 * CGFloat(M_PI), duration: 7.0)
        obstacle.runAction(SKAction.repeatActionForever(rotateAction))
    }
    
    func addCrossesObstacle() {
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 200, height: 20),
                                cornerRadius: 10)
        let leftObstacle = obstacleByDuplicatingPath(path, clockwise: false)
        leftObstacle.position = CGPoint(x: size.width/2 - 200, y: obstacleSpacing * CGFloat(obstacles.count + 1))
        addChild(leftObstacle)
        
        let rightObstacle = obstacleByDuplicatingPath(path, clockwise: false)
        rightObstacle.position = CGPoint(x: size.width/2 + 200, y: obstacleSpacing * CGFloat(obstacles.count + 1))
        addChild(rightObstacle)
        
        let leftRotateAction = SKAction.rotateByAngle(2.0 * CGFloat(M_PI), duration: 7.0)
        let rightRotateAction = SKAction.rotateByAngle(-2.0 * CGFloat(M_PI), duration: 7.0)
        leftObstacle.runAction(SKAction.repeatActionForever(leftRotateAction))
        rightObstacle.runAction(SKAction.repeatActionForever(rightRotateAction))
        obstacles.append(leftObstacle)
        rightobstacles.append(rightObstacle)
    }
    
    
    //create secitons
    func obstacleByDuplicatingPath(path: UIBezierPath, clockwise: Bool) -> SKNode {
        let container = SKNode()
        
        var rotationFactor = CGFloat(M_PI_2)
        if !clockwise {
            rotationFactor *= -1
        }
        
        for i in 0...3 {
            let section = SKShapeNode(path: path.CGPath)
            section.fillColor = colors[i]
            section.strokeColor = colors[i]
            section.zRotation = rotationFactor * CGFloat(i);
            
            let sectionBody = SKPhysicsBody(polygonFromPath: path.CGPath)
            sectionBody.categoryBitMask = PhysicsCategory.Obstatcle
            sectionBody.collisionBitMask = 0
            sectionBody.contactTestBitMask = PhysicsCategory.Player
            sectionBody.affectedByGravity = false
            section.physicsBody = sectionBody
            container.addChild(section)
        }
        return container
    }
    
    func dieAndRestart() {
        
        print("boom")
        player.physicsBody?.velocity.dy = 0
        player.removeFromParent()
        
        for node in obstacles {
            node.removeFromParent()
        }
        for node in rightobstacles {
            node.removeFromParent()
        }
        
        obstacles.removeAll()
        rightobstacles.removeAll()
        setupPlayerAndObstacles()
        
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        score = 0
        scoreLabel.text = String(score)
    }
    
    //add player
    func addPlayer() {
        player.fillColor = UIColor.blueColor()
        player.strokeColor = UIColor.blueColor()
        player.position = CGPointMake(size.width/2, 200)
        addChild(player)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        player.physicsBody?.velocity.dy = 800.0
    }
    
    override func update(currentTime: NSTimeInterval) {
        
        if player.position.y > obstacleSpacing * CGFloat(obstacles.count - 2) {
            print("score")
            score += 1
            scoreLabel.text = String(score)
            addObstacle()
        }
        
        let playerPositionInCamera = cameraNode.convertPoint(player.position, toNode: self)
        if playerPositionInCamera.y > 0 && !cameraNode.hasActions() {
            cameraNode.position.y = player.position.y
        }
        
        if playerPositionInCamera.y < -size.height/2 {
            dieAndRestart()
        }
    }
    
}

//check is contact vaild
extension GameScene: SKPhysicsContactDelegate {
    
    func didBeginContact(contact: SKPhysicsContact) {
        if let nodeA = contact.bodyA.node as? SKShapeNode, let nodeB = contact.bodyB.node as? SKShapeNode {
            if nodeA.fillColor != nodeB.fillColor {
                dieAndRestart()
            }
        }
    }
}
