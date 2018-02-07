//
//  GameModel.swift
//  Annuvin
//
//  Created by Jeffrey Roy on 2/4/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//

import Foundation
import GameplayKit

/// 1. Structures
// Structure to represent board space using x and y coordinates
struct BoardSpace {
    public var x: Int
    public var y: Int
}

// Vector addition
extension BoardSpace {
    public init(_ x: Int, _ y: Int) {
        self.init(x: x, y: y)
    }
    public static func + (left: BoardSpace, right: BoardSpace) -> BoardSpace {
        return BoardSpace(x: left.x + right.x, y: left.y + right.y)
    }
    public func distance(_ target: BoardSpace) -> Int {
        let yDiff: Int = self.y - target.y
        let xDiff: Int = self.x - target.x
        let a: Int = abs(xDiff + yDiff)
        let b: Int = abs(xDiff)
        let c: Int = abs(yDiff)
        let result: Int = ( a + b + c) / 2
        return result
    }
}

// Structure to represent move from one space to another
struct Move {
    public var from: BoardSpace
    public var to: BoardSpace
}

extension Move {
    public init(_ from: Int, _ to: Int) {
        self.init(from: from, to: to)
    }
}

/// 2 Text display of board (for testing)
let symbols: [Character] = ["-", ".", "X", "O"]
let initialBoard: [String] = [
    "- - O O O",
     "- O . . .",
      ". . . . .",
       ". . . X -",
        "X X X - -"
]

// Convert initial board representation into array of integers
// for use when initializing a new game
// 0 = human
// 1 = computer
// -1 = empty
// -2 = out-of-bounds
func convertBoard() -> [[Int]]{
    let intArray: [[Int]] = initialBoard.map { Array($0.replacingOccurrences(of: " ", with: "")).map
    { symbols.index(of: $0)! - 2 }
    }
    return intArray
}

// Convert board back to string array so it can be displayed
func convertBoardBack(_ intArray: [[Int]]) -> [String] {
    let charArray: [[String]] = intArray.map {
        $0.map {
            String(symbols[$0 + 2])
        }
    }
    return charArray.map { $0.joined(separator: " ") }
}

// Display text representation of position, for testing purposes
func printBoard(_ position: [String]) {
    for (i, row) in position.enumerated() {
        let initialSpace = Array(repeating: " ", count: i).joined()
        print(initialSpace, terminator:"")
        print(row.replacingOccurrences(of: "-", with: " "))
    }
}

/// 3. Game model
class AnnuvinModel: NSObject, GKGameModel {
    let totalPieces = 4
    let players: [GKGameModelPlayer]?
    var activePlayer: GKGameModelPlayer?
    var piecesLeft: [Int]  // Number of pieces left for each player
    var movingPiece: BoardSpace?  // Active piece, if one player is mid move
    var movesLeft: Int  // Number of moves left for active piece

    var position: [[Int]]  // Store board position as 2d array
    
    // Initialize new game state
    init(position: [[Int]], players: [GKGameModelPlayer]?) {
        //        assert(players?.count != 2, "Error:  Exactly two players required.")
        if players?.count != 2 {
            print("Error:  Exactly two players required.")
        }
        self.players = players
        self.position = position
        self.piecesLeft = [totalPieces, totalPieces]
        self.movingPiece = nil
        self.movesLeft = 0
        self.activePlayer = players!.first
    }
    
    //  For NSCopying protocol
    func copy(with zone: NSZone? = nil) -> Any {
        var new = AnnuvinModel(position: position, players: players)
        new.piecesLeft = [totalPieces, totalPieces]
        new.movingPiece = movingPiece
        new.movesLeft = movesLeft
        new.activePlayer = activePlayer
        return new
    }
    
    //  Check whether given player is on the move
    func isActive(_ player: GKGameModelPlayer) -> Bool {
        return activePlayer!.playerId == player.playerId
    }
    
    // Return opponent of player
    func opponent(_ player: GKGameModelPlayer) -> GKGameModelPlayer? {
        return players?[1 - player.playerId]
    }
    
    // Switch active player
    func togglePlayer() {
        activePlayer = opponent(activePlayer!)
    }

    // Get number of pieces for a player
    func numPieces(_ player: GKGameModelPlayer) -> Int {
        return piecesLeft[player.playerId]
    }
    
    // Get list of pieces for a player
    func piecesFor(_ player: GKGameModelPlayer) -> [BoardSpace] {
        var result: [BoardSpace] = []
        // Fill this in
        for (y, row) in position.enumerated() {
            for (x, value) in row.enumerated() {
                if value == player.playerId {
                    result.append( BoardSpace(x, y) )
                }
            }
        }
        return result
    }
    
    //  Return list of available moves
    //  Move = [from, to], where from and to are board locations
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        // Fill this in
    }
    
    func getMoves(for player: GKGameModelPlayer) -> [Move] {
        let p = activePlayer!
        var result: [Move] = []
        let pieces = piecesFor(p)
        if movingPiece != nil {
            result = getPieceMoves(movingPiece!, true)
        }
        else {
            for piece in pieces {
                result += getPieceMoves(piece, false)
            }
        }
        // Fill this in
        return result
    }
    
    func getPieceMoves(_ piece: BoardSpace, _ capturesOnly: Bool) -> [Move] {
        // Fill this in
        return []
    }

    // Get total moves available to player based on number of pieces left
    func totalMoves() -> Int {
        let p = activePlayer!
        return 1 + totalPieces - piecesLeft[p.playerId]
    }
    
    // Heuristic score = difference in number of pieces
    func score(for player: GKGameModelPlayer) -> Int {
        return numPieces(player) - numPieces(opponent(player)!)
    }
    
    
    // Win and loss conditions
    // Player with no pieces left loses
    func isLoss(for player: GKGameModelPlayer) -> Bool {
        return numPieces(player) == 0
    }
    
    func isWin(for player: GKGameModelPlayer) -> Bool {
        return numPieces(opponent(player)!) == 0
    }
    
    //  Make move
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        let move = gameModelUpdate as! AnnuvinUpdate
        // print("Considering \(move)", terminator: "")
        // Fill this in
        togglePlayer()
    }
    
    //  Undo move
    func unapplyGameModelUpdate(_ gameModelUpdate: GKGameModelUpdate) {
        let move = gameModelUpdate as! AnnuvinUpdate
        // Fill this in
        togglePlayer()
    }
    
    //  Copy state from model
    func setGameModel(_ gameModel: GKGameModel) {
        if let model = gameModel as? AnnuvinModel{
            self.position = model.position
            self.activePlayer = model.activePlayer
            self.piecesLeft = model.piecesLeft
            self.movingPiece = model.movingPiece
        }
    }
}

/// 4.  Player model
class AnnuvinPlayer: NSObject, GKGameModelPlayer {
    let playerId: Int
    init(_ p: Int) {
        playerId = p
    }
}

/// 5.  Update class representing Annuvin move
class AnnuvinUpdate: NSObject, GKGameModelUpdate {
    var value: Int = 0  // Desirability of move
    var move: Move
    init(_ m: Move) {
        move = m
    }
    override var description: String { return "From \(move.from.y) \(move.from.x) to \(move.to.y) \(move.to.x)" }
}

