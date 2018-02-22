//
//  GameData.swift
//  Annuvin
//
//  Created by Jeffrey Roy on 2/17/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//
//  Defines structures for storage of game date

import Foundation

//MARK: Structures
public struct HexBoard {
    public var height: Int
    public var width: Int
    public var data: [[Int]]
}

extension HexBoard {
    public init(_ grid: [[Int]]) {
        let height = grid.count
        let width = (height > 0 ? grid[0].count : 0)
        self.init(height: height, width: width, data: grid)
    }
    // Translate between model and view format
    func rotate(_ row: [Int], _ n: Int) -> [Int] {
        let divider = (n>0 ? row.count-n : -n)
        let firstHalf = row[..<divider]
        let secondHalf = row[divider...]
        return Array(secondHalf) + Array(firstHalf)
    }
    func offset(_ y: Int) -> Int {
        var result = (y * 2 - height) / 2
        result += (result < 0 ? -1 : 1)
        return result / 2
    }
    func transform(_ direction: Int) -> HexBoard {
        var newData: [[Int]] = []
        for (i, row) in data.enumerated() {
            newData.append(rotate(row, offset(i)))
        }
        return HexBoard(newData)
    }
    public func view() -> HexBoard {
        return transform(1)
    }
    public func model() -> HexBoard {
        return transform(-1)
    }
}

// Structure to represent board space using x and y coordinates
public struct BoardSpace {
    let height = 5 // Dimension of Annuvin board
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
    
    public static func != (left: BoardSpace, right: BoardSpace) -> Bool {
        return left.x != right.x || left.y != right.y
    }
    
    // Distance function for hex board
    public func distance(_ target: BoardSpace) -> Int {
        let yDiff: Int = self.y - target.y
        let xDiff: Int = self.x - target.x
        let a: Int = abs(xDiff + yDiff)
        let b: Int = abs(xDiff)
        let c: Int = abs(yDiff)
        let result: Int = ( a + b + c) / 2
        return result
    }
    
    // Translate between model and view format
    func offset(_ row: Int) -> Int {
        var result = (row * 2 - height) / 2
        result += (result < 0 ? -1 : 1)
        return result / 2
    }
    
    public func view() -> BoardSpace {
        let newY = height - 1 - y
        return BoardSpace( x + offset(y), newY )
    }
    
    public func model() -> BoardSpace {
        let newY = height - 1 - y
        return BoardSpace( x - offset(newY), newY )
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

//MARK: Text representation of Annuvin board (for testing)
class BoardDisplay {
    
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
    func initialBoardArray() -> [[Int]]{
        let intArray: [[Int]] = initialBoard.map { Array($0.replacingOccurrences(of: " ", with: "")).map
        { symbols.index(of: $0)! - 2 }
        }
        return intArray
    }
    
    // Convert board back to string array so it can be displayed
    func boardStringArray(_ intArray: [[Int]]) -> [String] {
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
}

