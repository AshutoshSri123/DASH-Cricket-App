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
    
    func switchTeams() {
        let temp = battingTeam
        battingTeam = bowlingTeam
        bowlingTeam = temp
    }
    
    func nextInnings() {
        ballsCompleted = 0
        
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

    // Add this helper property to check if innings just started
    var isInningsJustStarted: Bool {
        return ballsCompleted == 0 &&
               (currentBatter1 == nil || currentBatter2 == nil || currentBowler == nil)
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
        
        // Deduct runs for wicket
        if isWicket {
            if battingTeam == 0 {
                teamA.totalRuns -= 25
            } else {
                teamB.totalRuns -= 25
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
        
        // Update batter stats
        if let batterIndex = getCurrentBatterIndex() {
            if battingTeam == 0 {
                teamA.players[batterIndex].ballsFaced += 1
                if !isByes {
                    teamA.players[batterIndex].runsScored += runs
                }
            } else {
                teamB.players[batterIndex].ballsFaced += 1
                if !isByes {
                    teamB.players[batterIndex].runsScored += runs
                }
            }
        }
        
        // Determine if strike should change
        var shouldChangeStrike = false
        
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
        
        if shouldChangeStrike {
            onStrike = onStrike == 0 ? 1 : 0
        }
        
        // Check if over is complete
        if let bowlerIndex = getBowlerIndex() {
            let currentBowler = battingTeam == 0 ? teamB.players[bowlerIndex] : teamA.players[bowlerIndex]
            if currentBowler.ballsInCurrentOver >= 5 {
                // Over complete - change strike and reset over
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
