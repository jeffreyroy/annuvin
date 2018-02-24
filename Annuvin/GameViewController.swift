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

protocol GameDelegate: class {
    func gameState() -> AnnuvinModel
    func legalMoves(_ from: BoardSpace) -> [BoardSpace]
    func movePiece(_ from: BoardSpace, _ to: BoardSpace) -> Bool
    func aiMove() -> Move
}

class GameViewController: UIViewController, SKSceneDelegate, GameDelegate {

    let scene = SKScene(fileNamed: "GameScene")!
    @IBOutlet weak var gameView: SKView!
    
    // Initialize game variables
    let gameStart = AnnuvinModel(position: BoardDisplay().initialBoardArray(), players: [AnnuvinPlayer(0), AnnuvinPlayer(1)])
    let ai = GKMinmaxStrategist()

    override func viewDidLoad() {
        super.viewDidLoad()
//        scene.delegate = self
        let gameScene = scene as! GameScene
        gameScene.gameDelegate = self
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

    // Move a piece using coordinates from view, return true if successful
    func movePiece(_ from: BoardSpace, _ to: BoardSpace) -> Bool {
        let move = Move(from.model(), to.model())
        let update = AnnuvinUpdate(move)
        ai.gameModel!.apply(update)
        displayState()
        return true
    }
    
    // get current game state
    func gameState() -> AnnuvinModel {
        return ai.gameModel as! AnnuvinModel
    }
    
    // Return set of legal destinations for piece
    func legalMoves (_ from: BoardSpace) -> [BoardSpace] {
        let space = from.model() // Translate to model format
        let state = gameState()
        let player = state.activePlayer!
        let capturesOnly = state.movingPiece != nil
        // Get moves from model
        let moves = state.getDestinations(player, space, capturesOnly)
        // TBA
        let translatedMoves = moves.map { $0.view() }
        return translatedMoves
    }
    
    func aiMove() -> Move {
        let best = ai.bestMoveForActivePlayer() as! AnnuvinUpdate
        return best.move
    }
    
    // Log current game state to console, for testing
    func displayState() {
        let state = gameState()
        let displayer = BoardDisplay()
        let boardText = displayer.boardStringArray(state.position)
        displayer.printBoard(boardText)
        print("Player to move: " + String(describing: state.activePlayer!.playerId))
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
