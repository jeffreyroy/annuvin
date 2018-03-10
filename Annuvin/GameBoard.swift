////
////  GameBoard.swift
////  Annuvin
////
////  Created by Jeffrey Roy on 5/1/17.
////  Copyright © 2017 Jeffrey Roy. All rights reserved.
////
//
//// Structure representing a grid-based game board
//import Foundation
//import SpriteKit
//import GameplayKit
//
//// Structure representing of piece from one location to another
//struct GameMove {
//    var from: [Int]?
//    var to: [Int]?
//    var piece: GamePiece?
//    //  Move piece from one space to another
//    init(_ from: [Int], _ to: [Int]) {
//        self.from = from
//        self.to = to
//        piece = nil
//    }
//    //  Drop piece on board
//    init(_ piece: GamePiece, _ to: [Int]) {
//        from = nil
//        self.to = to
//        self.piece = piece
//    }
//    //  Remove piece
//    init(from: [Int]) {
//        self.from = from
//        to = nil
//        piece = nil
//    }
//}
//
////  GamePiece represents a piece on the board
//class GamePiece {
//    var name: String
//    var image: String
//    init(_ name: String, image: String? = nil) {
//        self.name = name
//        //  Default image name is "<name>.png"
//        //  Otherwise, use specified image name
//        self.image = image == nil ? name + ".png" : image!
//    }
//    func legalMoves() -> [GameMove] {
//        // Customize for specific game
//        return []
//    }
//}
//
////  A board position, represented as an array of game pieces
//struct GamePosition {
//    var position: [[GamePiece?]]
//    var columns: Int
//    var rows: Int
//    //  Initialize empty position, using dimensions
//    init(columns: Int, rows: Int) {
//        self.columns = columns
//        self.rows = rows
//        // Initialize empty position
//        let emptyRow = [GamePiece?](repeating: nil, count: columns)
//        self.position = [[GamePiece?]](repeating: emptyRow, count: rows)
//    }
//    //  Initialize from a given position
//    init(position: [[GamePiece?]]) {
//        self.position = position
//        self.rows = position.count
//        self.columns = position[0].count
//    }
//    //  Functions to manipulate pieces
//    mutating func addTo(piece: GamePiece, row: Int, column: Int) {
//        position[row][column] = piece
//    }
//    mutating func clear(row: Int, column: Int) {
//        position[row][column] = nil
//    }
//    mutating func makeMove(_ move: GameMove) {
//        var piece = move.piece
//        if let from = move.from {
//            piece = position[from[0]][from[1]]
//            position[from[0]][from[1]] = nil
//        }
//        if let to = move.to {
//            position[to[0]][to[1]] = piece
//        }
//    }
//}
//
//class GameBoard {
//    //  Position represented as an array of rows, each row an array of game piece optionals (nil means the space is empty)
//    var currentPosition: GamePosition
//    var columns: Int
//    var rows: Int
//    let hex: Bool
//    // Grid of directions in form of [columnIncrement, rowIncrement]
//    var directions: [[Int]]
//    // Initialize board from tile map and (optional) position
//    init(node: SKTileMapNode, position: [[GamePiece?]] = [[GamePiece?]](), hex: Bool = false) {
//        self.hex = hex
//        columns = node.numberOfColumns
//        rows = node.numberOfRows
//        currentPosition = GamePosition(columns: columns, rows: rows)
//        if hex {
//            columns += rows / 2
//            directions = [[1, 0], [-1, 0], [1, -1], [0, -1], [-1, 1], [0, 1]]
//        }
//        else {
//            directions = [[-1, 1], [-1, 0], [-1, -1], [0, 1], [0, -1], [1, 1], [1, 0], [1, -1]]
//        }
//        // Initialize position, checking to make sure it corresponds to tile map
//        if position.count == 0 {
//            // Initialize empty position
//            let emptyRow = [GamePiece?](repeating: nil, count: columns)
//            self.currentPosition.position = [[GamePiece?]](repeating: emptyRow, count: rows)
//        }
//        else if position.count != rows {
//            fatalError("Wrong number of rows!")
//        }
//        else if position[0].count != columns {
//            fatalError("Wrong number of columns!")
//        }
//        else {
//            self.currentPosition.position = position
//        }
//    }
//    
//}
//

