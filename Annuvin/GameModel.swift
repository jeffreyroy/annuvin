//
//  GameModel.swift
//  Annuvin
//
//  Created by Jeffrey Roy on 2/4/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//

import Foundation
import GameplayKit

//MARK: Structures
// Structure to represent board space using x and y coordinates
public struct BoardSpace {
    public var x: Int
    public var y: Int
}

// Vector addition
extension BoardSpace {
    public init(_ x: Int, _ y: Int) {
        self.init(x: x, y: y)
    }
//    public static func + (left: BoardSpace, right: BoardSpace) -> BoardSpace {
//        return BoardSpace(x: left.x + right.x, y: left.y + right.y)
//    }
    public static func == (left: BoardSpace, right: BoardSpace) -> Bool {
        return left.x == right.x && left.y == right.y
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
public struct Move {
    public var from: BoardSpace
    public var to: BoardSpace
}

extension Move {
    public init(_ f: BoardSpace, _ t: BoardSpace) {
        self.init(from: f, to: t)
    }
}

//MARK: Text display of board (for testing)
let symbols: [Character] = ["-", ".", "X", "O"]
let initialBoard: [String] = [
    "- - O O O",
     "- O . . .",
      ". . . . .",
       ". . . X -",
        "X X X - -"
]

// Note:  SpriteKit hex grid uses this representation :
//  4    - O O O -
//  3     O . . . -
//  2    . . . . .
//  1     . . . X -
//  0    _ X X X -

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

//MARK: Game model
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
        self.movesLeft = 1
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
        // Loop through board positions
        for (y, row) in position.enumerated() {
            for (x, value) in row.enumerated() {
                // If it's a piece, add it to the list
                if value == player.playerId {
                    result.append( BoardSpace(x, y) )
                }
            }
        }
        return result
    }
    
    // Convert list of moves in to list of model updates
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        // Return nil if game is over
        if isOver(for: player) { return nil }
        let moves: [Move] = getMoves(for: player)
        // Return nil if no moves available
        if moves.isEmpty { return nil }
        // Otherwise, convert moves into model updates
        return moves.map { AnnuvinUpdate($0) }
    }
    
    //  Return list of available moves for a player
    //  Move = [from, to], where from and to are board locations
    func getMoves(for player: GKGameModelPlayer) -> [Move] {
        var result: [Move] = []
        let pieces = piecesFor(player)
        // Check whether player is mid-move
        if movingPiece != nil {
            // If so, continue moving same piece
            result = getPieceMoves(player, movingPiece!, true)
        }
        else {
            // If not, loop through all pieces for that player
            for piece in pieces {
                result += getPieceMoves(player, piece, false)
            }
        }
        return result
    }
    
    // Get list of legal moves for a specific piece
    func getPieceMoves(_ player: GKGameModelPlayer, _ piece: BoardSpace, _ capturesOnly: Bool) -> [Move] {
        var destinations: [BoardSpace] = []
        // Loop through all spaces on board
        for (y, row) in position.enumerated() {
            for (x, value) in row.enumerated() {
                // Check whether destination is in range
                if piece.distance(BoardSpace(x, y)) <= totalMoves(player) {
                    // Check whether destination is legal
                    if (value == opponent(player)!.playerId || (value == -1 && !capturesOnly)) {
                        destinations.append( BoardSpace(x, y) )
                    }
                }
            }
        }
        // Convert destinations into list of moves
        let result = destinations.map { Move(piece, $0) }
        return result
    }

    // Get total moves available to player
    func totalMoves(_ player: GKGameModelPlayer) -> Int {
        // If a piece is currently mid-move, return stored number
        if player.playerId == activePlayer!.playerId && movingPiece != nil {
            return movesLeft
        }
        // Otherwise, return number based on pieces remaining
        return 1 + totalPieces - piecesLeft[player.playerId]
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
    
    func isOver(for player: GKGameModelPlayer) -> Bool {
        return isLoss(for: player) || isWin(for: player)
    }
    
    
    //  Update position to reflect move, return true if capture
    func movePiece(_ move: Move) -> Bool {
        let piece = move.from
        let dest = move.to
        let destValue = position[dest.y][dest.x]
        let pieceValue = position[piece.y][piece.x]
        assert(pieceValue >= 0, "Trying to move non-existent piece!")
        assert(pieceValue != destValue, "Trying to capture own piece!")
        assert(destValue != -2, "Trying to move off the board!")
        // Move the piece
        position[piece.y][piece.x] = -1
        position[dest.y][dest.x] = pieceValue
        // If capture, reduce number of piece by 1
        if( destValue == 0 || destValue == 1 ) {
            piecesLeft[destValue] -= 1
        }
        return destValue != -1
    }

    
    // Apply state update
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        // Get move
        let update = gameModelUpdate as! AnnuvinUpdate
        let move = update.move
        let piece = move.from
        let destination = move.to
        // print("Considering \(move)", terminator: "")
        let capture = movePiece(move)
        // Note:  Need to check whether move is a capture
        if capture {
            movingPiece = destination
            movesLeft -= piece.distance(destination)
        }
        else {
            togglePlayer()
            movingPiece = nil
            movesLeft = totalMoves(activePlayer!)
        }
    }
    
//    //  Undo move
//    func unapplyGameModelUpdate(_ gameModelUpdate: GKGameModelUpdate) {
//        let move = gameModelUpdate as! AnnuvinUpdate
//        // Fill this in
//        togglePlayer()
//    }
    
    //  Copy state from model
    func setGameModel(_ gameModel: GKGameModel) {
        if let model = gameModel as? AnnuvinModel {
            self.position = model.position
            self.activePlayer = model.activePlayer
            self.piecesLeft = model.piecesLeft
            self.movingPiece = model.movingPiece
            self.movesLeft = model.movesLeft
        }
    }
}

//MARK:  Player model
class AnnuvinPlayer: NSObject, GKGameModelPlayer {
    let playerId: Int
    init(_ p: Int) {
        playerId = p
    }
}

//MARK:  Update class representing Annuvin move
class AnnuvinUpdate: NSObject, GKGameModelUpdate {
    var value: Int = 0  // Desirability of move
    var move: Move
    init(_ m: Move) {
        move = m
    }
    // Need function to check whether it's a capture?
    override var description: String { return "From \(move.from.y) \(move.from.x) to \(move.to.y) \(move.to.x)" }
}

