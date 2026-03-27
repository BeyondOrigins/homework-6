import SwiftUI

struct RulesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.08, green: 0.10, blue: 0.18)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ruleSection(
                            emoji: "🎯",
                            title: String(localized: "rules_goal_title"),
                            text: String(localized: "rules_goal_text")
                        )
                        ruleSection(
                            emoji: "🎲",
                            title: String(localized: "rules_turns_title"),
                            text: String(localized: "rules_turns_text")
                        )
                        ruleSection(
                            emoji: "🪜",
                            title: String(localized: "rules_ladders_title"),
                            text: String(localized: "rules_ladders_text")
                        )
                        ruleSection(
                            emoji: "🐍",
                            title: String(localized: "rules_snakes_title"),
                            text: String(localized: "rules_snakes_text")
                        )
                        ruleSection(
                            emoji: "🏁",
                            title: String(localized: "rules_winning_title"),
                            text: String(localized: "rules_winning_text")
                        )
                        ruleSection(
                            emoji: "↩️",
                            title: String(localized: "rules_bounce_title"),
                            text: String(localized: "rules_bounce_text")
                        )
                    }
                    .padding(24)
                }
            }
            .navigationTitle("title_rules")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("button_close") { dismiss() }
                        .foregroundColor(.orange)
                }
            }
        }
    }

    private func ruleSection(emoji: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(emoji)
                .font(.title)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}
