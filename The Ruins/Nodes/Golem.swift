//
//  Golem.swift
//  The Ruins
//
//  Created by Valsamis Elmaliotis on 03/12/2017.
//  Copyright © 2017 Valsamis Elmaliotis. All rights reserved.
//

import Foundation
import SceneKit

enum GolemAnimationType {
    
    case walk, attack1, dead
}
//골렘이 공중에 떠있으면 못때림.
//
class Golem:SCNNode {
    
    //general
    var gameView:GameView!
    
    //nodes
    private let daeHolderNode = SCNNode()
    private var characterNode:SCNNode!
    private var enemy:Player!
    private var collider:SCNNode!
    
    //animations
    private var walkAnimation = CAAnimation()
    private var deadAnimation = CAAnimation()
    private var attack1Animation = CAAnimation()
    
    //movement
    private var previousUpdateTime = TimeInterval(0.0)
    private let noticeDistance:Float = 140
    private let movementSpeedLimiter = Float(0.5)
    var didHit = false
    private var isWalking:Bool = false {
        
        didSet {
            
            if oldValue != isWalking {
                
                if isWalking {
                    
                    addAnimation(walkAnimation, forKey: "walk")
                    
                } else {
                    
                    removeAnimation(forKey: "walk")
                }
            }
        }
    }
    
    var isCollideWithEnemy = false {
        
        didSet {
            
            if oldValue != isCollideWithEnemy {
                
                if isCollideWithEnemy {
                    
                    isWalking = false
                }
            }
        }
    }
    
    //attack
    private var isAttacking = false
    private var lastAttackTime:TimeInterval = 0.0
    private var attackTimer:Timer?
    private var attackFrameCounter = 0
    
    //battle
    private var hpPoints:Float = 70.0
    private var isDead = false
    
    //MARK:- initialization
    init(enemy:Player, view:GameView) {
        super.init()
        
        self.gameView = view
        self.enemy = enemy
        
        setupModelScene()
        loadAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- scene
    private func setupModelScene() {
        
        name = "Golem"
        
//        let idleURL = Bundle.main.url(forResource: "art.scnassets/Scenes/Enemies/Golem@Idle", withExtension: "dae")
        let idleURL = Bundle.main.url(forResource: "art.scnassets/inplaceWalk", withExtension: "dae")
        let idleScene = try! SCNScene(url: idleURL!, options: nil)
        
        for child in idleScene.rootNode.childNodes {
            
            daeHolderNode.addChildNode(child)
        }
        
        addChildNode(daeHolderNode)
        characterNode = daeHolderNode
//        characterNode = daeHolderNode.childNode(withName: "CATRigHub002", recursively: true)!
    }
    
    //MARK:- animations
    private func loadAnimations() {
        loadAnimation(animationType: .walk, inSceneNamed: "art.scnassets/inplaceWalk", withIdentifier: "unnamed_animation__0")
        loadAnimation(animationType: .attack1, inSceneNamed: "art.scnassets/inplaceWalk", withIdentifier: "unnamed_animation__0")
//        loadAnimation(animationType: .walk, inSceneNamed: "art.scnassets/Scenes/Enemies/Golem@Flight", withIdentifier: "unnamed_animation__1")
        
//        loadAnimation(animationType: .dead, inSceneNamed: "art.scnassets/Scenes/Enemies/Golem@Dead", withIdentifier: "Golem@Dead-1")
        
//        loadAnimation(animationType: .attack1, inSceneNamed: "art.scnassets/Scenes/Enemies/Golem@Attack(1)", withIdentifier: "Golem@Attack(1)-1")
    }
    
    private func loadAnimation(animationType:GolemAnimationType, inSceneNamed scene:String, withIdentifier identifier:String) {
        
        let sceneURL = Bundle.main.url(forResource: scene, withExtension: "dae")!
        let sceneSource = SCNSceneSource(url: sceneURL, options: nil)!
        
        let animationObject:CAAnimation = sceneSource.entryWithIdentifier(identifier, withClass: CAAnimation.self)!
        
        animationObject.delegate = self
        animationObject.fadeInDuration = 0.2
        animationObject.fadeOutDuration = 0.2
        animationObject.usesSceneTimeBase = false
        animationObject.repeatCount = 0
        
        switch animationType {
            
        case .walk:
            
            animationObject.repeatCount = Float.greatestFiniteMagnitude
            walkAnimation = animationObject
            
        case .dead:
            
            animationObject.isRemovedOnCompletion = false
            deadAnimation = animationObject
            
        case .attack1:
            
            animationObject.setValue("attack1", forKey: "animationId")
            attack1Animation = animationObject
        }
    }
    
    //MARK:- movement
    func update(with time:TimeInterval, and scene:SCNScene) {
        
        guard let enemy = enemy, !enemy.isDead, !isDead else { return }
       
        //delta time
        if previousUpdateTime == 0.0 { previousUpdateTime = time }
        let deltaTime = Float(min(time-previousUpdateTime, 1.0/60.0))
        previousUpdateTime = time
        
        //get distance
        let distance = GameUtils.distanceBetweenVectors(vector1: enemy.position, vector2: position)
       
        if distance < noticeDistance && distance > 0.001 {
            
            //move
            let vResult = GameUtils.getCoordinatesNeededToMoveToReachNode(form: position, to: enemy.position)
            let vx = vResult.vX
            let vz = vResult.vZ
            let angle = vResult.angle
            
            //rotate
            let fixedAngle = GameUtils.getFixedRotationAngle(with: angle)
            eulerAngles = SCNVector3Make(0, fixedAngle, 0)
            
            if !isCollideWithEnemy && !isAttacking {
            
                let characterSpeed = deltaTime * movementSpeedLimiter
                
                if vx != 0.0 && vz != 0.0 {
                    
                    position.x += vx * characterSpeed * 30
                    position.z += vz * characterSpeed * 30
                    
                    isWalking = true
                    
                } else {
                    
                    isWalking = false
                }
                
                //update the altidute
                let initialPosition = position
                
                var pos = position
                var endpoint0 = pos
                var endpoint1 = pos
                
                endpoint0.y -= 2
                endpoint1.y += 2
                
                let results = scene.physicsWorld.rayTestWithSegment(from: endpoint1, to: endpoint0, options: [.collisionBitMask: BitmaskWall, .searchMode: SCNPhysicsWorld.TestSearchMode.closest])
                
                if let result = results.first {
                    
                    let groundAltitude = result.worldCoordinates.y
                    pos.y = groundAltitude
                    
                    position = pos
                    
                } else {
                    
                    position = initialPosition
                }
                
            } else {
                
                ///attack
                if lastAttackTime == 0.0 {
                    
                    lastAttackTime = time
                    attack1()
                }
                
                let timeDiff = time - lastAttackTime
                
                if timeDiff >= 2.5 {
                    
                    lastAttackTime = time
                    attack1()
                }
            }
            
        } else {
            
            isWalking = false
        }
    }
    
    //MARK:- collisions
    func setupCollider(scale:CGFloat) {
        
        let geometry = SCNCapsule(capRadius: 1, height: 22)
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        collider = SCNNode(geometry: geometry)
        collider.name = "golemCollider"
        collider.position = SCNVector3Make(0, 22, 0)
        collider.opacity = 1.0
        
        let shapeGeometry = SCNCapsule(capRadius: 3 * scale, height: 44 * scale)
        let physicsShape = SCNPhysicsShape(geometry: shapeGeometry, options: nil)
        collider.physicsBody = SCNPhysicsBody(type: .kinematic, shape: physicsShape)
        collider.physicsBody!.categoryBitMask = BitmaskGolem
        
        collider.physicsBody!.contactTestBitMask = BitmaskPlayer | BitmaskPlayerWeapon
        //BitmaskWall을 지워도 계단 오를 수 있다.
        
        gameView.prepare([collider]) {
            (finished) in
            
            self.addChildNode(self.collider)
        }
    }
    
    //MARK:- battle
    private func attack1() {
        
        if isAttacking { return }
        
        isAttacking = true
        
        DispatchQueue.main.async {
            
            self.attackTimer?.invalidate()
            self.attackTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.attackTimerTicked), userInfo: nil, repeats: true)
            
            self.characterNode.addAnimation(self.attack1Animation, forKey: "attack1")
        }
    }
    
    @objc private func attackTimerTicked() {
        
        attackFrameCounter += 1
        
        if attackFrameCounter == 1 {//원래10
            
            if isCollideWithEnemy && !didHit {
                
                enemy.gotHit(with: 5)
                print("hit!")
                didHit = true
            }
        }
    }
    
    func gotHit(by node:SCNNode, with hpHitPoints:Float) {
        
        hpPoints -= hpHitPoints
        
        if hpPoints <= 0 {
            
            die()
        }
    }
    
    private func die() {
        
        isDead = true
        addAnimation(deadAnimation, forKey: "dead")
        
        let wait = SCNAction.wait(duration: 3.0)
        let remove = SCNAction.run { (node) in
            
            self.removeAllAnimations()
            self.removeAllActions()
            self.removeFromParentNode()
        }
        
        let seq = SCNAction.sequence([wait, remove])
        runAction(seq)
    }
}

//MARK:- extensions
extension Golem: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        guard let id = anim.value(forKey: "animationId") as? String else { return }
        
        if id == "attack1" {
            
            attackTimer?.invalidate()
            attackFrameCounter = 0
            isAttacking = false
        }
    }
}
