//
//  GameScene.swift
//  Annuvin
//
//  Created by Jeffrey Roy on 4/7/17.
//  Copyright © 2017 Jeffrey Roy. All rights reserved.
//

import SpriteKit
import GameplayKit




class GameScene: SKScene {
    // Delegate game logic to view controller
    weak var gameDelegate: GameDelegate?
    // Use premade tile set for testing
    let tileSet = SKTileSet(named: "Sample Hexagonal Tile Set")
    var readyForInput: Bool = false
    var activePiece: SKSpriteNode? = nil
    
    func gameBoard() -> SKTileMapNode {
        return childNode(withName: "hexBoard") as! SKTileMapNode
    }
    
    // Initialize game when view loads
    override func didMove(to view: SKView) {
//        addPiece(2, 2, 0)
        setBlurb("Ready!")
        readyForInput = true
    }
    
    // MARK: Adding and removing pieces
    func addPiece(_ row: Int, _ column: Int, _ player: Int) {
        let board = gameBoard()
        let man = createPiece(0)
        man.position = board.centerOfTile(atColumn: column, row: row)
        board.addChild(man)
    }
    
    func createPiece(_ player: Int) -> SKSpriteNode {
        let images = ["WhiteK.png", "BlackK.png"]
        var size = CGSize()
        size.width = 78
        size.height = 78
        let man = SKSpriteNode(imageNamed: images[player])
        man.size = size
        man.name = "man"
        man.userData = NSMutableDictionary()
        man.userData!["playerId"] = player
        return man
    }
    
    // MARK: Get touch input
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if  touch != nil && readyForInput {
            let node = interpret(touch!)
            if let name = node.name {
                // Piece touched
                if name == "man" {
                    let piece = node as! SKSpriteNode
                    if activePiece == piece {
                        deactivatePiece(piece)
                    }
                    activatePiece(piece)
                }
                // Empty board space touched
                if name == "hexBoard" {
                    let board = node as! SKTileMapNode
                    if activePiece != nil {
                        touchBoard(touch!, board)
//                        makeMove(touch!, board, activePiece!)
                    }
                }
            }
        }
    }
    
    // Return node being touched
    func interpret(_ touch: UITouch) -> SKNode {
        let pos = touch.location(in: self)
        let selectedNode = self.atPoint(pos)
        return selectedNode
    }
    
    func activatePiece(_ piece: SKSpriteNode) {
        if activePiece != nil {
            deactivatePiece(activePiece!)
        }
        activePiece = piece
        let location = boardLocation(piece)
        let moves = gameDelegate?.legalMoves(location)
        if moves!.count > 0 {
            for m in moves! {
                recolor(m.y, m.x, 0)
            }
        }
        else { setBlurb("No moves!")}
        highlight(piece)
    }
    
    func deactivatePiece(_ piece: SKSpriteNode) {
        unhighlightBoard()
        activePiece = nil
        unHighlight(piece)
    }
    
    func highlight(_ piece: SKSpriteNode) {
        piece.color = UIColor.red
        piece.colorBlendFactor = 0.5
    }
    
    func unHighlight(_ piece: SKSpriteNode) {
        piece.color = UIColor.white
        piece.colorBlendFactor = 0.0
    }
    
    func recolor(_ row: Int, _ column: Int, _ color: Int) {
        let board = gameBoard()
        board.setTileGroup(tileSet?.tileGroups[color], forColumn: column, row: row)
    }
    
    func unhighlightBoard() {
        for row in 0..<4 {
            for column in 0..<4 {
                recolor(row, column, 1)
                // do something to the SKTileDefinition
            }
        }
    }
    
    func makeMove(_ touch: UITouch, _ board: SKTileMapNode, _ piece: SKSpriteNode) {
    
    }
    
//    // Piece touched
//    func touchPiece(_ piece: SKSpriteNode) {
//        let blurbNode = childNode(withName: "blurb")
//        if let blurb = blurbNode as? SKLabelNode {
//            if let d = piece.userData {
//                blurb.text = String(describing: d["playerId"]!)
//            }
//        }
//        piece.removeFromParent()
//    }
    
    // Get space containing specific piece on board
    func boardLocation(_ piece: SKSpriteNode) -> BoardSpace {
        let p = piece.position
        return coordinates(p)
    }
    
    func coordinates(_ p: CGPoint) -> BoardSpace {
        let board = gameBoard()
        let x = board.tileColumnIndex(fromPosition: p)
        let y = board.tileRowIndex(fromPosition: p)
        return BoardSpace(x, y)
    }
    
    // Empty board position touched
    func touchBoard(_ touch: UITouch, _ board: SKTileMapNode) {
        // Get location on board
        let p = touch.location(in: board)
        let b = coordinates(p)
        displayCoordinates(b)
        recolor(b.y, b.x, 0)
    }
    
    // MARK: Display information for testing
    func setBlurb(_ s: String) {
        let blurbNode = childNode(withName: "blurb")
        if let blurb = blurbNode as? SKLabelNode {
            blurb.text = s
        }
    }
    
    func displayCoordinates(_ b: BoardSpace) {
        let column = b.x
        let row = b.y
        let text = String(row) + ", " + String(column)
        setBlurb(text)
    }


    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }

}
