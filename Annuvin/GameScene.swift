//
//  GameScene.swift
//  Annuvin
//
//  Created by Jeffrey Roy on 4/7/17.
//  Copyright © 2017 Jeffrey Roy. All rights reserved.
//

import SpriteKit
import GameplayKit

// Class to represent piece on the board
//class GamePiece {
//    var sprite: SKSpriteNode
//    var location: BoardSpace
//    var playerId: Int
//    var name: String
//    init(_ name: String, _ sprite: SKSpriteNode, playerId: Int, _ location: BoardSpace) {
//        self.name = name
//        self.sprite = sprite
//        self.playerId = playerId
//        self.location = location
//    }
//}

class GameScene: SKScene {
    // Delegate game logic to view controller
    weak var gameDelegate: GameDelegate?
    // Use premade tile set for testing
    let tileSet = SKTileSet(named: "Sample Hexagonal Tile Set")
    let animationDuration = 0.2  // Duration of move animation
    var readyForInput: Bool = false
    var activePiece: SKSpriteNode? = nil
    var pieces: [SKSpriteNode] = []
    
    func gameBoard() -> SKTileMapNode {
        return childNode(withName: "hexBoard") as! SKTileMapNode
    }
    
    func activePlayer() -> Int {
        return gameDelegate!.gameState().activePlayer!.playerId
    }
    
    // Initialize game when view loads
    override func didMove(to view: SKView) {
//        addPiece(2, 2, 0)
        resetBoard()
        setBlurb("Ready!")
        readyForInput = true
    }
    
    // MARK: Add and remove pieces
    func addPiece(_ row: Int, _ column: Int, _ player: Int) {
        let man = createPiece(player)
        centerPieceAt(man, row, column)
        pieces.append(man)
        gameBoard().addChild(man)
    }
    
    func centerPieceAt(_ piece: SKSpriteNode,_ row: Int, _ column: Int) {
        piece.position = gameBoard().centerOfTile(atColumn: column, row: row)
        piece.userData!["location"] = BoardSpace(column, row)
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
    
    func removePiece(_ piece: SKSpriteNode) {
        let i = pieces.index(of: piece)
        if i != nil { pieces.remove(at: i!) }
        piece.removeFromParent()
    }
    
    func resetBoard() {
        unhighlightBoard()
        // loop through pieces array, deleting all sprites
        let sprites = gameBoard().children
        for sprite in sprites {
            let piece = sprite as! SKSpriteNode
            removePiece(piece)
        }
        gameDelegate?.resetGame()
        // Add new sprites
        for playerId in [0,1] {
            let pieceLocations = gameDelegate?.piecesFor(playerId)
            for l in pieceLocations! {
                addPiece(l.y, l.x, playerId)
            }
        }
    }
    
    // MARK:  Highlight moves
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
    
    func highlighted(_ b: BoardSpace) -> Bool {
        let color = gameBoard().tileGroup(atColumn: b.x, row: b.y)
        return color == tileSet?.tileGroups[0]
    }
    
    func unhighlightBoard() {
        for row in 0..<4 {
            for column in 0..<4 {
                let tile = BoardSpace(column, row)
//                if highlighted(tile){ recolor(row, column, 1) }
                recolor(row, column, 1)
            }
        }
    }
    
    // MARK:  Translate touches into board coordinates
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
    
    func pieceAt(_ space: BoardSpace) -> SKSpriteNode? {
        for piece in pieces {
            let location = piece.userData!["location"] as! BoardSpace
            if  location == space { return piece }
        }
        return nil
    }
    
    // MARK: Get touch input
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if  touch != nil && readyForInput {
            let node = interpret(touch!)
            // Check what's been touched
            if let name = node.name {
                // Piece touched
                if name == "man" {
                    let piece = node as! SKSpriteNode
                    touchPiece(piece)
                }
                // Empty board space touched
                if name == "hexBoard" {
                    let board = node as! SKTileMapNode
                    if activePiece != nil {
                        touchBoard(touch!, board)
//                        makeMove(touch!, activePiece!)
                    }
                }
                if name == "button" {
                    let piece = node as! SKSpriteNode
                    piece.color = UIColor.red
                    piece.colorBlendFactor = 0.5
                    resetBoard()
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
    
    func touchPiece(_ piece: SKSpriteNode) {
        let owner = piece.userData!["playerId"] as! Int
        // If player's piece, activate it
        if owner == 0 {
            if activePiece == piece {
                deactivatePiece(piece)
            }
            activatePiece(piece)
        }
        // If ai's piece, treat as an attempt to capture
        else {
            if activePiece != nil {
                let location = boardLocation(piece)
                touchTile(location, piece)
            }
        }
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
    
    // Empty board position touched
    func touchBoard(_ touch: UITouch, _ board: SKTileMapNode) {
        // Get location on board
        let p = touch.location(in: board)
        let b = coordinates(p)
        touchTile(b, nil)
    }
    
    func touchTile(_ b: BoardSpace, _ capturedPiece: SKSpriteNode? ) {
        if highlighted(b) && activePiece != nil {
            unhighlightBoard()
            makeMove(b, activePiece!, capturedPiece)
            // Need to check whether game is won for player
            if activePlayer() == 1 && gameDelegate!.winner() == nil {
                //  Wait until animation is complete
//                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { self.AIMove() }
            }
            self.AIMove()
            let winner = gameDelegate!.winner()
            if  winner != nil {
                win(winner!)
            }
        }
    }
    
    // Get AI moves and make them
    func AIMove() {
        setBlurb("Thinking...")
        readyForInput = false
        // Need to check whether game is won for AI
        while activePlayer() == 1 && gameDelegate!.winner() == nil {
            let move = gameDelegate?.aiMove()
            let piece = pieceAt(move!.from)
            let capturedPiece = pieceAt(move!.to)
            // Need to delay 0.2 sec before making move
            makeMove(move!.to, piece!, capturedPiece)
        }
        setBlurb("Ready!")
        readyForInput = true
    }
    
    func makeMove(_ to: BoardSpace, _ piece: SKSpriteNode, _ capturedPiece: SKSpriteNode? ) {
        // Get coordinates of starting and ending position
        let from = boardLocation(piece)
//        let to = coordinates(touch.location(in: board))
        // Try making the move in the model
        let success = gameDelegate!.movePiece(Move(from, to))
        if success {
            centerPieceAt(piece, to.y, to.x)
//            animateMove(piece, to)
            if capturedPiece != nil {
//                animateCapture(capturedPiece!)
                removePiece(capturedPiece!)
            }
        }
        else {
            setBlurb("Illegal move!")
        }
    }
    
    func animateMove(_ piece: SKSpriteNode, _ to: BoardSpace ) {
        unHighlight(piece)
        piece.userData!["location"] = to
        let destination = gameBoard().centerOfTile(atColumn: to.x, row: to.y)
        let moveAnimation = SKAction.move(to: destination, duration: animationDuration)
        piece.run(moveAnimation)
    }
    
    func animateCapture(_ piece: SKSpriteNode) {
        let fadeAnimation = SKAction.fadeOut(withDuration: animationDuration)
        let shrinkAnimation = SKAction.resize(toWidth: 0.0, height: 0.0, duration: animationDuration)
        piece.run(shrinkAnimation)
        piece.run(fadeAnimation)
    }
    
    // Indicate winner
    func win(_ playerId: Int) {
        let playerNames = ["You", "I"]
        setBlurb(playerNames[playerId] + " win!")
        readyForInput = false
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
