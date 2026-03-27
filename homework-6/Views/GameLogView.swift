import SwiftUI

struct GameLogView: View {
    let log: [GameLogEntry]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.08, green: 0.10, blue: 0.18)
                    .ignoresSafeArea()

                if log.isEmpty {
                    Text("label_no_log")
                        .foregroundColor(.white.opacity(0.4))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(log) { entry in
                                HStack(alignment: .top, spacing: 8) {
                                    Text(entry.playerColor.emoji)
                                        .font(.caption)

                                    Text(entry.message)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))

                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("title_game_log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("button_close") { dismiss() }
                        .foregroundColor(.orange)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
