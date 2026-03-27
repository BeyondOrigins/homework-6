import Foundation

// MARK: - Board Cell

enum CellType: Codable, Equatable {
    case normal
    case ladder(destination: Int)
    case snake(destination: Int)
}

struct BoardCell: Identifiable, Codable, Equatable {
    let id: Int          // 1...boardSize
    var cellType: CellType

    var destination: Int? {
        switch cellType {
        case .ladder(let dest), .snake(let dest): return dest
        case .normal: return nil
        }
    }
}

// MARK: - Player

struct Player: Identifiable, Codable, Equatable {
    let id: Int
    var name: String
    var position: Int       // 0 = not started, 1...100 on board
    var color: PlayerColor

    var isFinished: Bool { position >= 100 }
}

enum PlayerColor: String, Codable, CaseIterable, Equatable {
    case red, blue, green, orange, purple, pink

    var emoji: String {
        switch self {
        case .red:    return "🔴"
        case .blue:   return "🔵"
        case .green:  return "🟢"
        case .orange: return "🟠"
        case .purple: return "🟣"
        case .pink:   return "🩷"
        }
    }
}

// MARK: - Game Board

struct GameBoard: Codable, Equatable {
    let size: Int   // total cells (default 100)
    let columns: Int // grid columns (default 10)
    var cells: [BoardCell]

    var rows: Int { size / columns }

    /// Generate a random board with snakes and ladders
    static func generate(
        size: Int = 100,
        columns: Int = 10,
        snakeCount: Int = 8,
        ladderCount: Int = 8
    ) -> GameBoard {
        var cells = (1...size).map { BoardCell(id: $0, cellType: .normal) }

        var usedPositions: Set<Int> = [1, size] // keep start/end clear

        // Place ladders (go UP: start in lower half, end in upper half)
        var placed = 0
        while placed < ladderCount {
            let start = Int.random(in: 2...(size - 11))
            let end = Int.random(in: (start + 5)...(size - 1))
            guard !usedPositions.contains(start),
                  !usedPositions.contains(end) else { continue }
            cells[start - 1].cellType = .ladder(destination: end)
            usedPositions.insert(start)
            usedPositions.insert(end)
            placed += 1
        }

        // Place snakes (go DOWN: start in upper area, end in lower area)
        placed = 0
        while placed < snakeCount {
            let start = Int.random(in: 12...(size - 1))
            let end = Int.random(in: 2...(start - 5))
            guard !usedPositions.contains(start),
                  !usedPositions.contains(end) else { continue }
            cells[start - 1].cellType = .snake(destination: end)
            usedPositions.insert(start)
            usedPositions.insert(end)
            placed += 1
        }

        return GameBoard(size: size, columns: columns, cells: cells)
    }

    /// Convert cell number (1-based) to grid row/col for rendering
    /// Board is rendered bottom-to-top, with zigzag pattern
    func gridPosition(for cellNumber: Int) -> (row: Int, col: Int) {
        let index = cellNumber - 1
        let row = index / columns
        let col: Int
        if row % 2 == 0 {
            col = index % columns
        } else {
            col = columns - 1 - (index % columns)
        }
        // Flip row so row 0 is at bottom
        return (rows - 1 - row, col)
    }
}
