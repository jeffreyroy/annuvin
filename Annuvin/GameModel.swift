//
//  GameModel.swift
//  Annuvin
//
//  Created by Jeffrey Roy on 2/4/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//

import Foundation
import GameplayKit


// Minmax strategist
//class AnnuvinStrategist: GKMinmaxStrategist {
//    var max​Look​Ahead​Depth = 20
//}

let totalPieces = 4
let symbols: [Character] = ["-", ".", "X", "O"]
let initialBoard: [String] = [
    "- - O O O",
     "- O . . .",
      ". . . . .",
       ". . . X -",
        "X X X - -"
]

// Convert initial board representation into array of integers
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

// Print text representation of position, for testing purposes
func printBoard(_ position: [String]) {
    for (i, row) in position.enumerated() {
        let initialSpace = Array(repeating: " ", count: i).joined()
        print(initialSpace, terminator:"")
        print(row.replacingOccurrences(of: "-", with: " "))
    }
}

// Game model
class AnnuvinModel: NSObject, GKGameModel {
    let players: [GKGameModelPlayer]?
    var activePlayer: GKGameModelPlayer?
    var piecesLeft: [Int]  // Number of pieces left for each player
    var movingPiece: [Int]?  // Active piece, if one player is mid move
    var movesLeft: Int  // Number of moves left for active piece

    var position: [[Int]]  // Store position as array of piles
    
    // Initialize new game
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
    
    func piecesFor(_ player: GKGameModelPlayer) -> [[Int]] {
        var result: [[Int]] = []
        return result
    }
    
    //  Return list of available moves
    //  Move = [from, to], where from and to are board locations
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        var result: [AnnuvinUpdate] = []
        // Fill this in
        return result
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

// Player model
class AnnuvinPlayer: NSObject, GKGameModelPlayer {
    let playerId: Int
    init(_ p: Int) {
        playerId = p
    }
}

// Update class representing Annuvin move
class AnnuvinUpdate: NSObject, GKGameModelUpdate {
    var value: Int = 0  // Desirability of move
    var from: [Int]
    var to: [Int]
    init(_ f: [Int], _ t: [Int]) {
        from = f
        to = t
    }
    override var description: String { return "From \(from) to \(to)" }
}

