//
//  GameScene.swift
//  Brutalist_Smoke
//
//  Created by Miguel Sicart on 29/11/2017.
//  Copyright © 2017 Miguel Sicart. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit
import CoreMotion
import AudioToolbox.AudioServices //for vibration

//to do
//swipe left to cast cigarrette away
//intro with instructions
//monetization


class GameScene: SKScene, SKPhysicsContactDelegate
{
    var cig =  SKSpriteNode(color: .white, size: CGSize(width: 100, height: 750))
    var fltr = SKSpriteNode(color: .brown, size: CGSize(width:100, height: 150))
    var fire = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 30))
    var ashes = SKSpriteNode(color: .gray, size: CGSize(width:100, height:0.1))
    var smoke = SKEmitterNode(fileNamed: "Smoke.sks")
    
    var inhaling = false
    
    //when I decide to make the cloud work, some day
    var ashCloud:[SKSpriteNode] = [SKSpriteNode]()
    
    //TO check if we can make ashes
    var ashesArePossible:Bool = true
    
    //Saving
    let defaults = UserDefaults.standard
    
    //max number of cigs
    var maxCig = 5
    
    //have you smoked
    var smokedAlready:Bool = false
    
    //vibrate baby
    let vibrate = SystemSoundID(kSystemSoundID_Vibrate) //UInt with a value of 4095
    
    
    override func sceneDidLoad()
    {
        
    }
    
    override func didMove(to view: SKView)
    {
        if smokedAlready
        {
            loadFromMemory()
        }
        else
        {
            cig.position = CGPoint(x:self.frame.midX, y: self.frame.midY)
            self.addChild(cig)
            
            fltr.position = CGPoint(x:self.frame.midX, y: self.frame.midY-cig.size.height/2-fltr.size.height/2)
            self.addChild(fltr)
            
            fire.position = CGPoint(x: self.frame.midX, y: self.frame.midY+cig.size.height/2+fire.size.height/2)
            self.addChild(fire)
            
            
            ashes.position = CGPoint(x: self.frame.midX, y: fire.position.y + fire.size.height/2)
            ashes.physicsBody = SKPhysicsBody(rectangleOf: ashes.size)
            ashes.physicsBody?.affectedByGravity = false
            ashes.name = "firstAsh"
            self.addChild(ashes)
            ashCloud.append(ashes)
            
            smoke?.advanceSimulationTime(10)
            smoke?.position.x = self.frame.midX
            smoke?.position.y = fire.position.y + 15
            addChild(smoke!)
            
        }
        
        
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
    }
    
    func loadFromMemory()
    {
        let cigSizeWidth = defaults.object(forKey: "cigarrete_size_width") as! CGFloat!
        let cigSizeHeight = defaults.object(forKey: "cigarrete_size_height") as! CGFloat!
        let cigPosX = defaults.object(forKey: "cigarrete_pos_x") as! CGFloat!
        let cigPosY = defaults.object(forKey: "cigarrete_pos_y") as! CGFloat!
        
        cig = SKSpriteNode(color: .white, size: CGSize(width: cigSizeWidth!, height: cigSizeHeight!))
        cig.position = CGPoint(x: cigPosX!, y: cigPosY!)
        
        let ashesSizeWidth = defaults.object(forKey: "ashes_size_width") as! CGFloat!
        let ashesSizeHeight = defaults.object(forKey: "ashes_size_height") as! CGFloat!
        let ashesPosX = defaults.object(forKey: "ashes_pos_x") as! CGFloat!
        let ashesPosY = defaults.object(forKey: "ashes_pos_y") as! CGFloat!
        
        ashes = SKSpriteNode(color: .gray, size: CGSize(width:ashesSizeWidth!, height:ashesSizeHeight!))
        ashes.position = CGPoint(x: ashesPosX!, y: ashesPosY!)
        
        let fltrSizeWidth = defaults.object(forKey: "filter_size_width") as! CGFloat!
        let fltrSizeHeight = defaults.object(forKey: "filter_size_height") as! CGFloat!
        let fltrPosX = defaults.object(forKey: "filter_pos_x") as! CGFloat!
        let fltrPosY = defaults.object(forKey: "filter_pos_y") as! CGFloat!
        
        fltr = SKSpriteNode(color: .brown, size: CGSize(width:fltrSizeWidth!, height: fltrSizeHeight!))
        fltr.position = CGPoint(x: fltrPosX!, y: fltrPosY!)
        
        let fireSizeWidth = defaults.object(forKey: "fire_size_width") as! CGFloat!
        let fireSizeHeight = defaults.object(forKey: "fire_size_height") as! CGFloat!
        let firePosX = defaults.object(forKey: "fire_pos_x") as! CGFloat!
        let firePosY = defaults.object(forKey: "fire_pos_y") as! CGFloat!
        
        fire = SKSpriteNode(color: .red, size: CGSize(width: fireSizeWidth!, height: fireSizeHeight!))
        fire.position = CGPoint(x: firePosX!, y: firePosY!)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        inhaling = true
        AudioServicesPlaySystemSound(vibrate)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        inhaling = false
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        if inhaling
        {
            if cig.size.height < 100
            {
                print("reset")
                reset()
            }
            
            let wd = cig.size.height
            let yp = cig.position.y
            
            let drt = 0.0000000000001
            let nr:CGFloat = 0.5
            
            let inhaleSmoke = SKAction.resize(toHeight: wd-nr, duration: drt)
            
            let fakeIt = SKAction.move(to: CGPoint(x:self.frame.midX, y: yp-nr/2), duration: drt)
            
            let fireFakeIT = SKAction.move(to: CGPoint(x:self.frame.midX, y: yp + cig.size.height/2), duration: drt)
            
            let aTeam = SKAction.group([inhaleSmoke, fakeIt])
            cig.run(aTeam)
            fire.run(fireFakeIT)
            smoke?.position.y = fire.position.y + 15
            
            if ashes.name == "firstAsh"
            {
                //fix this for the fucking size crap goddamit shit (hello future Miguel)
                let ashesToAshes = SKAction.resize(toHeight: ashes.size.height + nr, duration: drt)
                let moveAshes = SKAction.move(to: CGPoint(x:self.frame.midX, y: fire.position.y+fire.size.height/2), duration: drt)
                let ashGroup = SKAction.group([ashesToAshes, moveAshes])
                
                
                ashes.run(ashGroup)
                
                if ashes.size.height >= 40
                {
                    ashesArePossible = false
                    ashes.removeAllActions()
                    ashes.physicsBody?.affectedByGravity = true
                    ashes.physicsBody?.applyImpulse(CGVector(dx:0.1, dy:0))
                }
            }
            
        }
        else if !inhaling
        {
            cig.removeAllActions()
            fire.removeAllActions()
            ashes.removeAllActions()
            fire.removeAllActions()
        }
        
        if !ashesArePossible
        {
            if ashes.position.y <= 3
            {
                ashes.removeFromParent()
                createAsh()
            }
        }
        
        if cig.size.height < 100
        {
            print("reset")
            reset()
        }
    }
    
    func createAsh()
    {
        ashes = SKSpriteNode(color: .gray, size: CGSize(width:100, height:0.1))
        ashes.position = CGPoint(x: self.frame.midX, y: fire.position.y + fire.size.height/2)
        ashes.physicsBody = SKPhysicsBody(rectangleOf: ashes.size)
        ashes.physicsBody?.affectedByGravity = false
        ashes.name = "firstAsh"
        self.addChild(ashes)
        ashCloud.append(ashes)
    }
    
    func reset()
    {
        cig.removeFromParent()
        fltr.removeFromParent()
        fire.removeFromParent()
        ashes.removeFromParent()
        
        cig.size = CGSize(width: 100, height: 750)
        cig.position = CGPoint(x:self.frame.midX, y: self.frame.midY)
        self.addChild(cig)
        
        fltr.size = CGSize(width: 100, height: 150)
        fltr.position = CGPoint(x:self.frame.midX, y: self.frame.midY-cig.size.height/2-fltr.size.height/2)
        self.addChild(fltr)
        
        fire.size = CGSize(width: 100, height: 20)
        fire.position = CGPoint(x: self.frame.midX, y: self.frame.midY+cig.size.height/2+fire.size.height/2)
        self.addChild(fire)
        
        ashes.size = CGSize(width: 100, height: 0.1)
        ashes.position = CGPoint(x: self.frame.midX, y: fire.position.y + fire.size.height/2)
        ashes.physicsBody = SKPhysicsBody(rectangleOf: ashes.size)
        ashes.physicsBody?.affectedByGravity = false
        ashes.name = "firstAsh"
        self.addChild(ashes)
        ashCloud.append(ashes)
        
    }
    
    func shake()
    {
        //https://stackoverflow.com/questions/41988160/detecting-shake-gesture-spritekit-in-swift
        ashesArePossible = false
        ashes.removeAllActions()
        ashes.physicsBody?.affectedByGravity = true
        ashes.physicsBody?.applyImpulse(CGVector(dx:0.1, dy:0))
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //saveStuff()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
    }
}
