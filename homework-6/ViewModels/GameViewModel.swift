import Foundation
import SwiftUI
import Combine

enum GameState: Equatable {
    case waitingToRoll
    case rolling
    case moving
    case snakeOrLadder
    case gameOver
}

struct GameLogEntry: Identifiable {
    let id = UUID()
    let playerName: String
    let playerColor: PlayerColor
    let message: String
    let timestamp: Date = Date()
}

// MARK: - Game ViewModel

@MainActor
class GameViewModel: ObservableObject {
    @Published var board: GameBoard
    @Published var players: [Player]
    @Published var currentPlayerIndex: Int = 0
    @Published var gameState: GameState = .waitingToRoll
    @Published var diceValue: Int = 1
    @Published var diceIsRolling: Bool = false
    @Published var gameLog: [GameLogEntry] = []
    @Published var finishedPlayers: [Player] = []
    @Published var showConfetti: Bool = false
    @Published var animatingPlayerID: Int? = nil
    @Published var highlightedCells: Set<Int> = []

    var currentPlayer: Player {
        players[currentPlayerIndex]
    }

    var isGameOver: Bool {
        gameState == .gameOver
    }

    var allFinished: Bool {
        players.allSatisfy { $0.isFinished }
    }

    init(playerNames: [String]) {
        self.board = GameBoard.generate()
        Dice.resetSeed()

        let colors = PlayerColor.allCases
        self.players = playerNames.enumerated().map { index, name in
            Player(
                id: index,
                name: name,
                position: 0,
                color: colors[index % colors.count]
            )
        }

        addLog(
            playerName: "player",
            color: .green,
            message: String(localized: "log_game_started")
        )
    }

    // MARK: - Roll Dice

    func rollDice() {
        guard gameState == .waitingToRoll else { return }
        guard !currentPlayer.isFinished else {
            advanceToNextPlayer()
            return
        }

        gameState = .rolling
        diceIsRolling = true

        // Animate dice rolling with multiple intermediate values
        let finalValue = Dice.roll()
        let rollDuration = 0.6
        let steps = 8
        let stepInterval = rollDuration / Double(steps)

        for step in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepInterval * Double(step)) {
                self.diceValue = Int.random(in: 1...6)
            }
        }

        // Set final value and move
        DispatchQueue.main.asyncAfter(deadline: .now() + rollDuration) {
            self.diceValue = finalValue
            self.diceIsRolling = false
            self.moveCurrentPlayer(by: finalValue)
        }
    }

    // MARK: - Move Logic

    private func moveCurrentPlayer(by steps: Int) {
        let playerIndex = currentPlayerIndex
        let oldPosition = players[playerIndex].position
        var newPosition = oldPosition + steps

        // If new position exceeds 100, bounce back
        if newPosition > 100 {
            newPosition = 100 - (newPosition - 100)
            addLog(
                playerName: players[playerIndex].name,
                color: players[playerIndex].color,
                message: String(localized: "log_bounce_back \(diceValue)")
            )
        } else {
            addLog(
                playerName: players[playerIndex].name,
                color: players[playerIndex].color,
                message: String(localized: "log_rolled \(diceValue) \(oldPosition) \(newPosition)")
            )
        }

        gameState = .moving
        animatingPlayerID = players[playerIndex].id

        // Animate this hell of a position step by step
        let animSteps = abs(newPosition - oldPosition)
        let direction = newPosition > oldPosition ? 1 : -1

        if animSteps > 0 {
            for step in 1...animSteps {
                let intermediatePos = oldPosition + step * direction
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15 * Double(step)) {
                    withAnimation(.easeInOut(duration: 0.12)) {
                        self.players[playerIndex].position = intermediatePos
                    }
                }
            }
        }

        // After movement animation, check for snake/ladder
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15 * Double(animSteps) + 0.2) {
            self.checkSnakeOrLadder(playerIndex: playerIndex, at: newPosition)
        }
    }

    private func checkSnakeOrLadder(playerIndex: Int, at position: Int) {
        guard position >= 1 && position <= board.size else {
            finishTurn(playerIndex: playerIndex)
            return
        }

        let cell = board.cells[position - 1]
        switch cell.cellType {
        case .ladder(let dest):
            gameState = .snakeOrLadder
            highlightedCells = [position, dest]
            addLog(
                playerName: players[playerIndex].name,
                color: players[playerIndex].color,
                message: String(localized: "log_ladder \(position) \(dest)")
            )
            // Animate climbing (this is so much better than hecking css)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    self.players[playerIndex].position = dest
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.highlightedCells = []
                    self.checkWin(playerIndex: playerIndex)
                }
            }

        case .snake(let dest):
            gameState = .snakeOrLadder
            highlightedCells = [position, dest]
            addLog(
                playerName: players[playerIndex].name,
                color: players[playerIndex].color,
                message: String(localized: "log_snake \(position) \(dest)")
            )
            // Animate sliding down
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    self.players[playerIndex].position = dest
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.highlightedCells = []
                    self.finishTurn(playerIndex: playerIndex)
                }
            }

        case .normal:
            checkWin(playerIndex: playerIndex)
        }
    }

    private func checkWin(playerIndex: Int) {
        if players[playerIndex].position >= 100 {
            finishedPlayers.append(players[playerIndex])
            addLog(
                playerName: players[playerIndex].name,
                color: players[playerIndex].color,
                message: String(localized: "log_finished \(finishedPlayers.count)")
            )

            if finishedPlayers.count == 1 {
                showConfetti = true
            }

            // Check if all players finished
            let activePlayers = players.filter { !$0.isFinished }
            if activePlayers.count <= 1 {
                // Add last remaining player
                if let last = activePlayers.first, !finishedPlayers.contains(where: { $0.id == last.id }) {
                    finishedPlayers.append(last)
                }
                gameState = .gameOver
                saveGameResult()
                return
            }
        }
        finishTurn(playerIndex: playerIndex)
    }

    private func finishTurn(playerIndex: Int) {
        animatingPlayerID = nil
        advanceToNextPlayer()
        gameState = .waitingToRoll
    }

    private func advanceToNextPlayer() {
        var nextIndex = (currentPlayerIndex + 1) % players.count
        var attempts = 0
        while players[nextIndex].isFinished && attempts < players.count {
            nextIndex = (nextIndex + 1) % players.count
            attempts += 1
        }
        currentPlayerIndex = nextIndex
    }

    private func addLog(playerName: String, color: PlayerColor, message: String) {
        let entry = GameLogEntry(playerName: playerName, playerColor: color, message: message)
        gameLog.insert(entry, at: 0)
        if gameLog.count > 100 {
            gameLog = Array(gameLog.prefix(100))
        }
    }

    // MARK: - Save Results

    private func saveGameResult() {
        let playerResults = finishedPlayers.enumerated().map { index, player in
            GameResult.PlayerResult(
                name: player.name,
                color: player.color.rawValue,
                finishPosition: index + 1,
                turns: 0
            )
        }

        let result = GameResult(
            id: UUID(),
            date: Date(),
            players: playerResults,
            totalTurns: gameLog.count
        )

        GameResultsStorage.save(result)
    }

    // MARK: - Restart

    func restartGame() {
        board = GameBoard.generate()
        Dice.resetSeed()

        for i in players.indices {
            players[i].position = 0
        }
        currentPlayerIndex = 0
        gameState = .waitingToRoll
        diceValue = 1
        diceIsRolling = false
        gameLog = []
        finishedPlayers = []
        showConfetti = false
        animatingPlayerID = nil
        highlightedCells = []

        addLog(
            playerName: "player",
            color: .green,
            message: String(localized: "log_game_started")
        )
    }
}
