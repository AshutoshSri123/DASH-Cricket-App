import SwiftUI

struct ScorecardView: View {
    @ObservedObject var gameState: GameState
    @State private var showBowlerSelection = false
    @State private var showBatterSelection = false
    @State private var showByesInput = false
    @State private var showCustomInput = false
    @State private var customRuns = ""
    @State private var byesFromRunning = ""
    @State private var byesFromBoundary = ""
    
    var body: some View {
        if gameState.gameCompleted {
            FinalScorecardView(gameState: gameState)
        } else if gameState.isInningsJustStarted {
            InningsSetupView(gameState: gameState)
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
                VStack(spacing: 15) {
                    // Current Batters
                    HStack {
                        VStack(alignment: .leading) {
                            Text("On Strike:")
                                .font(.headline)
                            
                            if let onStrikeBatter = getOnStrikeBatter() {
                                Text("\(onStrikeBatter.name)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text("\(onStrikeBatter.ballsFaced)/\(onStrikeBatter.ballQuota) balls")
                                    .font(.caption)
                                Text("\(onStrikeBatter.runsScored) runs")
                                    .font(.caption)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Non-Strike:")
                                .font(.headline)
                            
                            if let nonStrikeBatter = getNonStrikeBatter() {
                                Text("\(nonStrikeBatter.name)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text("\(nonStrikeBatter.ballsFaced)/\(nonStrikeBatter.ballQuota) balls")
                                    .font(.caption)
                                Text("\(nonStrikeBatter.runsScored) runs")
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
                            
                            if let currentBowler = getCurrentBowler() {
                                Text("\(currentBowler.name)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                Text("Over: \(currentBowler.ballsInCurrentOver)/5")
                                    .font(.caption)
                                Text("Total: \(currentBowler.ballsBowled)/\(currentBowler.bowlingQuota) balls")
                                    .font(.caption)
                                Text("Runs: \(currentBowler.runsConceded)")
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
                        gameState.updateScore(runs: 1)
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
                        gameState.updateScore(runs: 1)
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
            .alert("Enter Byes Details", isPresented: $showByesInput) {
                TextField("Running byes (0-4)", text: $byesFromRunning)
                    .keyboardType(.numberPad)
                TextField("Boundary byes (0 or 4)", text: $byesFromBoundary)
                    .keyboardType(.numberPad)
                Button("Add Byes") {
                    let runningByes = Int(byesFromRunning) ?? 0
                    let boundaryByes = Int(byesFromBoundary) ?? 0
                    let totalByes = runningByes + boundaryByes
                    
                    if totalByes > 0 {
                        gameState.updateScore(runs: totalByes, isByes: true, byesFromRunning: runningByes)
                        checkForPlayerChanges()
                    }
                    
                    byesFromRunning = ""
                    byesFromBoundary = ""
                }
                Button("Cancel", role: .cancel) {
                    byesFromRunning = ""
                    byesFromBoundary = ""
                }
            } message: {
                Text("Enter running byes (1-4) and boundary byes (0 or 4). Strike changes only for 1 or 3 running byes.")
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
    
    // MARK: - Helper Methods for Getting Updated Player Info
    
    private func getOnStrikeBatter() -> Player? {
        let battingTeamPlayers = gameState.battingTeam == 0 ? gameState.teamA.players : gameState.teamB.players
        let currentBatterId = (gameState.onStrike == 0 ? gameState.currentBatter1?.id : gameState.currentBatter2?.id)
        
        if let batterId = currentBatterId {
            return battingTeamPlayers.first { $0.id == batterId }
        }
        return nil
    }
    
    private func getNonStrikeBatter() -> Player? {
        let battingTeamPlayers = gameState.battingTeam == 0 ? gameState.teamA.players : gameState.teamB.players
        let nonStrikeBatterId = (gameState.onStrike == 1 ? gameState.currentBatter1?.id : gameState.currentBatter2?.id)
        
        if let batterId = nonStrikeBatterId {
            return battingTeamPlayers.first { $0.id == batterId }
        }
        return nil
    }
    
    private func getCurrentBowler() -> Player? {
        let bowlingTeamPlayers = gameState.bowlingTeam == 0 ? gameState.teamA.players : gameState.teamB.players
        
        if let bowlerId = gameState.currentBowler?.id {
            return bowlingTeamPlayers.first { $0.id == bowlerId }
        }
        return nil
    }
    
    // MARK: - Player Change Detection
    
    private func checkForPlayerChanges() {
        checkForBowlerChange()
        checkForBatterChange()
    }
    
    private func checkForBowlerChange() {
        guard let currentBowler = getCurrentBowler() else { return }
        
        // Show bowler selection only when over is complete
        if currentBowler.ballsInCurrentOver == 0 &&
           currentBowler.ballsBowled > 0 &&
           gameState.ballsCompleted < gameState.totalBallsInInnings {
            showBowlerSelection = true
        }
    }
    
    private func checkForBatterChange() {
        let battingTeamPlayers = gameState.battingTeam == 0 ? gameState.teamA.players : gameState.teamB.players
        
        // Check if batter 1 has completed their quota
        if let batter1 = gameState.currentBatter1,
           let player1 = battingTeamPlayers.first(where: { $0.id == batter1.id }),
           player1.ballsFaced >= player1.ballQuota {
            showBatterSelection = true
            return
        }
        
        // Check if batter 2 has completed their quota
        if let batter2 = gameState.currentBatter2,
           let player2 = battingTeamPlayers.first(where: { $0.id == batter2.id }),
           player2.ballsFaced >= player2.ballQuota {
            showBatterSelection = true
            return
        }
    }

}
