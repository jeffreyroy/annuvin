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

// Protocol to allow view to delegate gameplay functions to controller
protocol GameDelegate: class {
    func resetGame()
    func gameState() -> AnnuvinModel
    func piecesFor(_ playerId: Int ) -> [BoardSpace]
    func legalMoves(_ from: BoardSpace) -> [BoardSpace]
    func movePiece(_ move: Move) -> Bool
    func aiMove() -> Move
    func winner() -> Int?
}

// MARK: View controller
class GameViewController: UIViewController, SKSceneDelegate, GameDelegate {
    // MARK: Initialization
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
        ai.maxLookAheadDepth = 7
        ai.gameModel = gameStart.copy() as! AnnuvinModel
        //ai.randomSource = GKARC4RandomSource()
        // Load the SKScene from 'GameScene.sks'
        if let view = self.view as! SKView? {
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    // MARK: Delegated functions
    
    // Reset game to initial position
    func resetGame() {
        print("Resetting game...")
        ai.gameModel = gameStart.copy() as! AnnuvinModel
    }

    
    // get current game state
    func gameState() -> AnnuvinModel {
        return ai.gameModel as! AnnuvinModel
    }
    
    // Return list of pieces for a player
    func piecesFor(_ playerId: Int) -> [BoardSpace] {
        let player = gameState().players![playerId]
        let pieceList = gameState().piecesFor(player)
        return pieceList.map { $0.view() }
    }
    
    // Return set of legal destinations for piece
    func legalMoves (_ from: BoardSpace) -> [BoardSpace] {
        let space = from.model() // Translate to model format
        let state = gameState()
        let player = state.activePlayer!
        let capturesOnly = state.movingPiece != nil
        // Get moves from model
        let moves = state.getDestinations(player, space, capturesOnly)
        // Convert to view format
        let translatedMoves = moves.map { $0.view() }
        return translatedMoves
    }
    
    // Move a piece using coordinates from view, return true if piece can
    // make additional captures
    func movePiece(_ move: Move) -> Bool {
        let m = move.model()
        let f = String(describing: [m.from.y, m.from.x])
        let t = String(describing: [m.to.y, m.to.x])
        let update = AnnuvinUpdate(m)
        print ("Moving from " + f + " to " + t)
        ai.gameModel!.apply(update)
        displayState()
        return gameState().movingPiece != nil
    }
    
    // Return best move for ai
    func aiMove() -> Move {
        let best = ai.bestMoveForActivePlayer() as! AnnuvinUpdate
        return best.move.view()
    }
    
    // Return winner if game is over, otherwise nil
    func winner() -> Int? {
        for playerId in [0, 1] {
            let player = gameState().players![playerId]
            if gameState().isWin(for: player) {
                return playerId
            }
        }
        return nil
    }

    
    // Log current game state to console, for testing
    func displayState() {
        let state = gameState()
        let displayer = BoardDisplay()
        let player = state.activePlayer!
        let boardText = displayer.boardStringArray(state.position)
        displayer.printBoard(boardText)
        print("Player to move: " + String(describing: player.playerId))
        print("Pieces left: " + String(describing: state.piecesLeft))
        if state.movingPiece != nil {
            let p = state.movingPiece!
            print("Moving piece: " + String(describing: [p.y, p.x]))
            print("Moves left: " + String(describing: state.movesLeft))

        }
//        print("Pieces available: " + String(describing: state.piecesFor(player)))
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
