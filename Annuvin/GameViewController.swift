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

class GameViewController: UIViewController {

    @IBOutlet weak var gameView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
//                scene.scaleMode = .aspectFill
                let pawn = GamePiece("Pawn", image: "pawnNode")
                
                
                let hexBoardNode = scene.childNode(withName: "hexBoard")
                if let hexBoard = hexBoardNode as? SKTileMapNode {
                    let board = GameBoard(node: hexBoard)
                }
                else {
                    fatalError("No board found!")
                }
                
                let blurbNode = scene.childNode(withName: "blurb")
                if let blurb = blurbNode as? SKLabelNode {
                    blurb.text = String(describing: gameView)
                }
                else {
                    fatalError("No blurb found!")
                }
                // Present the scene
                view.presentScene(scene)
                
            }
            
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
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
