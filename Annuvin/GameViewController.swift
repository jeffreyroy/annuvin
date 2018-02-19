//
//  GameViewController.swift
//  Annuvin
//
//  Created by Jeffrey Roy on 4/7/17.
//  Copyright © 2017 Jeffrey Roy. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, SKSceneDelegate {
    
    let scene = SKScene(fileNamed: "GameScene")!
    @IBOutlet weak var gameView: SKView!
    
    // Initialize game variables
    let gameStart = AnnuvinModel(position: BoardDisplay().initialBoardArray(), players: [AnnuvinPlayer(0), AnnuvinPlayer(1)])
    let ai = GKMinmaxStrategist()

    override func viewDidLoad() {
        super.viewDidLoad()
        scene.delegate = self
        // Initialize ai
        ai.maxLookAheadDepth = 2
        ai.gameModel = gameStart
        //ai.randomSource = GKARC4RandomSource()

        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    func movePiece() {
        
    }
    
    // Return set of legal destinations for piece
    func getLegalDestinations(_ piece: SKSpriteNode) -> [BoardSpace] {
        // TBA
        return []
    }
    
    
    
    
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
