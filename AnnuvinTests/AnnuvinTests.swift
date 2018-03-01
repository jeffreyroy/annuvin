//
//  AnnuvinTests.swift
//  AnnuvinTests
//
//  Created by Jeffrey Roy on 4/7/17.
//  Copyright © 2017 Jeffrey Roy. All rights reserved.
//

import XCTest
import GameplayKit
@testable import Annuvin

class AnnuvinTests: XCTestCase {
    var testModel: AnnuvinModel!
    let human = AnnuvinPlayer(0)
    let computer = AnnuvinPlayer(1)
    let move = Move(BoardSpace(0, 4), BoardSpace(0, 3))
    var testUpdate: AnnuvinUpdate!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        // Initialize new game
        let initialPosition: [[Int]] = [[-2, -2, 1, 1, 1], [-2, 1, -1, -1, -1], [-1, -1, -1, -1, -1], [-1, -1, -1, 0, -2], [0, 0, 0, -2, -2]]
        testModel = AnnuvinModel(position: initialPosition, players: [human, computer])
        testUpdate = AnnuvinUpdate(move)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        testModel = nil
        testUpdate = nil
    }
    
    func testBoardSpace() {
        let a = BoardSpace(x: 0, y: 4)
        let b = BoardSpace(x: 3, y: 3)
        let c = BoardSpace(x: 0, y: 3)
        let d = BoardSpace(x: 1, y: 0)
        var e: BoardSpace

        XCTAssertEqual(a.distance(c), 1, "Distance not calculated correctly")
        XCTAssertEqual(a.distance(b), 3, "Distance not calculated correctly")
        XCTAssertTrue(a.view() == d, "BoardSpace view is incorrect")
        XCTAssertTrue(d.model() == a, "BoardSpace model is incorrect")
        for x in 0...4 {
            for y in 0...4 {
                e = BoardSpace(x, y)
                XCTAssertTrue(e.model().view() == e.view().model(), "Boardspace view() and model() are not commutative")
            }
        }


    }
    
    func testMove() {
        let newMove = Move(BoardSpace(1, 0), BoardSpace(0, 1))
        XCTAssertTrue(move.view() == newMove, "Move view() is not correct")
    }
    
    func testPosition() {
        XCTAssertEqual( testModel.position.count, 5, "Board does not have five rows")
        XCTAssertEqual( testModel.position[0].count, 5, "Board does not have five columns")
        XCTAssertEqual( testModel.position[4][0], 0, "Position at 4, 0 is not the player")
        XCTAssertEqual( testModel.position[3][0], -1, "Position at 3, 0 is not empty")
    }
    
    func testActivePlayer() {
        XCTAssertEqual(testModel.activePlayer!.playerId, human.playerId, "Active player id is not human")
        XCTAssertEqual( human.playerId, 0, "Human player id is not zero")
        XCTAssertTrue(testModel.isActive(human), "Human is not the active player")
    }
    
    func testOpponent() {
        XCTAssertEqual(testModel.opponent(human)!.playerId, computer.playerId, "Opponent of human is not computer")
    }
    
    func testNumPieces() {
        XCTAssertEqual(testModel.numPieces(human), 4, "Human does not have four pieces")
        XCTAssertEqual(testModel.piecesFor(human).count, 4, "List of human's pieces does not include four pieces")
    }
    
    func testTotalMoves() {
        XCTAssertEqual(testModel.totalMoves(human), 1, "Moves available is not one")
    }
    
    
    func testPiecesFor() {
        let p = testModel.piecesFor(human)
        XCTAssertTrue(p.contains { $0 == BoardSpace(3, 3) }, "List of human's pieces does not include piece at 3, 3")
    }
    
    func testHeuristic() {
        XCTAssertEqual(testModel.score(for: human), 0, "Score of initial position is not zero")
    }
    
    func testToggle() {
        testModel.togglePlayer()
        XCTAssertTrue(testModel.isActive(computer), "Toggle does not switch player to computer")
    }
    
    func testWin() {
        XCTAssertFalse(testModel.isWin(for: human), "Game should not be won in starting position")
        XCTAssertFalse(testModel.isLoss(for: human), "Game should not be lost in starting position")
    }
    
    func testGetMoves() {
        let piece = BoardSpace(3, 3)
        XCTAssertEqual(testModel.getPieceMoves(human, piece, false).count, 3, "Piece at 3, 3 does not have three moves")
        XCTAssertEqual(testModel.getMoves(for: human).count, 8, "Player does not have eight moves")
    }
    
    func testMakeMove() {
        let capture = testModel.movePiece(move)
        XCTAssertFalse(capture, "Move to 3, 0 should not be a capture")
        XCTAssertEqual(testModel.position[3][0], 0, "Player did not complete move to 3, 0")
        XCTAssertEqual(testModel.position[4][0], -1, "Player did not vacate position 4, 0")
    }
    
    func testUpdateModel() {
        let list = testModel.gameModelUpdates(for: human)
//        let move = testUpdate.move
        XCTAssertNotNil(list, "Human has no updates")
//        XCTAssertEqual(list!.count, 8, "Player does not have eight updates")
//        XCTAssertTrue(list!.contains { $0.move == move }, "Human can't move from 4, 0 to 3, 0")
        testModel.apply(testUpdate)
        XCTAssertEqual(testModel.position[3][0], 0, "Player did not complete move to 3, 0")
    }
    
    func testAI() {
        let ai = GKMinmaxStrategist()
        ai.maxLookAheadDepth = 1
        //ai.randomSource = GKARC4RandomSource()
        ai.gameModel = testModel
        let humanMove = ai.bestMoveForActivePlayer() as! AnnuvinUpdate
        XCTAssertNotNil(humanMove, "AI returns no move for human")
        testModel.apply(testUpdate)
        let aiMove = ai.bestMoveForActivePlayer() as! AnnuvinUpdate
        XCTAssertNotNil(aiMove, "AI returns no move for AI")
    }
    
    func testGamePlay() {
        let ai = GKMinmaxStrategist()
        ai.maxLookAheadDepth = 1
        ai.gameModel = testModel
        var count = 0
        while !ai.gameModel!.isWin!(for: ai.gameModel!.activePlayer!) &&  !ai.gameModel!.isLoss!(for: ai.gameModel!.activePlayer!) && count < 30 {
            let aiMove = ai.bestMoveForActivePlayer()
            if aiMove != nil {
                ai.gameModel!.apply(aiMove!)
            }
            count += 1
        }
        XCTAssertTrue(count < 30, "Game not complete in 30 moves")
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        let ai = GKMinmaxStrategist()
        ai.maxLookAheadDepth = 3
        ai.gameModel = testModel
        self.measure {
            // Put the code you want to measure the time of here.
            _ = ai.bestMoveForActivePlayer()
        }
    }
    
}
