import SwiftUI

struct HistoryView: View {
    @State private var results: [GameResult] = []
    @State private var showClearConfirm = false

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.10, blue: 0.18)
                .ignoresSafeArea()

            if results.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.2))
                    Text("label_no_history")
                        .foregroundColor(.white.opacity(0.4))
                }
            } else {
                List {
                    ForEach(results) { result in
                        HistoryRow(result: result)
                            .listRowBackground(Color.white.opacity(0.05))
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("title_history")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            if !results.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showClearConfirm = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red.opacity(0.7))
                    }
                }
            }
        }
        .alert("alert_clear_history", isPresented: $showClearConfirm) {
            Button("button_cancel", role: .cancel) { }
            Button("button_clear", role: .destructive) {
                GameResultsStorage.clearAll()
                results = []
            }
        }
        .onAppear {
            results = GameResultsStorage.load()
        }
    }
}

struct HistoryRow: View {
    let result: GameResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(result.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                Text(result.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }

            ForEach(Array(result.players.enumerated()), id: \.offset) { index, player in
                HStack(spacing: 8) {
                    Text(rankEmoji(index))
                        .font(.caption)
                    Text(player.name)
                        .font(.subheadline.weight(index == 0 ? .bold : .regular))
                        .foregroundColor(index == 0 ? .yellow : .white.opacity(0.7))

                    if let color = PlayerColor(rawValue: player.color) {
                        Text(color.emoji)
                            .font(.caption)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func rankEmoji(_ index: Int) -> String {
        switch index {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return "  \(index + 1)."
        }
    }
}
