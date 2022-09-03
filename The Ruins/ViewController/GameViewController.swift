//
//  GameViewController.swift
//  The Ruins
//
//  Created by Valsamis Elmaliotis on 27/11/2017.
//  Copyright © 2017 Valsamis Elmaliotis. All rights reserved.
//

import UIKit
import SceneKit

let BitmaskPlayer = 1
let BitmaskPlayerWeapon = 2
let BitmaskWall = 64
let BitmaskGolem = 3

enum GameState {
    
    case loading, playing
}
//stage복붙 할때 카메라 이상해서 다시 카메라 만들어서 넣어야함.
//캐릭터 속도가 느려 안가느줄
class GameViewController: UIViewController {
    
    //scene
    var gameView:GameView { return view as! GameView }
    var mainScene:SCNScene!
    
    //general
    var gameState:GameState = .loading
    
    //nodes
    private var player:Player?
    private var player2: Player?
    private var cameraStick:SCNNode!
    private var cameraXHolder:SCNNode!
    private var cameraYHolder:SCNNode!
    private var lightStick:SCNNode!
    
    //movement
    private var controllerStoredDirection = float2(0.0)
    private var padTouch:UITouch?
    private var cameraTouch:UITouch?
    
    //collisions
    private var maxPenetrationDistance = CGFloat(0.0)
    private var replacementPositions = [SCNNode:SCNVector3]()

    //enemies
    private var golemsPositionArray = [String:SCNVector3]()
    private var peoplePositionArray = [String:SCNVector3]()
    private var specialPositionArray = [String:SCNVector3]()
    //MARK:- lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupPlayer()
        setupPlayer2()
        setupCamera()
        setupLight()
        setupWallBitmasks()
        setupEnemies()
        gameState = .playing
        
    }
    
    override var shouldAutorotate: Bool { return true }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    //MARK:- scene
    private func setupScene() {
        
//        gameView.allowsCameraControl = true
        gameView.antialiasingMode = .multisampling4X
        gameView.delegate = self
        
        mainScene = SCNScene(named: "art.scnassets/stage3.scn")
        mainScene.physicsWorld.contactDelegate = self
        
        gameView.scene = mainScene
        gameView.isPlaying = true
    }
    
    //MARK:- player
    private func setupPlayer() {
        
        player = Player()
        player!.scale = SCNVector3Make(0.26, 0.26, 0.26)
        player!.position = SCNVector3Make(0.0, 0.0, 0.0)
        player!.rotation = SCNVector4Make(0, 1, 0, Float.pi)
        
        mainScene.rootNode.addChildNode(player!)
        
        player!.setupCollider(with: 0.26)
        player!.setupWeaponCollider(with: 0.26)
    }
    private func setupPlayer2() {
        
        let target = mainScene.rootNode.childNode(withName: "target", recursively: false)!
        
     
        
        
        player2 = Player()
        player2!.scale = SCNVector3Make(0.26, 0.26, 0.26)
        player2!.position = target.worldPosition
        player2!.rotation = SCNVector4Make(0, 1, 0, Float.pi)
        player2?.opacity = 0.0
        mainScene.rootNode.addChildNode(player2!)
        
        player2!.setupCollider(with: 0.26)
        player2!.setupWeaponCollider(with: 0.26)
    }
    
    
    //MARK:- touches + movement
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     
        for touch in touches {
            
            if gameView.virtualDPadBounds().contains(touch.location(in: gameView)) {
//                print("1")
                if padTouch == nil {
//                    print("2")//첫dp
                    padTouch = touch
                    controllerStoredDirection = float2(0.0)
                }
                
            } else if gameView.virtualAttackButtonBounds().contains(touch.location(in: gameView)) {
//                print("3")//어택
                player!.attack1()
                
            } else if cameraTouch == nil {//아무데도아닌곳
//                print("4")
                cameraTouch = touches.first
            }
            
            if padTouch != nil { break }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        if let touch = padTouch {
//            print("a")
            let displacement = float2(touch.location(in: view)) - float2(touch.previousLocation(in: view))
//            print("csd: \(controllerStoredDirection)")
            let vMix = mix(controllerStoredDirection, displacement, t: 0.1)
            let vClamp = clamp(vMix, min: -1.0, max: 1.0)
            
            controllerStoredDirection = vClamp
            
        } else if let touch = cameraTouch {
//            print("b")
            let displacement = float2(touch.location(in: view)) - float2(touch.previousLocation(in: view))
            
            panCamera(displacement)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        padTouch = nil
        controllerStoredDirection = float2(0.0)
        cameraTouch = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        padTouch = nil
        controllerStoredDirection = float2(0.0)
        cameraTouch = nil
    }
    
    private func characterDirection() -> float3 {
        
        var direction = float3(controllerStoredDirection.x, 0.0, controllerStoredDirection.y)
        
        if let pov = gameView.pointOfView {
            
            let p1 = pov.presentation.convertPosition(SCNVector3(direction), to: nil)
            let p0 = pov.presentation.convertPosition(SCNVector3Zero, to: nil)
//            print("p1\(p1),p0\(p0)")
            direction = float3(Float(p1.x-p0.x), 0.0, Float(p1.z-p0.z))
            
            if direction.x != 0.0 || direction.z != 0.0 {
                
                direction = normalize(direction)
            }
        }
        
        return direction
    }

    //MARK:- camera
    private func setupCamera() {
        
        cameraStick = mainScene.rootNode.childNode(withName: "CameraStick", recursively: false)!
        
        cameraXHolder = mainScene.rootNode.childNode(withName: "xHolder", recursively: true)!
        
        cameraYHolder = mainScene.rootNode.childNode(withName: "yHolder", recursively: true)!
    }
    
    private func panCamera(_ direction:float2) {
        
        var directionToPan = direction
        directionToPan *= float2(1.0, -1.0)
        
        let panReducer = Float(0.005)
        
        let currX = cameraXHolder.rotation
        let xRotationValue = currX.w - directionToPan.x * panReducer
        
        let currY = cameraYHolder.rotation
        var yRotationValue = currY.w + directionToPan.y * panReducer
        
        if yRotationValue < -0.94 { yRotationValue = -0.94 }
        if yRotationValue > 0.46 { yRotationValue = 0.46 }
        
        cameraXHolder.rotation = SCNVector4Make(0, 1, 0, xRotationValue)
        cameraYHolder.rotation = SCNVector4Make(1, 0, 0, yRotationValue)
    }
    
    private func setupLight() {
        
        lightStick = mainScene.rootNode.childNode(withName: "LightStick", recursively: false)!
    }
    
    //MARK:- game loop functions
    
    func updateFollowersPositions() {//캐릭터 움직이면 빛하고, 카메라 따라가게.
        
        cameraStick.position = SCNVector3Make(player!.position.x, 0.0, player!.position.z)
        lightStick.position = SCNVector3Make(player!.position.x, 0.0, player!.position.z)
    }
    
    //MARK:- walls
    private func setupWallBitmasks() {
        
        var collisionNodes = [SCNNode]()
        
        mainScene.rootNode.enumerateChildNodes { (node, _) in
            
            switch node.name {
                
            case let .some(s) where s.range(of: "collision") != nil:
//                print("node#@@@", node)
                collisionNodes.append(node)
                
            default:
                break
            }
        }
        
        for node in collisionNodes {
            
            node.physicsBody = SCNPhysicsBody.static()
            node.physicsBody!.categoryBitMask = BitmaskWall
            node.physicsBody!.physicsShape = SCNPhysicsShape(node: node, options: [.type: SCNPhysicsShape.ShapeType.concavePolyhedron as NSString])
        }
    }
    
    //MARK:- collisions
    private func characterNode(_ characterNode:SCNNode, hitWall wall:SCNNode, withContact contact:SCNPhysicsContact) {
//        print("collide~!~!")
        if characterNode.name != "collider" && characterNode.name != "golemCollider" { return }
        
        if maxPenetrationDistance > contact.penetrationDistance { return }
        
        maxPenetrationDistance = contact.penetrationDistance
        
        var characterPosition = float3(characterNode.parent!.position)
        var positionOffest = float3(contact.contactNormal) * Float(contact.penetrationDistance)
        positionOffest.y = 0
        characterPosition += positionOffest
        
        replacementPositions[characterNode.parent!] = SCNVector3(characterPosition)
    }
    
    //MARK:- enemies
    private func setupEnemies() {
        
//        let enemies = mainScene.rootNode.childNode(withName: "Enemies", recursively: false)!
        let people = mainScene.rootNode.childNode(withName: "people", recursively: false)!
        let special = mainScene.rootNode.childNode(withName: "special", recursively: false)!
        //정보가져가려고 한것. 그림에서도 빈노드로 만든것.
//        print(enemies)
//        for child in enemies.childNodes {
//
//            golemsPositionArray[child.name!] = child.position
//
//        }
        
        
        for child in people.childNodes {
            peoplePositionArray[child.name!] = child.worldPosition
            
        }
//        print(special.childNodes)
        for child in special.childNodes {
            specialPositionArray[child.name!] = child.worldPosition
        }
//        print(golemsPositionArray)
        setupGolems()
    }
    
    private func setupGolems() {
        
        let golemScale:Float = 0.083
        let specialScale:Float = 0.3
        var golems: [Golem] = [Golem]()
        var specials: [Golem] = [Golem]()
//        print("peoplep",peoplePositionArray)
        for i in 1...peoplePositionArray.count {
//            print("\(i)번째 사람: \(peoplePositionArray["inplaceWalk\(i)"]!)")
            golems.append(Golem(enemy: player!, view: gameView))
            golems[i-1].scale = SCNVector3Make(golemScale, golemScale, golemScale)
//            print(i)
            golems[i-1].position = peoplePositionArray["inplaceWalk\(i)"]!
        }
        gameView.prepare(golems) {
            (finished) in
            self.prepareHelper(golems: golems, golemScale: golemScale)
        }
        
        for i in 1...specialPositionArray.count {
            specials.append(Golem(enemy: player2!, view: gameView))
            specials[i-1].scale = SCNVector3Make(specialScale, specialScale, specialScale)
            specials[i-1].position = specialPositionArray["special\(i)"]!
        }

        
        gameView.prepare(specials) {
            (finished) in
            self.prepareHelper(golems: specials, golemScale: specialScale)
        }

    }
}

//MARK:- extensions

//physics
extension GameViewController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        if gameState != .playing { return }
        
        //if player collide with wall
        contact.match(BitmaskWall) {
            (matching, other) in
            print("1mo",matching,other)
            self.characterNode(other, hitWall: matching, withContact: contact)
        }
        
        //if player collide with golem
        contact.match(BitmaskGolem) {
            
            (matching, other) in
//            print("2mo", matching,other)
            let golem = matching.parent as! Golem
            if other.name == "collider" { golem.isCollideWithEnemy = true }
            if other.name == "weaponCollider" { player!.weaponCollide(with: golem) }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        
        //if player collide with wall
        contact.match(BitmaskWall) {
            (matching, other) in
            
            self.characterNode(other, hitWall: matching, withContact: contact)
        }
        
        //if player collide with golem
        contact.match(BitmaskGolem) {
            (matching, other) in
            
            let golem = matching.parent as! Golem
            if other.name == "collider" { golem.isCollideWithEnemy = true }
            if other.name == "weaponCollider" { player!.weaponCollide(with: golem) }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        
        //if player collide with golem
        contact.match(BitmaskGolem) {
            (matching, other) in
            
            let golem = matching.parent as! Golem
            if other.name == "collider" { golem.isCollideWithEnemy = false }
            if other.name == "weaponCollider" { player!.weaponUnCollide(with: golem) }
        }
    }
}

//game loop
extension GameViewController:SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
//
        if gameState != .playing { return }

        for (node,position) in replacementPositions {

            node.position = position
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if gameState != .playing { return }

        //reset
        replacementPositions.removeAll()
        maxPenetrationDistance = 0.0

        let scene = gameView.scene!
        let direction = characterDirection()

        player!.walkInDirection(direction, time: time, scene: scene)

        updateFollowersPositions()
        
        
        mainScene.rootNode.enumerateChildNodes { (node, _) in

            if let name = node.name {

                switch name {

                case "Golem":
                    (node as! Golem).update(with: time, and: scene)

                default:
                    break
                }
            }
        }
    }
}


extension GameViewController {
    func prepareHelper(golems:[Golem], golemScale:Float){
//        print("count", golems.count)
        for g in golems {
            self.mainScene.rootNode.addChildNode(g)
            g.setupCollider(scale: CGFloat(golemScale))
        }
    }
}









