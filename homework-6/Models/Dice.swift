import Foundation

// MARK: - Dice

struct Dice {
    private static var seed: UInt64 = UInt64(Date().timeIntervalSince1970 * 1000)

    static func roll() -> Int {
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        let value = Int((seed >> 33) % 6) + 1
        return value
    }
    
    static func resetSeed() {
        seed = UInt64(Date().timeIntervalSince1970 * 1000) ^ UInt64.random(in: 0...UInt64.max)
    }
}
