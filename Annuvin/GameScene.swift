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
    // Use premade tile set for testing
    let tileSet = SKTileSet(named: "Sample Hexagonal Tile Set")
    var readyForInput: Bool = true
    var activePiece: SKSpriteNode? = nil
    // Get touch input
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            interpret(touch)
        }
    }
    
    // Figure out what is being touched
    func interpret(_ touch: UITouch) {
        // Find node at touch location
       let pos = touch.location(in: self)
        let selectedNode = self.atPoint(pos)
        if let name = selectedNode.name {
            // Piece touched
            if name == "man" {
                let piece = selectedNode as! SKSpriteNode
                touchPiece(piece)
            }
            // Empty board space touched
            if name == "hexBoard" {
                let board = selectedNode as! SKTileMapNode
                touchBoard(touch, board)
            }
        }
    }
    
    // Piece touched
    func touchPiece(_ piece: SKSpriteNode) {
        let blurbNode = childNode(withName: "blurb")
        if let blurb = blurbNode as? SKLabelNode {
            if let d = piece.userData {
                blurb.text = String(describing: d["playerId"]!)
            }
        }
        piece.removeFromParent()
    }
    
    // Empty board position touched
    func touchBoard(_ touch: UITouch, _ board: SKTileMapNode) {
        // Get location on board
        let p = touch.location(in: board)
        // Get row and column of location
        let column = board.tileColumnIndex(fromPosition: p)
        let row = board.tileRowIndex(fromPosition: p)
        board.setTileGroup(tileSet?.tileGroups[0], forColumn: column, row: row)
        let blurbNode = childNode(withName: "blurb")
        if let blurb = blurbNode as? SKLabelNode {
            blurb.text = String(row) + ", " + String(column)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }

}
