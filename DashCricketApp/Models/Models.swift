import Foundation

enum PlayerRole: String, CaseIterable, Hashable {
    case batter = "Batter"
    case allRounder = "All-Rounder"
    case bowler = "Bowler"
}

struct Player: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var role: PlayerRole
    var ballsFaced: Int = 0
    var ballsBowled: Int = 0
    var runsScored: Int = 0
    var runsConceded: Int = 0
    var oversBowled: Int = 0
    var ballsInCurrentOver: Int = 0
    
    var ballQuota: Int {
        switch role {
        case .batter:
            return 10
        case .allRounder:
            return 5
        case .bowler:
            return 0
        }
    }
    
    var bowlingQuota: Int {
        switch role {
        case .batter:
            return 0
        case .allRounder:
            return 5
        case .bowler:
            return 10
        }
    }
}

struct Team {
    var name: String
    var players: [Player]
    var totalRuns: Int = 0
    
    var batters: [Player] {
        return players.filter { $0.role == .batter }
    }
    
    var allRounders: [Player] {
        return players.filter { $0.role == .allRounder }
    }
    
    var bowlers: [Player] {
        return players.filter { $0.role == .bowler }
    }
}

enum Innings: Int, CaseIterable {
    case first = 1
    case second = 2
    case third = 3
}

class GameState: ObservableObject {
    @Published var teamA = Team(name: "", players: [])
    @Published var teamB = Team(name: "", players: [])
    @Published var currentInnings: Innings = .first
    @Published var battingTeam: Int = 0 // 0 for teamA, 1 for teamB
    @Published var bowlingTeam: Int = 1
    @Published var ballsCompleted: Int = 0
    @Published var currentBatter1: Player?
    @Published var currentBatter2: Player?
    @Published var onStrike: Int = 0 // 0 for batter1, 1 for batter2
    @Published var currentBowler: Player?
    @Published var lastBowler: Player? = nil  // Track who bowled the previous over
    @Published var gameCompleted: Bool = false
    @Published var matchResult: String = ""
    
    var totalBallsInInnings: Int {
        switch currentInnings {
        case .first, .third:
            return 25
        case .second:
            return 50
        }
    }
    
    var battingTeamRef: Team {
        return battingTeam == 0 ? teamA : teamB
    }
    
    var bowlingTeamRef: Team {
        return bowlingTeam == 0 ? teamA : teamB
    }
    
    // Check if innings just started
    var isInningsJustStarted: Bool {
        return ballsCompleted == 0 &&
               (currentBatter1 == nil || currentBatter2 == nil || currentBowler == nil)
    }
    
    // Check if only one batter is left
    var isOnlyOneBatterLeft: Bool {
        let battingTeamPlayers = battingTeam == 0 ? teamA.players : teamB.players
        let availableBatters = battingTeamPlayers.filter { player in
            (player.role == .batter || player.role == .allRounder) &&
            player.ballsFaced < player.ballQuota
        }
        return availableBatters.count == 1
    }
    
    // Get available bowlers (excluding last bowler if they just finished an over)
    var availableBowlers: [Player] {
        let bowlingTeamPlayers = bowlingTeam == 0 ? teamA.players : teamB.players
        return bowlingTeamPlayers.filter { player in
            (player.role == .bowler || player.role == .allRounder) &&
            player.ballsBowled < player.bowlingQuota &&
            player.id != lastBowler?.id  // Can't bowl consecutive overs
        }
    }
    
    // Get available batters
    var availableBatters: [Player] {
        let battingTeamPlayers = battingTeam == 0 ? teamA.players : teamB.players
        return battingTeamPlayers.filter { player in
            (player.role == .batter || player.role == .allRounder) &&
            player.ballsFaced < player.ballQuota &&
            player.id != currentBatter1?.id &&
            player.id != currentBatter2?.id
        }
    }
    
    // Get current on-strike batter with updated stats
    var currentOnStrikeBatter: Player? {
        let battingTeamPlayers = battingTeam == 0 ? teamA.players : teamB.players
        if let id = (onStrike == 0 ? currentBatter1?.id : currentBatter2?.id) {
            return battingTeamPlayers.first { $0.id == id }
        }
        return nil
    }
    
    // Get current non-strike batter with updated stats
    var currentNonStrikeBatter: Player? {
        let battingTeamPlayers = battingTeam == 0 ? teamA.players : teamB.players
        if let id = (onStrike == 1 ? currentBatter1?.id : currentBatter2?.id) {
            return battingTeamPlayers.first { $0.id == id }
        }
        return nil
    }
    
    // Get current active bowler with updated stats
    var currentActiveBowler: Player? {
        let bowlingTeamPlayers = bowlingTeam == 0 ? teamA.players : teamB.players
        if let bowler = currentBowler {
            return bowlingTeamPlayers.first { $0.id == bowler.id }
        }
        return nil
    }
    
    func switchTeams() {
        let temp = battingTeam
        battingTeam = bowlingTeam
        bowlingTeam = temp
    }
    
    func nextInnings() {
        ballsCompleted = 0
        lastBowler = nil  // Reset last bowler for new innings
        
        if currentInnings == .first {
            // First innings complete, start second innings
            currentInnings = .second
            switchTeams()
            // Reset current players for new batting team
            currentBatter1 = nil
            currentBatter2 = nil
            currentBowler = nil
            onStrike = 0
            
        } else if currentInnings == .second {
            // Second innings complete, start third innings
            currentInnings = .third
            switchTeams() // Back to original batting team
            // Reset current players for third innings
            currentBatter1 = nil
            currentBatter2 = nil
            currentBowler = nil
            onStrike = 0
            
        } else {
            // Third innings complete, game over
            gameCompleted = true
            calculateResult()
        }
    }
    
    func calculateResult() {
        if teamA.totalRuns > teamB.totalRuns {
            matchResult = "\(teamA.name) wins by \(teamA.totalRuns - teamB.totalRuns) runs!"
        } else if teamB.totalRuns > teamA.totalRuns {
            matchResult = "\(teamB.name) wins by \(teamB.totalRuns - teamA.totalRuns) runs!"
        } else {
            matchResult = "Match is a tie!"
        }
    }
    
    func updateScore(runs: Int, isWicket: Bool = false, isByes: Bool = false, byesFromRunning: Int = 0) {
        // Add runs to team total
        if battingTeam == 0 {
            teamA.totalRuns += runs
        } else {
            teamB.totalRuns += runs
        }
        
        // Handle wicket
        if isWicket {
            // Deduct 25 runs from team total
            if battingTeam == 0 {
                teamA.totalRuns -= 25
            } else {
                teamB.totalRuns -= 25
            }
            
            // Also deduct 25 runs from the batter's personal stats
            if let batterIndex = getCurrentBatterIndex() {
                if battingTeam == 0 {
                    teamA.players[batterIndex].runsScored -= 25
                } else {
                    teamB.players[batterIndex].runsScored -= 25
                }
            }
        }
        
        // Increment ball count
        ballsCompleted += 1
        
        // Update bowler stats
        if let bowlerIndex = getBowlerIndex() {
            if battingTeam == 0 {
                teamB.players[bowlerIndex].ballsBowled += 1
                teamB.players[bowlerIndex].ballsInCurrentOver += 1
                teamB.players[bowlerIndex].runsConceded += runs
            } else {
                teamA.players[bowlerIndex].ballsBowled += 1
                teamA.players[bowlerIndex].ballsInCurrentOver += 1
                teamA.players[bowlerIndex].runsConceded += runs
            }
        }
        
        // Update batter stats (batter still faces the ball even if wicket)
        if let batterIndex = getCurrentBatterIndex() {
            if battingTeam == 0 {
                teamA.players[batterIndex].ballsFaced += 1
                if !isByes && !isWicket {  // Only add runs if not byes and not wicket
                    teamA.players[batterIndex].runsScored += runs
                }
            } else {
                teamB.players[batterIndex].ballsFaced += 1
                if !isByes && !isWicket {  // Only add runs if not byes and not wicket
                    teamB.players[batterIndex].runsScored += runs
                }
            }
        }
        
        // Determine if strike should change (wickets don't change strike)
        var shouldChangeStrike = false
        
        if !isWicket {  // Strike doesn't change on wicket
            if isByes {
                // For byes, only change strike if running byes are 1 or 3
                if byesFromRunning == 1 || byesFromRunning == 3 {
                    shouldChangeStrike = true
                }
            } else {
                // For normal runs, only change strike for 1 or 3 runs
                if runs == 1 || runs == 3 {
                    shouldChangeStrike = true
                }
            }
        }
        
        if shouldChangeStrike {
            onStrike = onStrike == 0 ? 1 : 0
        }
        
        // Check if over is complete
        if let bowlerIndex = getBowlerIndex() {
            let bowler = battingTeam == 0 ? teamB.players[bowlerIndex] : teamA.players[bowlerIndex]
            if bowler.ballsInCurrentOver >= 5 {
                // Over complete - set last bowler, change strike and reset over
                lastBowler = currentBowler  // Store who just finished bowling
                onStrike = onStrike == 0 ? 1 : 0
                if battingTeam == 0 {
                    teamB.players[bowlerIndex].ballsInCurrentOver = 0
                    teamB.players[bowlerIndex].oversBowled += 1
                } else {
                    teamA.players[bowlerIndex].ballsInCurrentOver = 0
                    teamA.players[bowlerIndex].oversBowled += 1
                }
            }
        }
        
        // Check if innings complete
        if ballsCompleted >= totalBallsInInnings {
            nextInnings()
        }
    }

    
    // Check if a specific runs value is allowed (for single batter rule)
    func isRunsAllowed(_ runs: Int) -> Bool {
        if isOnlyOneBatterLeft {
            // Only allow boundaries (10, 15, 20, 25) and dot ball (0) when only one batter left
            return [0, 10, 15, 20, 25].contains(runs)
        }
        return true
    }
    
    // Check if byes are allowed
    func areBytesAllowed() -> Bool {
        return !isOnlyOneBatterLeft
    }
    
    // Get batter who needs to be replaced (completed quota)
    func getBatterToReplace() -> Player? {
        let battingTeamPlayers = battingTeam == 0 ? teamA.players : teamB.players
        
        // Check current batter 1
        if let batter1 = currentBatter1,
           let player1 = battingTeamPlayers.first(where: { $0.id == batter1.id }),
           player1.ballsFaced >= player1.ballQuota {
            return player1
        }
        
        // Check current batter 2
        if let batter2 = currentBatter2,
           let player2 = battingTeamPlayers.first(where: { $0.id == batter2.id }),
           player2.ballsFaced >= player2.ballQuota {
            return player2
        }
        
        return nil
    }
    
    // Replace batter who completed quota
    func replaceBatter(with newBatter: Player) {
        let battingTeamPlayers = battingTeam == 0 ? teamA.players : teamB.players
        
        // Find and replace the batter who has completed their quota
        if let batter1 = currentBatter1,
           let player1 = battingTeamPlayers.first(where: { $0.id == batter1.id }),
           player1.ballsFaced >= player1.ballQuota {
            currentBatter1 = newBatter
            return
        }
        
        if let batter2 = currentBatter2,
           let player2 = battingTeamPlayers.first(where: { $0.id == batter2.id }),
           player2.ballsFaced >= player2.ballQuota {
            currentBatter2 = newBatter
            return
        }
    }
    
    // Check if any batter needs replacement
    func needsBatterReplacement() -> Bool {
        return getBatterToReplace() != nil && !availableBatters.isEmpty
    }
    
    // Check if bowler change is needed (after over completion)
    func needsBowlerChange() -> Bool {
        guard let currentBowler = currentActiveBowler else { return false }
        return currentBowler.ballsInCurrentOver == 0 &&
               currentBowler.ballsBowled > 0 &&
               ballsCompleted < totalBallsInInnings &&
               !availableBowlers.isEmpty
    }
    
    private func getBowlerIndex() -> Int? {
        guard let bowler = currentBowler else { return nil }
        let bowlingTeamPlayers = battingTeam == 0 ? teamB.players : teamA.players
        return bowlingTeamPlayers.firstIndex { $0.id == bowler.id }
    }
    
    private func getCurrentBatterIndex() -> Int? {
        let currentBatter = onStrike == 0 ? currentBatter1 : currentBatter2
        guard let batter = currentBatter else { return nil }
        let battingTeamPlayers = battingTeam == 0 ? teamA.players : teamB.players
        return battingTeamPlayers.firstIndex { $0.id == batter.id }
    }
}
