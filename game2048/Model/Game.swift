//
//  Game.swift
//  game2048
//
//  Created by Justin Chen on 3/20/19.
//  Copyright © 2019 Justin Chen. All rights reserved.
//

import Foundation

class Game {
    
    private var state = [Tile]()
    private var gameScore = 0
    private let boardSize: Int
    
    private var prevState: [Tile]?
    private var prevGameScore = 0
    
    init (withSize boardSize: Int = 4) {
        self.boardSize = boardSize
        for i in 0...(boardSize*boardSize) - 1 {
            state.append(Tile(value: 0, row: i/boardSize, col: i%boardSize))
        }
        spawn()
        spawn()
    }
    
    func getBoardSize() -> Int {
        return boardSize
    }
    
    func getScore() -> Int {
        return gameScore
    }
    
    func isGameOver() -> Bool {
        //movesAvailable() isn't very efficient, so want to short-circuit
        return !(tilesAvailable() || movesAvailable())
    }
    
    //Returns true if undo was successful, else false.
    func undo() -> Bool {
        if prevState != nil {
            state = prevState!
            prevState = nil
            gameScore = prevGameScore
            return true
        } else {
            return false
        }
    }
    
    func left() {
        prevState = copyState(state: state)
        prevGameScore = gameScore
        let collapse = collapseBoard(arr: state)
        if collapse != nil {
            state = collapse!
            spawn()
        }
    }
    
    func right() {
        prevState = copyState(state: state)
        prevGameScore = gameScore
        self.reverseBoard()
        let collapse = collapseBoard(arr: state)
        if collapse != nil {
            state = collapse!
            self.reverseBoard()
            spawn()
        } else {
            self.reverseBoard()
        }
    }
    
    func up() {
        prevState = copyState(state: state)
        prevGameScore = gameScore
        self.transposeBoard()
        let collapse = collapseBoard(arr: state)
        if collapse != nil {
            state = collapse!
            self.transposeBoard()
            spawn()
        } else {
            self.transposeBoard()
        }
    }
    
    func down() {
        prevState = copyState(state: state)
        prevGameScore = gameScore
        self.transposeBoard()
        self.reverseBoard()
        let collapse = collapseBoard(arr: state)
        if collapse != nil {
            state = collapse!
            self.reverseBoard()
            self.transposeBoard()
            spawn()
        } else {
            self.reverseBoard()
            self.transposeBoard()
        }
        
    }
    
    func getState() -> [Int] {
        var gameState = [Int]()
        for i in state {
            gameState.append(i.value)
        }
        return gameState
    }
    
    func getTileState() -> [Tile] {
        return state.filter{$0.value > 0}
    }
    
    private func copyState(state: [Tile]) -> [Tile] {
        var ret = [Tile]()
        for tile in state {
            ret.append(Tile(tile: tile))
        }
        return ret
    }
    
    private func tilesAvailable() -> Bool {
        for i in state {
            if i.value == 0 {
                return true
            }
        }
        return false
    }
    
    private func movesAvailable() -> Bool {
        for row in 0...boardSize - 1 {
            for col in 0...boardSize - 1 {
                let tile = state[row*boardSize + col]
                let up = (row - 1)*boardSize + col
                let down = (row + 1)*boardSize + col
                let left = col - 1
                let right = col + 1
                if (up >= 0 && tile.value == state[up].value) {
                    return true
                }
                if (down < boardSize && tile.value == state[down].value) {
                    return true
                }
                if (left >= 0 && tile.value == state[row*boardSize + left].value) {
                    return true
                }
                if (right < boardSize && tile.value == state[row*boardSize + right].value) {
                    return true
                }
            }
        }
        return false
    }
    
    private func spawn() {
        var empty = [Int]()
        for i in 0...state.count - 1 {
            if state[i].value < 1 {
                empty.append(i)
            }
        }
        let rand = Int.random(in: 0...empty.count - 1)
        state[empty[rand]] = Tile(value: 1, row: empty[rand]/boardSize, col: empty[rand]%boardSize)
        gameScore += 2
    }
    
    private func collapse(row: Int, arr : [Tile]) -> [Tile]? {
        let noZero = arr.filter{$0.value != 0}
        var ret = [Tile]()
        
        var i = 0
        while i < noZero.count {
            if (i + 1 < noZero.count && noZero[i].value == noZero[i + 1].value) {
                let curr = noZero[i]
                let mergedWith = noZero[i + 1]
                curr.mergedIdent = mergedWith.ident
                mergedWith.ident += 1
                curr.value += 1
                gameScore += Int(pow(Double(2), Double(curr.value)))
                ret.append(curr)
                i += 1 //Increment i to "skip" the next element in the parameter.
            } else {
                ret.append(noZero[i])
            }
            i += 1
        }
        i = 0
        while (i < ret.count) {
            ret[i].col = i
            i += 1
        }
        
        while (ret.count < self.boardSize) {
            ret.append(Tile(value: 0, row: row, col: ret.count))
        }
        
        var changed = false
        i = 0
        while (i < ret.count) {
            if ret[i].value != arr[i].value {
                changed = true
            }
            i += 1
        }
        
        return changed ? ret : nil
    }
    
    private func collapseBoard(arr: [Tile]) -> [Tile]? {
        var state2d = [[Tile]]()
        for i in 0...boardSize - 1 {
            var row = [Tile]()
            for j in 0...boardSize - 1{
                row.append(arr[i*boardSize + j])
            }
            state2d.append(row)
        }
        
        var newState = [Tile]()
        var changed = false
        for (idx, elem) in state2d.enumerated() {
            let new = collapse(row: idx, arr: elem)
            if new != nil {
                newState += new!
                changed = true
            } else {
                newState += elem
            }
        }
        
        return changed ? newState : nil
    }
    
    private func reverseBoard() {
        var i = 0
        while (i < boardSize) { //Goes row by row
            var j = i*boardSize //Start from left end of the row
            var k = j + boardSize - 1 //Start from right end of the row
            while (j < k) { //Advance until j and k meet each other.
                let temp = state[j]
                state[j] = state[k]
                state[k] = temp
                Tile.swapPos(lhs: state[j], rhs: state[k])
                j += 1
                k -= 1
            }
            i += 1 //Advance row
        }
    }
    
    private func transposeBoard() {
        var ret = [Tile]()
        var i = 0
        while (i < boardSize) { //Go column by column
            var j = 0
            while (j < boardSize) {
                let curr = state[j*boardSize + i]
                curr.swapPos()
                ret.append(curr) //j*size + i goes down a row in a column as "j" increases.
                j += 1
            }
            i += 1
        }
        state = ret
    }
}

class Tile: Equatable {
    
    fileprivate var value: Int
    fileprivate var row: Int
    fileprivate var col: Int
    fileprivate var ident: Int
    fileprivate var mergedIdent: Int?
    
    static private var tileSerial = 0
    
    init(value: Int, row: Int, col: Int) {
        self.ident = Tile.tileSerial
        self.value = value
        self.row = row
        self.col = col
        Tile.tileSerial += 1
    }
    
    init(tile: Tile) {
        self.value = tile.value
        self.row = tile.row
        self.col = tile.col
        self.ident = tile.ident
    }
    
    func getIdent() -> Int {
        return ident
    }
    
    func popMergedIdent() -> Int? {
        if mergedIdent != nil {
            let temp = mergedIdent!
            mergedIdent = nil
            return temp
        } else {
            return nil
        }
    }
    
    func getCoordinates() -> (Int, Int) {
        return (col, row)
    }
    
    func getValue() -> Int {
        return value
    }
    
    fileprivate func swapPos() {
        let temp = self.row
        self.row = self.col
        self.col = temp
    }
    
    fileprivate static func swapPos(lhs: Tile, rhs: Tile) {
        let tempRow = lhs.row
        let tempCol = lhs.col
        lhs.row = rhs.row
        lhs.col = rhs.col
        rhs.row = tempRow
        rhs.col = tempCol
    }
    
    //Conform to Equatable
    static func == (lhs: Tile, rhs: Tile) -> Bool {
        return lhs.ident == rhs.ident
    }
}
