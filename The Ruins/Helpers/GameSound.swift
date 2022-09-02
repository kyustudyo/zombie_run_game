
import Foundation
import SceneKit
import AudioToolbox.AudioServices

class GameSound {
    private static let explosion = SCNAudioSource(fileNamed: "voice.wav")
    private static let welcom = SCNAudioSource(fileNamed: "welcom.wav")
    private static let this = SCNAudioSource(fileNamed: "this.wav")
    private static let is_ = SCNAudioSource(fileNamed: "is_.wav")
    private static let enjoy = SCNAudioSource(fileNamed: "enjoy.wav")
    private static let scenario = SCNAudioSource(fileNamed: "scenario.wav")
    private static let vcFirst = SCNAudioSource(fileNamed: "first.wav")
    private static let vcSecond = SCNAudioSource(fileNamed: "second.wav")
    private static let vcThird = SCNAudioSource(fileNamed: "third.wav")
    private static let vcFourth = SCNAudioSource(fileNamed: "fourth.wav")
    private static let vcFifth = SCNAudioSource(fileNamed: "fifth.wav")
    private static let vcSixth = SCNAudioSource(fileNamed: "sixth.wav")
    private static let music = SCNAudioSource(fileNamed: "music.wav")
    private static let lightsec_0 = SCNAudioSource(fileNamed: "sec_0.wav")
    private static let lightsec_1 = SCNAudioSource(fileNamed: "sec_1.wav")
    private static let lightsec_2 = SCNAudioSource(fileNamed: "sec_2.wav")
    private static let lightsec_3 = SCNAudioSource(fileNamed: "sec_3.wav")
    private static let lightsec_4 = SCNAudioSource(fileNamed: "sec_4.wav")
    private static let lightsec_5 = SCNAudioSource(fileNamed: "sec_5.wav")
    private static let lightsec_6 = SCNAudioSource(fileNamed: "sec_6.wav")
    private static let lightsec_7 = SCNAudioSource(fileNamed: "sec_7.wav")
    private static let lightsec_8 = SCNAudioSource(fileNamed: "sec_8.wav")
    private static let lightsec_8_2 = SCNAudioSource(fileNamed: "sec_8_2.wav")
    private static let lightsec_9 = SCNAudioSource(fileNamed: "sec_9.wav")
    private static let third_0 = SCNAudioSource(fileNamed: "third_0.wav")
    private static let third_1 = SCNAudioSource(fileNamed: "third_1.wav")
    private static let third_2 = SCNAudioSource(fileNamed: "third_2.wav")
    private static let beforeLast = SCNAudioSource(fileNamed: "beforeLast.wav")
    private static let rem = SCNAudioSource(fileNamed: "rem.wav")
//    private static let lightsec_10 = SCNAudioSource(fileNamed: "sec_10.wav")
    
//    private static let welcom = SCNAudioSource(fileNamed: "bonus.wav")
//    private static let fire = SCNAudioSource(fileNamed: "sounds/fire.wav")
//    private static let bonus = SCNAudioSource(fileNamed: "sounds/bonus.wav")


    private static func play(_ name: String, source: SCNAudioSource, node: SCNNode) {
        let _ = GameAudioPlayer(name: name, source: source, node: node)
    }

    static func explosion(_ node: SCNNode) {
        guard explosion != nil else { return }
        
        GameSound.play("explosion", source: GameSound.explosion!, node: node)

    }
    static func getRem(_ node: SCNNode) {
        guard rem != nil else { return }
        
        GameSound.play("rem", source: GameSound.rem!, node: node)

    }
    
    static func vcFirst(_ node: SCNNode) {
        guard vcFirst != nil else { return }
        
        GameSound.play("vcFirst", source: GameSound.vcFirst!, node: node)
//        GameSound.vibrate()
    }
    static func vcSecond(_ node: SCNNode) {
        guard vcSecond != nil else { return }
        
        GameSound.play("vcSecond", source: GameSound.vcSecond!, node: node)
//        GameSound.vibrate()
    }
    static func vcThird(_ node: SCNNode) {
        guard vcThird != nil else { return }
        
        GameSound.play("vcThird", source: GameSound.vcThird!, node: node)
//        GameSound.vibrate()
    }
    static func vcFourth(_ node: SCNNode) {
        guard vcFourth != nil else { return }
        
        GameSound.play("vcFourth", source: GameSound.vcFourth!, node: node)
//        GameSound.vibrate()
    }
    
    static func vcFifth(_ node: SCNNode) {
        guard vcFifth != nil else { return }
        
        GameSound.play("vcFifth", source: GameSound.vcFifth!, node: node)
//        GameSound.vibrate()
    }
    static func vcSixth(_ node: SCNNode) {
        guard vcSixth != nil else { return }
        
        GameSound.play("vcSixth", source: GameSound.vcSixth!, node: node)
//        GameSound.vibrate()
    }
    static func music(_ node: SCNNode) {
        guard music != nil else { return }
        
        GameSound.play("music", source: GameSound.music!, node: node)
//        GameSound.vibrate()
    }
    static func lightsec_0(_ node: SCNNode) {
        guard vcSixth != nil else { return }
        
        GameSound.play("lightsec_0", source: GameSound.lightsec_0!, node: node)
//        GameSound.vibrate()
    }
    static func lightsec_1(_ node: SCNNode) {
        guard vcSixth != nil else { return }
        
        GameSound.play("lightsec_1", source: GameSound.lightsec_1!, node: node)
//        GameSound.vibrate()
    }
    static func lightsec_2(_ node: SCNNode) {
        guard vcSixth != nil else { return }
        
        GameSound.play("lightsec_2", source: GameSound.lightsec_2!, node: node)
//        GameSound.vibrate()
    }
    static func lightsec_3(_ node: SCNNode) {
        guard vcSixth != nil else { return }
        
        GameSound.play("lightsec_3", source: GameSound.lightsec_3!, node: node)
//        GameSound.vibrate()
    }
    static func lightsec_4(_ node: SCNNode) {
        guard vcSixth != nil else { return }
        
        GameSound.play("lightsec_4", source: GameSound.lightsec_4!, node: node)
//        GameSound.vibrate()
    }
    static func lightsec_5(_ node: SCNNode) {
        guard vcSixth != nil else { return }
        
        GameSound.play("lightsec_5", source: GameSound.lightsec_5!, node: node)
//        GameSound.vibrate()
    }
    static func lightsec_6(_ node: SCNNode) {
        guard vcSixth != nil else { return }
        
        GameSound.play("lightsec_6", source: GameSound.lightsec_6!, node: node)
//        GameSound.vibrate()
    }
    static func lightsec_7(_ node: SCNNode) {
        guard vcSixth != nil else { return }
        
        GameSound.play("lightsec_7", source: GameSound.lightsec_7!, node: node)
//        GameSound.vibrate()
    }
    static func lightsec_8(_ node: SCNNode) {
        guard vcSixth != nil else { return }
        
        GameSound.play("lightsec_8", source: GameSound.lightsec_8!, node: node)
//        GameSound.vibrate()
    }
    static func lightsec_8_2(_ node: SCNNode) {
        guard vcSixth != nil else { return }
        
        GameSound.play("lightsec_8_2", source: GameSound.lightsec_8_2!, node: node)
//        GameSound.vibrate()
    }
    static func lightsec_9(_ node: SCNNode) {
        guard vcSixth != nil else { return }
        
        GameSound.play("lightsec_9", source: GameSound.lightsec_9!, node: node)
//        GameSound.vibrate()
    }
    static func getthird_0(_ node: SCNNode) {
        guard vcSixth != nil else { return }
        
        GameSound.play("third_0", source: GameSound.third_0!, node: node)
//        GameSound.vibrate()
    }
    static func gethird_1(_ node: SCNNode) {
        guard vcSixth != nil else { return }
        
        GameSound.play("third_1", source: GameSound.third_1!, node: node)
//        GameSound.vibrate()
    }
    static func gethird_2(_ node: SCNNode) {
        guard third_2 != nil else { return }
        
        GameSound.play("third_2", source: GameSound.third_2!, node: node)
//        GameSound.vibrate()
    }
    static func getBeforeLast(_ node: SCNNode) {
        guard third_2 != nil else { return }
        
        GameSound.play("beforeLast", source: GameSound.beforeLast!, node: node)
//        GameSound.vibrate()
    }
//    static func lightsec_10(_ node: SCNNode) {
//        guard vcSixth != nil else { return }
//
//        GameSound.play("lightsec_10", source: GameSound.lightsec_10!, node: node)
////        GameSound.vibrate()
//    }
    static func this(_ node: SCNNode) {
        guard this != nil else { return }
        
        GameSound.play("this", source: GameSound.this!, node: node)
//        GameSound.vibrate()
    }
    static func _is(_ node: SCNNode) {
        guard _is != nil else { return }
        
        GameSound.play("is_", source: GameSound.is_!, node: node)
//        GameSound.vibrate()
    }
    
    static func enjoy(_ node: SCNNode) {
        guard enjoy != nil else { return }
        
        GameSound.play("enjoy", source: GameSound.enjoy!, node: node)
//        GameSound.vibrate()
    }
    static func scenario(_ node: SCNNode) {
        guard scenario != nil else { return }
        
        GameSound.play("scenario", source: GameSound.scenario!, node: node)
//        GameSound.vibrate()
    }
    
    static func welcom(_ node: SCNNode) {
        guard welcom != nil else { return }
        
        GameSound.play("welcom", source: GameSound.welcom!, node: node)
//        GameSound.vibrate()
    }
 
}

class GameAudioPlayer : SCNAudioPlayer {
    private var _node: SCNNode!
    
    init(name: String, source: SCNAudioSource, node: SCNNode) {
        super.init(source: source)
        
        node.addAudioPlayer(self)
        
        _node = node

//        rbDebug("GameAudioPlayer: play \(name)")

        self.didFinishPlayback = {
//            rbDebug("GameAudioPlayer: stopped \(name)")

            self._node.removeAudioPlayer(self)
        }
    }
    
}

