import SwiftUI

struct MainMenuView: View {
    @State private var playerCount: Int = 2
    @State private var playerNames: [String] = Array(repeating: "", count: 6)
    @State private var navigateToGame = false
    @State private var navigateToHistory = false
    @State private var showingRules = false

    private let minPlayers = 2
    private let maxPlayers = 6

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.16, blue: 0.26),
                        Color(red: 0.08, green: 0.10, blue: 0.18)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        // Title
                        VStack(spacing: 8) {

                            Text("title_snakes_and_ladders")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Text("subtitle_classic_board_game")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 40)

                        // Player count selector
                        VStack(spacing: 12) {
                            Text("label_number_of_players")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))

                            HStack(spacing: 12) {
                                ForEach(minPlayers...maxPlayers, id: \.self) { count in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            playerCount = count
                                        }
                                    } label: {
                                        Text("\(count)")
                                            .font(.title2.bold())
                                            .frame(width: 48, height: 48)
                                            .background(
                                                playerCount == count
                                                    ? Color.orange
                                                    : Color.white.opacity(0.1)
                                            )
                                            .foregroundColor(
                                                playerCount == count ? .white : .white.opacity(0.6)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .scaleEffect(playerCount == count ? 1.1 : 1.0)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)

                        // Player names
                        VStack(spacing: 10) {
                            ForEach(0..<playerCount, id: \.self) { index in
                                let colors = PlayerColor.allCases
                                HStack(spacing: 12) {
                                    Text(colors[index % colors.count].emoji)
                                        .font(.title2)

                                    TextField(
                                        String(localized: "placeholder_player_name \(index + 1)"),
                                        text: $playerNames[index]
                                    )
                                    .textFieldStyle(.plain)
                                    .padding(12)
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                }
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                            }
                        }
                        .padding(.horizontal)
                        .animation(.spring(response: 0.4), value: playerCount)

                        // Start button
                        Button {
                            navigateToGame = true
                        } label: {
                            HStack {
                                Image(systemName: "dice.fill")
                                Text("button_start_game")
                                    .fontWeight(.bold)
                            }
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .orange.opacity(0.4), radius: 12, y: 6)
                        }
                        .padding(.horizontal)

                        // Bottom buttons
                        HStack(spacing: 16) {
                            Button {
                                navigateToHistory = true
                            } label: {
                                Label("button_history", systemImage: "clock.fill")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.08))
                                    .clipShape(Capsule())
                            }

                            Button {
                                showingRules = true
                            } label: {
                                Label("button_rules", systemImage: "book.fill")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.08))
                                    .clipShape(Capsule())
                            }
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToGame) {
                GameView(viewModel: GameViewModel(playerNames: resolvedNames()))
            }
            .navigationDestination(isPresented: $navigateToHistory) {
                HistoryView()
            }
            .sheet(isPresented: $showingRules) {
                RulesView()
            }
        }
    }

    private func resolvedNames() -> [String] {
        (0..<playerCount).map { index in
            let name = playerNames[index].trimmingCharacters(in: .whitespaces)
            return name.isEmpty
                ? String(localized: "default_player_name \(index + 1)")
                : name
        }
    }
}

#Preview {
    MainMenuView()
}
