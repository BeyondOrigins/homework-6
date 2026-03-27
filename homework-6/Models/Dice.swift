import Foundation

// MARK: - Dice

struct Dice {
    /// Pseudo-random roll using a seeded generator for reproducibility
    /// Uses Linear Congruential Generator for educational purposes
    private static var seed: UInt64 = UInt64(Date().timeIntervalSince1970 * 1000)

    static func roll() -> Int {
        // LCG parameters (same as glibc)
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        let value = Int((seed >> 33) % 6) + 1
        return value
    }

    /// Reset seed for new game
    static func resetSeed() {
        seed = UInt64(Date().timeIntervalSince1970 * 1000) ^ UInt64.random(in: 0...UInt64.max)
    }
}
