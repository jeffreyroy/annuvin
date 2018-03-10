//
//  GameModel.swift
//  Annuvin
//
//  Created by Jeffrey Roy on 2/4/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//
//  Game state model for GameplayKit minimax algorithm

import Foundation
import GameplayKit

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
        new.piecesLeft = piecesLeft
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
    
    // Convert list of moves into list of model updates
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
        let destinations = getDestinations(player, piece, capturesOnly)
        // Convert destinations into list of moves
        return destinations.map { Move(piece, $0) }

    }
    
    func getDestinations(_ player: GKGameModelPlayer, _ piece: BoardSpace, _ capturesOnly: Bool) -> [BoardSpace] {
        var destinations: [BoardSpace] = []
        // If mid move, check whether piece is the one
        // currently moving; if not, return empty destinations
        if capturesOnly && piece != movingPiece! {
            return []
        }
        // Loop through all spaces on board
        // For testing, allow computer only forward moves
        // until captures start
        // (Normally, "lowerBound" should always be zero
        let forward = min(piece.y + 1, 4)
        let lowerBound = (player.playerId == 1 && piecesLeft[1] == 4) ? forward : 0
        for y in lowerBound...4 {
            let row = position[y]
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
        return destinations
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
        // Check whether move is a capture
        if capture {
            movingPiece = destination
            movesLeft -= piece.distance(destination)
            let moreMoves = getDestinations(activePlayer!, movingPiece!, true)
            // If no more moves available, end move
            if moreMoves.count == 0 {
                endMove()
            }
        }
        else {
            endMove()
        }
    }
    
    func endMove() {
        togglePlayer()
        movingPiece = nil
        movesLeft = totalMoves(activePlayer!)
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

