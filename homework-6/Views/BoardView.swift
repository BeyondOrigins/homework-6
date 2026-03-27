import SwiftUI

struct BoardView: View {
    let board: GameBoard
    let players: [Player]
    let highlightedCells: Set<Int>
    let animatingPlayerID: Int?

    private let columns = 10
    private let rows = 10

    var body: some View {
        GeometryReader { geo in
            let cellSize = min(geo.size.width, geo.size.height) / CGFloat(columns)

            ZStack {
                // Board background
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.15, green: 0.18, blue: 0.28))

                // Grid cells
                ForEach(board.cells) { cell in
                    let pos = board.gridPosition(for: cell.id)
                    let x = CGFloat(pos.col) * cellSize + cellSize / 2
                    let y = CGFloat(pos.row) * cellSize + cellSize / 2

                    CellView(
                        cell: cell,
                        cellSize: cellSize,
                        isHighlighted: highlightedCells.contains(cell.id)
                    )
                    .position(x: x, y: y)
                }

                // Draw snake/ladder connections
                ForEach(board.cells.filter { $0.cellType != .normal }) { cell in
                    if let dest = cell.destination {
                        let startPos = board.gridPosition(for: cell.id)
                        let endPos = board.gridPosition(for: dest)
                        let startPoint = CGPoint(
                            x: CGFloat(startPos.col) * cellSize + cellSize / 2,
                            y: CGFloat(startPos.row) * cellSize + cellSize / 2
                        )
                        let endPoint = CGPoint(
                            x: CGFloat(endPos.col) * cellSize + cellSize / 2,
                            y: CGFloat(endPos.row) * cellSize + cellSize / 2
                        )

                        ConnectionLine(
                            from: startPoint,
                            to: endPoint,
                            isLadder: {
                                if case .ladder = cell.cellType { return true }
                                return false
                            }()
                        )
                    }
                }

                // Player tokens
                ForEach(players.filter { $0.position > 0 }) { player in
                    let pos = board.gridPosition(for: min(player.position, 100))
                    let playersAtPos = players.filter { $0.position == player.position }
                    let indexAtPos = playersAtPos.firstIndex(where: { $0.id == player.id }) ?? 0
                    let offset = tokenOffset(index: indexAtPos, total: playersAtPos.count, cellSize: cellSize)

                    let x = CGFloat(pos.col) * cellSize + cellSize / 2 + offset.x
                    let y = CGFloat(pos.row) * cellSize + cellSize / 2 + offset.y

                    PlayerToken(
                        player: player,
                        size: cellSize * 0.45,
                        isAnimating: animatingPlayerID == player.id
                    )
                    .position(x: x, y: y)
                    .zIndex(animatingPlayerID == player.id ? 10 : 1)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: player.position)
                }
            }
            .frame(width: cellSize * CGFloat(columns), height: cellSize * CGFloat(rows))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func tokenOffset(index: Int, total: Int, cellSize: CGFloat) -> CGPoint {
        guard total > 1 else { return .zero }
        let radius = Double(cellSize) * 0.2
        let angle = (2.0 * Double.pi / Double(total)) * Double(index) - Double.pi / 2.0
        return CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
    }
}

// MARK: - Cell View

struct CellView: View {
    let cell: BoardCell
    let cellSize: CGFloat
    let isHighlighted: Bool

    var body: some View {
        ZStack {
            Rectangle()
                .fill(cellColor)
                .frame(width: cellSize - 1, height: cellSize - 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                )

            if isHighlighted {
                Rectangle()
                    .fill(Color.yellow.opacity(0.3))
                    .frame(width: cellSize - 1, height: cellSize - 1)
                    .overlay(
                        Rectangle()
                            .stroke(Color.yellow, lineWidth: 2)
                    )
            }

            VStack(spacing: 0) {
                Text("\(cell.id)")
                    .font(.system(size: cellSize * 0.22, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))

                if cell.cellType != .normal {
                    Text(cellEmoji)
                        .font(.system(size: cellSize * 0.28))
                }
            }
        }
    }

    private var cellColor: Color {
        switch cell.cellType {
        case .ladder: return Color.green.opacity(0.15)
        case .snake: return Color.red.opacity(0.15)
        case .normal:
            return (cell.id / 10 + cell.id) % 2 == 0
                ? Color(red: 0.18, green: 0.21, blue: 0.32)
                : Color(red: 0.20, green: 0.24, blue: 0.36)
        }
    }

    private var cellEmoji: String {
        switch cell.cellType {
        case .ladder: return "🪜"
        case .snake: return "🐍"
        case .normal: return ""
        }
    }
}

// MARK: - Connection Line

struct ConnectionLine: View {
    let from: CGPoint
    let to: CGPoint
    let isLadder: Bool

    var body: some View {
        Path { path in
            path.move(to: from)
            // Slight curve for visual appeal
            let midX = (from.x + to.x) / 2 + (isLadder ? 8 : -8)
            let midY = (from.y + to.y) / 2
            path.addQuadCurve(to: to, control: CGPoint(x: midX, y: midY))
        }
        .stroke(
            isLadder ? Color.green.opacity(0.5) : Color.red.opacity(0.5),
            style: StrokeStyle(
                lineWidth: 3,
                lineCap: .round,
                dash: isLadder ? [] : [6, 4]
            )
        )
    }
}

// MARK: - Player Token

struct PlayerToken: View {
    let player: Player
    let size: CGFloat
    let isAnimating: Bool

    @State private var bouncing = false

    var body: some View {
        Text(player.color.emoji)
            .font(.system(size: size * 0.7))
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(Color.black.opacity(0.4))
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
            )
            .scaleEffect(isAnimating ? 1.15 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isAnimating)
    }
}
