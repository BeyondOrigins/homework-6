import Foundation

// MARK: - Game Result (for UserDefaults persistence)

struct GameResult: Codable, Identifiable {
    let id: UUID
    let date: Date
    let players: [PlayerResult]
    let totalTurns: Int

    struct PlayerResult: Codable {
        let name: String
        let color: String      // PlayerColor.rawValue
        let finishPosition: Int // 1st, 2nd, etc.
        let turns: Int
    }
}

// MARK: - Results Storage

class GameResultsStorage {
    private static let key = "game_results"

    static func save(_ result: GameResult) {
        var results = load()
        results.insert(result, at: 0)
        // Keep last 50 games
        if results.count > 50 {
            results = Array(results.prefix(50))
        }
        if let data = try? JSONEncoder().encode(results) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> [GameResult] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let results = try? JSONDecoder().decode([GameResult].self, from: data) else {
            return []
        }
        return results
    }

    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
