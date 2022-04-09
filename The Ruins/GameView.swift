//
//  GameView.swift
//  The Ruins
//
//  Created by Valsamis Elmaliotis on 27/11/2017.
//  Copyright © 2017 Valsamis Elmaliotis. All rights reserved.
//

import SceneKit
import SpriteKit

//will hold the SpriteKit 2D UI

class GameView: SCNView {
    
    private var skScene:SKScene!
    private let overlayNode = SKNode()
    private var dpadSprite:SKSpriteNode!
    private var attackButtonSprite:SKSpriteNode!
    private var hpBar:SKSpriteNode!
    private let hpBarMaxWidth:CGFloat = 150.0
    
    //MARK:- lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup2DOverlay()
        setupObservers()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layout2DOverlay()
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- overlay functions
    private func setup2DOverlay() {
        
        let w = bounds.size.width
        let h = bounds.size.height
        
        skScene = SKScene(size: CGSize(width: w, height: h))
        skScene.scaleMode = .resizeFill
        
        skScene.addChild(overlayNode)
        overlayNode.position = CGPoint(x: 0.0, y: h)
        
        setupDpad(with: skScene)
        setupAttackButton(with: skScene)
        setupHpBar(with: skScene)
        
        overlaySKScene = skScene
        skScene.isUserInteractionEnabled = false
    }
    
    private func layout2DOverlay() {
        
        overlayNode.position = CGPoint(x: 0.0, y: bounds.size.height)
    }
    
    //MARK:- D-Pad
    private func setupDpad(with scene:SKScene) {
        
        dpadSprite = SKSpriteNode(imageNamed: "art.scnassets/Assets/dpad.png")
        dpadSprite.position = CGPoint(x: 10.0, y: 10.0)
        dpadSprite.xScale = 1.0
        dpadSprite.yScale = 1.0
        dpadSprite.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        dpadSprite.size = CGSize(width: 150.0, height: 150.0)
        scene.addChild(dpadSprite)
    }
    
    func virtualDPadBounds() -> CGRect {
        
        print(bounds)
        
        var virtualDPadBounds = CGRect(x: 10.0, y: 10.0, width: 150.0, height: 150.0)
        
        virtualDPadBounds.origin.y = bounds.size.height - virtualDPadBounds.size.height + virtualDPadBounds.origin.y
        
        return virtualDPadBounds
    }
    
    //MARK:- attack button
    private func setupAttackButton(with scene:SKScene) {
        
        attackButtonSprite = SKSpriteNode(imageNamed: "art.scnassets/Assets/attack1.png")
        attackButtonSprite.position = CGPoint(x: bounds.size.height-110.0, y: 50)
        attackButtonSprite.xScale = 1.0
        attackButtonSprite.yScale = 1.0
        attackButtonSprite.size = CGSize(width: 60.0, height: 60.0)
        attackButtonSprite.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        attackButtonSprite.name = "attackButton"
        scene.addChild(attackButtonSprite)
    }
    
    func virtualAttackButtonBounds() -> CGRect {
        
        var virtualAttackButtonBounds = CGRect(x: bounds.width-110, y: 50, width: 60.0, height: 60.0)
        
        virtualAttackButtonBounds.origin.y = bounds.size.height - virtualAttackButtonBounds.size.height - virtualAttackButtonBounds.origin.y
        
        return virtualAttackButtonBounds
    }
    
    //MARK:- HP bar
    private func setupHpBar(with scene:SKScene) {
        
        hpBar = SKSpriteNode(color: UIColor.green, size: CGSize(width: hpBarMaxWidth, height: 20))
        hpBar.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        hpBar.position = CGPoint(x: 15.0, y: bounds.width-35.0)
        hpBar.xScale = 1.0
        hpBar.yScale = 1.0
        scene.addChild(hpBar)
    }
    
    //MARK:- internal functions
    private func setupObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(hpDidChange), name: NSNotification.Name("hpChanged"), object: nil)
    }
    
    @objc private func hpDidChange(notification:Notification) {
        
        guard let userInfo = notification.userInfo as? [String:Any], let playerMaxHp = userInfo["playerMaxHp"] as? Float, let currentHp = userInfo["currentHp"] as? Float else { return }
        
        let v1 = CGFloat(playerMaxHp)
        let v2 = hpBarMaxWidth
        let v3 = CGFloat(currentHp)
        var x:CGFloat = 0.0
        
        //100 * x = 150 * 90 -> x = (150 * 90) / 100
        x = (v2 * v3) / v1
        
        if x <= hpBarMaxWidth / 3.5 {
            
            hpBar.color = UIColor.red
            
        } else if x <= hpBarMaxWidth / 2 {
            
            hpBar.color = UIColor.orange
        }
        
        if x < 0 { x = 0 }
        
        let reduceAction = SKAction.resize(toWidth: x, duration: 0.3)
        hpBar.run(reduceAction)
    }

}
