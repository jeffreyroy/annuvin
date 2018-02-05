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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
           let pos = touch.location(in: self)
            let selectedNode = self.atPoint(pos)
            if let name = selectedNode.name {
                if name == "man" {
                    selectedNode.removeFromParent()
                }
                if name == "hexBoard" {
                    let board = selectedNode as! SKTileMapNode
                    let column = board.tileColumnIndex(fromPosition: pos)
                    let row = board.tileRowIndex(fromPosition: pos)
                    let blurbNode = childNode(withName: "blurb")
                    if let blurb = blurbNode as? SKLabelNode {
                        blurb.text = String(row) + ", " + String(column)
                    }
                    
                }
            }
            var node: SKSpriteNode
            

            // do something with your currentPoint
//            let man = childNode(withName: "man")
//            man?.position = pos
            

        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
