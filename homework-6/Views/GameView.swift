import SwiftUI

// MARK: - Game View

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showLog = false

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.08, green: 0.10, blue: 0.18)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar: current player info
                topBar
                    .padding(.horizontal)
                    .padding(.top, 4)

                // Board
                BoardView(
                    board: viewModel.board,
                    players: viewModel.players,
                    highlightedCells: viewModel.highlightedCells,
                    animatingPlayerID: viewModel.animatingPlayerID
                )
                .padding(8)

                // Dice & controls
                bottomControls
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }

            // Game over overlay
            if viewModel.isGameOver {
                gameOverOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showLog.toggle()
                } label: {
                    Image(systemName: "list.bullet.rectangle")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showLog) {
            GameLogView(log: viewModel.gameLog)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 12) {
            ForEach(viewModel.players) { player in
                PlayerBadge(
                    player: player,
                    isCurrent: player.id == viewModel.currentPlayer.id && !viewModel.isGameOver,
                    isFinished: player.isFinished
                )
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 12) {
            // Current player indicator
            if !viewModel.isGameOver {
                HStack {
                    Text(viewModel.currentPlayer.color.emoji)
                    Text("label_turn \(viewModel.currentPlayer.name)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                }
                .transition(.opacity)
            }

            HStack(spacing: 24) {
                // Dice
                DiceView(
                    value: viewModel.diceValue,
                    isRolling: viewModel.diceIsRolling
                )
                .onTapGesture {
                    viewModel.rollDice()
                }

                // Roll button
                if !viewModel.isGameOver {
                    Button {
                        viewModel.rollDice()
                    } label: {
                        Text("button_roll")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(
                                viewModel.gameState == .waitingToRoll
                                    ? LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [.gray, .gray.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: viewModel.gameState == .waitingToRoll ? .orange.opacity(0.4) : .clear, radius: 8, y: 4)
                    }
                    .disabled(viewModel.gameState != .waitingToRoll)
                    .animation(.easeInOut, value: viewModel.gameState)
                }
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Game Over Overlay

    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("🏆")
                    .font(.system(size: 72))

                Text("label_game_over")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.yellow)

                // Rankings
                VStack(spacing: 8) {
                    ForEach(Array(viewModel.finishedPlayers.enumerated()), id: \.element.id) { index, player in
                        HStack {
                            Text(rankEmoji(index))
                                .font(.title2)
                            Text(player.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Text(player.color.emoji)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(index == 0 ? 0.15 : 0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 32)

                HStack(spacing: 16) {
                    Button {
                        viewModel.showConfetti = false
                        viewModel.restartGame()
                    } label: {
                        Label("button_play_again", systemImage: "arrow.counterclockwise")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        dismiss()
                    } label: {
                        Label("button_menu", systemImage: "house.fill")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.12, green: 0.14, blue: 0.22))
                    .shadow(radius: 30)
            )
            .padding(24)
            .transition(.scale.combined(with: .opacity))
        }
        .animation(.spring(response: 0.5), value: viewModel.isGameOver)
    }

    private func rankEmoji(_ index: Int) -> String {
        switch index {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return "\(index + 1)."
        }
    }
}

// MARK: - Player Badge

struct PlayerBadge: View {
    let player: Player
    let isCurrent: Bool
    let isFinished: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(player.color.emoji)
                .font(.title3)
            Text("\(player.position)")
                .font(.caption2.monospacedDigit().bold())
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isCurrent ? Color.orange.opacity(0.3) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isCurrent ? Color.orange : Color.clear, lineWidth: 2)
                )
        )
        .opacity(isFinished ? 0.5 : 1.0)
        .scaleEffect(isCurrent ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isCurrent)
    }
}
