/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Contains the object recognition view controller for the Breakfast Finder.
*/

import UIKit
import AVFoundation
import Vision
import SceneKit

enum cDirection:String {
    case u
    case l
    case d
    case r
    case n
}
var cdirection: cDirection = .n

extension VisionObjectRecognitionViewController {

    @discardableResult
    func setupVision() -> NSError? {
        // Setup Vision parts
        let error: NSError! = nil
        
        guard let modelURL = Bundle.main.url(forResource: "C_R_S_T", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        self.drawVisionRequestResults(results)
                    }
                })
            })
            self.requests = [objectRecognition]
        } catch let error as NSError {
//            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    func drawVisionRequestResults(_ results: [Any]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
            shapeLayer.backgroundColor = UIColor.clear.cgColor
//            print("qqq", topLabelObservation.identifier)
            cdirection = cDirection.init(rawValue: topLabelObservation.identifier) ?? .n
            if cdirection != .n {
                player?.first = false
            }
//            print("qwer", topLabelObservation.identifier, topLabelObservation.confidence)
//            let textLayer = self.createTextSubLayerInBounds(objectBounds,
//                                                            identifier: topLabelObservation.identifier,
//                                                            confidence: topLabelObservation.confidence)
//            shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
        }
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    
    func setupLayers() {
        detectionOverlay = CALayer() // container layer that has all the renderings of the observations
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionOverlay)
    }
    
    func updateLayerGeometry() {
        let bounds = rootLayer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // rotate the layer into screen orientation and scale and mirror
        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
        
    }
    
//    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
//        let textLayer = CATextLayer()
//        textLayer.name = "Object Label"
//        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
////        print(identifier)
//        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
//        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
//        textLayer.string = formattedString
//        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
//        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
//        textLayer.shadowOpacity = 0.7
//        textLayer.shadowOffset = CGSize(width: 2, height: 2)
//        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
//        textLayer.contentsScale = 2.0 // retina rendering
//        // rotate the layer into screen orientation and scale and mirror
//        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
//        return textLayer
//    }
    
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }
    
}

class VisionObjectRecognitionViewController: ViewController {
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
//            print(error)
        }
    }
    
    override func setupAVCapture() {
        super.setupAVCapture()
        
        // setup Vision parts
        setupLayers()
        updateLayerGeometry()
        setupVision()
        
        // start the capture
        startCaptureSession()
    }
    
    private var detectionOverlay: CALayer! = nil
    
    // Vision parts
    private var requests = [VNRequest]()
    
    //scene
    var gameView:GameView {
        return view.subviews.first as! GameView
    }
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
//        gameView.allowsCameraControl = true
    }
    
    //MARK:- player
    private func setupPlayer() {
        
        player = Player()
        GameSound.music(self.player!)
        player!.scale = SCNVector3Make(0.14, 0.14, 0.14)
        player!.position = SCNVector3Make(1.0, 0.0, 0.0)
        player!.rotation = SCNVector4Make(0, 0, 0, Float.pi)
        
        mainScene.rootNode.addChildNode(player!)
        
        player!.setupCollider(with: 14)
        player!.setupWeaponCollider(with: 14)
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
        print("qw!",direction)
        
        switch cdirection {
        case .r: direction = .init(x: 1, y: 0, z: 0)
        case .d: direction = .init(x: 0, y: 0, z: 1)
        case .l: direction = .init(x: -1, y: 0, z: 0)
        case .u: direction = .init(x: 0, y: 0, z: -1)
            
        default: direction = .zero
        }
//        print("direction!!:\(direction)")
        return direction
    }

    //MARK:- camera
    private func setupCamera() {
        
        cameraStick = mainScene.rootNode.childNode(withName: "CameraStick", recursively: false)!
        
        cameraXHolder = mainScene.rootNode.childNode(withName: "xHolder", recursively: true)!
        
        cameraYHolder = mainScene.rootNode.childNode(withName: "yHolder", recursively: true)!
        
        cameraStick.light?.attenuationEndDistance = .greatestFiniteMagnitude
        cameraStick.light?.attenuationStartDistance = 0
    }
    
    private func panCamera(_ direction:float2) {
        
        var directionToPan = direction
        directionToPan *= float2(1.0, -1.0)
        
        let panReducer = Float(0.005)
        
        let currX = cameraXHolder.rotation
        let xRotationValue = currX.w - directionToPan.x * panReducer
        
        let currY = cameraYHolder.rotation
        var yRotationValue = currY.w + directionToPan.y * panReducer
        
        if yRotationValue < -0.94 {
            yRotationValue = -0.94
            
        }
        if yRotationValue > 0.46 {
            yRotationValue = 0.46
            
        }
        
        cameraXHolder.rotation = SCNVector4Make(0, 1, 0, xRotationValue)
        cameraYHolder.rotation = SCNVector4Make(1, 0, 0, yRotationValue)
    }
    
    private func setupLight() {
        
        lightStick = mainScene.rootNode.childNode(withName: "LightStick", recursively: false)!
    }
    
    //MARK:- game loop functions
    
    func updateFollowersPositions() {//캐릭터 움직이면 빛하고, 카메라 따라가게.
        
        cameraStick.position = SCNVector3Make(player!.position.x, 30.0, player!.position.z)
        lightStick.position = SCNVector3Make(player!.position.x, 30.0, player!.position.z)
        print(cameraStick.position)
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
        print("collide~!~!")
        if characterNode.name != "collider" && characterNode.name != "golemCollider" { return }
        print("collide~!~!collide~!~!collide~!~!")
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
        
        
        for (i,child) in people.childNodes.enumerated() {
            peoplePositionArray[child.name!] = child.worldPosition
        }
//        print(special.childNodes)
        for child in special.childNodes {
            specialPositionArray[child.name!] = child.worldPosition
        }
//        print(golemsPositionArray)
        setupGolems()
    }
    var golemScale:Double = 0.3
    private func setupGolems() {
        
        
        let specialScale:Float = 0.3
        var golems: [Golem] = [Golem]()
        var specials: [Golem] = [Golem]()
//        print("peoplep",peoplePositionArray)
        for i in 1...peoplePositionArray.count {
            if i > 10 { break }
//            print("\(i)번째 사람: \(peoplePositionArray["inplaceWalk\(i)"]!)")
            golems.append(Golem(enemy: player!, view: gameView))
            golemScale = [0.25,0.26,0.27,0.28,0.29,0.30,0.31,0.32,0.33,0.34,0.35,0.36,0.37,0.38,0.39].randomElement()! / 2
            golems[i-1].scale = SCNVector3Make(Float(golemScale), Float(golemScale), Float(golemScale))
//            print(i)
            golems[i-1].position = peoplePositionArray["inplaceWalk\(i)"]!
        }
        gameView.prepare(golems) {
            (finished) in
            self.prepareHelper(golems: golems, golemScale: Float(self.golemScale))
        }
        
        for i in 1...specialPositionArray.count {
//            specials.append(Golem(enemy: player2!, view: gameView))
//            specials[i-1].scale = SCNVector3Make(specialScale, specialScale, specialScale)
//            specials[i-1].position = specialPositionArray["special\(i)"]!
        }

        
        gameView.prepare(specials) {
            (finished) in
            self.prepareHelper(golems: specials, golemScale: specialScale)
        }

    }
}

extension VisionObjectRecognitionViewController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        if gameState != .playing { return }
        
        //if player collide with wall
        contact.match(BitmaskWall) {
            (matching, other) in
//            print("1mo",matching,other)
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
            if other.name == "collider" {
                golem.isCollideWithEnemy = true
                print("iscollide true~")
            }
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
extension VisionObjectRecognitionViewController: SCNSceneRendererDelegate {
    
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
        
//        cdirection = .n
        
//        print("관심,", direction)
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


extension VisionObjectRecognitionViewController {
    func prepareHelper(golems:[Golem], golemScale:Float){
//        print("count", golems.count)
        for g in golems {
            self.mainScene.rootNode.addChildNode(g)
            g.setupCollider(scale: CGFloat(golemScale))
        }
    }
}









