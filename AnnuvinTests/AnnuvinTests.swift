//
//  AnnuvinTests.swift
//  AnnuvinTests
//
//  Created by Jeffrey Roy on 4/7/17.
//  Copyright © 2017 Jeffrey Roy. All rights reserved.
//

import XCTest
@testable import Annuvin

class AnnuvinTests: XCTestCase {
    var testModel: AnnuvinModel!
    let human = AnnuvinPlayer(0)
    let computer = AnnuvinPlayer(1)
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        // Initialize new game
        let initialPosition: [[Int]] = [[-2, -2, 1, 1, 1], [-2, 1, -1, -1, -1], [-1, -1, -1, -1, -1], [-1, -1, -1, 0, -2], [0, 0, 0, -2, -2]]
        testModel = AnnuvinModel(position: initialPosition, players: [human, computer])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        testModel = nil
    }
    
    func testBoardSpace() {
        let a = BoardSpace(x: 0, y: 4)
        let b = BoardSpace(x: 3, y: 3)
        XCTAssertEqual(a + b, BoardSpace(x: 3, y: 7), "Vectors not added correctly")
        XCTAssertEqual(distance(a, b), 3, "Distance not calculated correctly")

    }
    
    func testActivePlayer() {
        XCTAssertEqual(testModel.activePlayer!.playerId, human.playerId, "Active player id is not human")
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
        XCTAssertEqual(testModel.totalMoves(), 1, "Moves available is not one")
    }
    
    func testPiecesFor() {
        let p = testModel.piecesFor(human)
        XCTAssertTrue(p.contains { $0 == [3, 3] }), "List of human's pieces does not include piece at 3, 3")
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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
