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
            currentInnings = .second
            switchTeams()
        } else if currentInnings == .second {
            currentInnings = .third
            switchTeams() // Back to original batting team
        } else {
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
    
    func updateScore(runs: Int, isWicket: Bool = false, isByes: Bool = false) {
        if battingTeam == 0 {
            teamA.totalRuns += runs
        } else {
            teamB.totalRuns += runs
        }
        
        if isWicket {
            if battingTeam == 0 {
                teamA.totalRuns -= 25
            } else {
                teamB.totalRuns -= 25
            }
        }
        
        ballsCompleted += 1
        
        // Update current bowler stats
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
        if !isByes {
            if let batterIndex = getCurrentBatterIndex() {
                if battingTeam == 0 {
                    teamA.players[batterIndex].ballsFaced += 1
                    teamA.players[batterIndex].runsScored += runs
                } else {
                    teamB.players[batterIndex].ballsFaced += 1
                    teamB.players[batterIndex].runsScored += runs
                }
            }
        }
        
        // Switch strike for odd runs (including byes)
        if runs % 2 == 1 {
            onStrike = onStrike == 0 ? 1 : 0
        }
        
        // Check if over is complete (5 balls bowled in current over)
        if let bowlerIndex = getBowlerIndex() {
            let bowler = battingTeam == 0 ? teamB.players[bowlerIndex] : teamA.players[bowlerIndex]
            if bowler.ballsInCurrentOver == 5 {
                // Over complete, switch strike and reset over count
                onStrike = onStrike == 0 ? 1 : 0
                if battingTeam == 0 {
                    teamB.players[bowlerIndex].ballsInCurrentOver = 0
                    teamB.players[bowlerIndex].oversBowled += 1
                } else {
                    teamA.players[bowlerIndex].ballsInCurrentOver = 0
                    teamA.players[bowlerIndex].oversBowled += 1
                }
                // Note: Don't set currentBowler to nil here - let the view handle bowler change
            }
        }
        
        // Check if innings is complete
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
