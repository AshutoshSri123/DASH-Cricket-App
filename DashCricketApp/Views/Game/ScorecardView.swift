import SwiftUI

struct ScorecardView: View {
    @ObservedObject var gameState: GameState
    @State private var showBowlerSelection = false
    @State private var showBatterSelection = false
    @State private var showByesInput = false
    @State private var byesRuns = ""
    @State private var showCustomInput = false
    @State private var customRuns = ""
    
    var body: some View {
        if gameState.gameCompleted {
            FinalScorecardView(gameState: gameState)
        } else {
            VStack(spacing: 20) {
                // Top Section - Score Display
                HStack {
                    VStack(alignment: .leading) {
                        Text(gameState.teamA.name)
                            .font(.headline)
                            .foregroundColor(.blue)
                        Text("\(gameState.teamA.totalRuns) runs")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("Innings \(gameState.currentInnings.rawValue)")
                            .font(.headline)
                        Text("\(gameState.ballsCompleted)/\(gameState.totalBallsInInnings) balls")
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(gameState.teamB.name)
                            .font(.headline)
                            .foregroundColor(.red)
                        Text("\(gameState.teamB.totalRuns) runs")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Current Batting Team
                Text("Batting: \(gameState.battingTeam == 0 ? gameState.teamA.name : gameState.teamB.name)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(gameState.battingTeam == 0 ? .blue : .red)
                
                // Middle Section - Player Stats
                // Middle Section - Player Stats
                VStack(spacing: 15) {
                    // Current Batters
                    HStack {
                        VStack(alignment: .leading) {
                            Text("On Strike:")
                                .font(.headline)
                            
                            // Get updated batter info from team array
                            let battingTeamPlayers = gameState.battingTeam == 0 ? gameState.teamA.players : gameState.teamB.players
                            let currentBatterId = (gameState.onStrike == 0 ? gameState.currentBatter1?.id : gameState.currentBatter2?.id)
                            
                            if let batterId = currentBatterId,
                               let updatedBatter = battingTeamPlayers.first(where: { $0.id == batterId }) {
                                Text("\(updatedBatter.name)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text("\(updatedBatter.ballsFaced)/\(updatedBatter.ballQuota) balls")
                                    .font(.caption)
                                Text("\(updatedBatter.runsScored) runs")
                                    .font(.caption)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Non-Strike:")
                                .font(.headline)
                            
                            // Get updated non-strike batter info from team array
                            let battingTeamPlayers = gameState.battingTeam == 0 ? gameState.teamA.players : gameState.teamB.players
                            let nonStrikeBatterId = (gameState.onStrike == 1 ? gameState.currentBatter1?.id : gameState.currentBatter2?.id)
                            
                            if let batterId = nonStrikeBatterId,
                               let updatedBatter = battingTeamPlayers.first(where: { $0.id == batterId }) {
                                Text("\(updatedBatter.name)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text("\(updatedBatter.ballsFaced)/\(updatedBatter.ballQuota) balls")
                                    .font(.caption)
                                Text("\(updatedBatter.runsScored) runs")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Current Bowler
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Bowler:")
                                .font(.headline)
                            
                            // Get updated bowler info from team array
                            let bowlingTeamPlayers = gameState.bowlingTeam == 0 ? gameState.teamA.players : gameState.teamB.players
                            
                            if let bowlerId = gameState.currentBowler?.id,
                               let updatedBowler = bowlingTeamPlayers.first(where: { $0.id == bowlerId }) {
                                Text("\(updatedBowler.name)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                Text("Over: \(updatedBowler.ballsInCurrentOver)/5")
                                    .font(.caption)
                                Text("Total: \(updatedBowler.ballsBowled)/\(updatedBowler.bowlingQuota) balls")
                                    .font(.caption)
                                Text("Runs: \(updatedBowler.runsConceded)")
                                    .font(.caption)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                }

                
                // Bottom Section - Ball Event Input
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                    // Scoring buttons
                    ForEach([("Dot", 0), ("1", 1), ("2", 2), ("3", 3), ("4", 4), ("5", 5)], id: \.0) { label, runs in
                        Button(action: {
                            gameState.updateScore(runs: runs)
                            checkForPlayerChanges()
                        }) {
                            Text(label)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 80, height: 50)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    
                    // Boundary buttons
                    ForEach([("10", 10), ("15", 15), ("20", 20), ("25", 25)], id: \.0) { label, runs in
                        Button(action: {
                            gameState.updateScore(runs: runs)
                            checkForPlayerChanges()
                        }) {
                            Text(label)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 80, height: 50)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                    
                    // Special buttons
                    Button(action: {
                        gameState.updateScore(runs: 0, isWicket: true)
                        showBatterSelection = true
                    }) {
                        Text("Wicket\n(-25)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 50)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        gameState.updateScore(runs: 1) // No ball + 1 free hit
                        checkForPlayerChanges()
                    }) {
                        Text("No Ball")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 50)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        gameState.updateScore(runs: 1) // Wide + 1 extra
                        checkForPlayerChanges()
                    }) {
                        Text("Wide")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 50)
                            .background(Color.purple)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showByesInput = true
                    }) {
                        Text("Byes")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 50)
                            .background(Color.brown)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showCustomInput = true
                    }) {
                        Text("Custom")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 50)
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showBowlerSelection) {
                BowlerChangeView(gameState: gameState, isPresented: $showBowlerSelection)
            }
            .sheet(isPresented: $showBatterSelection) {
                BatterChangeView(gameState: gameState, isPresented: $showBatterSelection)
            }
            .alert("Enter Byes Runs", isPresented: $showByesInput) {
                TextField("Runs", text: $byesRuns)
                    .keyboardType(.numberPad)
                Button("OK") {
                    if let runs = Int(byesRuns) {
                        gameState.updateScore(runs: runs, isByes: true)
                        checkForPlayerChanges()
                    }
                    byesRuns = ""
                }
                Button("Cancel", role: .cancel) {
                    byesRuns = ""
                }
            }
            .alert("Enter Custom Runs", isPresented: $showCustomInput) {
                TextField("Runs", text: $customRuns)
                    .keyboardType(.numberPad)
                Button("OK") {
                    if let runs = Int(customRuns) {
                        gameState.updateScore(runs: runs)
                        checkForPlayerChanges()
                    }
                    customRuns = ""
                }
                Button("Cancel", role: .cancel) {
                    customRuns = ""
                }
            }
        }
    }
    
    private func checkForPlayerChanges() {
        // Check if over is complete and need new bowler
        if let bowler = gameState.currentBowler {
            let bowlingTeamPlayers = gameState.battingTeam == 0 ? gameState.teamB.players : gameState.teamA.players
            if let bowlerIndex = bowlingTeamPlayers.firstIndex(where: { $0.id == bowler.id }) {
                let currentBowler = bowlingTeamPlayers[bowlerIndex]
                
                // Show bowler selection only when over is complete
                if currentBowler.ballsInCurrentOver == 0 &&
                   currentBowler.ballsBowled > 0 &&
                   gameState.ballsCompleted < gameState.totalBallsInInnings {
                    showBowlerSelection = true
                }
            }
        }
        
        // Check if current batter's quota is complete
        checkBatterQuotaComplete()
    }

    private func checkBatterQuotaComplete() {
        let battingTeamPlayers = gameState.battingTeam == 0 ? gameState.teamA.players : gameState.teamB.players
        
        // Check on-strike batter
        if let onStrikeBatterId = (gameState.onStrike == 0 ? gameState.currentBatter1?.id : gameState.currentBatter2?.id),
           let onStrikeBatter = battingTeamPlayers.first(where: { $0.id == onStrikeBatterId }),
           onStrikeBatter.ballsFaced >= onStrikeBatter.ballQuota {
            showBatterSelection = true
            return
        }
        
        // Check non-strike batter
        if let nonStrikeBatterId = (gameState.onStrike == 1 ? gameState.currentBatter1?.id : gameState.currentBatter2?.id),
           let nonStrikeBatter = battingTeamPlayers.first(where: { $0.id == nonStrikeBatterId }),
           nonStrikeBatter.ballsFaced >= nonStrikeBatter.ballQuota {
            showBatterSelection = true
            return
        }
    }


}
