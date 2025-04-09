import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    // MARK: - Private Properties
    
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestions
        case gamesCount
    }
    
    //MARK: - Computed Properties
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let totalCorrect = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        guard totalQuestions > 0 else {
            return 0.0
        }
        let accuracy = Double(totalCorrect) / Double(totalQuestions) * 100
        return accuracy
    }
    
    //MARK: - Methods
    
    func store(correct count: Int, total amount: Int) {
        let currentTotalCorrect = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        let currentTotalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        storage.set(currentTotalCorrect + count, forKey: Keys.totalCorrectAnswers.rawValue)
        storage.set(currentTotalQuestions + amount, forKey: Keys.totalQuestions.rawValue)
        gamesCount += 1
        
        let newGameResult = GameResult(correct: count, total: amount, date: Date())
        if newGameResult.isBetter(than: bestGame) {
            bestGame = newGameResult
        }
    }
}

