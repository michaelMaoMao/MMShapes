//
//  GameViewController.swift
//  MMShapes
//
//  Created by MichaelMao on 17/1/14.
//  Copyright © 2017年 MichaelMao. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: CGSize(width: 1536, height: 2048))
        //        let skView = self.view as! SKView
        let skView = SKView(frame: self.view.bounds)
        self.view .addSubview(skView)
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
    }
    
    
    override func prefersStatusBarHidden()-> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

