import SwiftUI

struct BatterChangeView: View {
    @ObservedObject var gameState: GameState
    @Binding var isPresented: Bool
    
    var availableBatters: [Player] {
        let team = gameState.battingTeam == 0 ? gameState.teamA : gameState.teamB
        return team.players.filter { player in
            (player.role == .batter || player.role == .allRounder) &&
            player.ballsFaced < player.ballQuota &&
            player.id != gameState.currentBatter1?.id &&
            player.id != gameState.currentBatter2?.id
        }
    }
    
    var batterToReplace: String {
        let battingTeamPlayers = gameState.battingTeam == 0 ? gameState.teamA.players : gameState.teamB.players
        
        if let batter1 = gameState.currentBatter1,
           let player1 = battingTeamPlayers.first(where: { $0.id == batter1.id }),
           player1.ballsFaced >= player1.ballQuota {
            return "\(player1.name) - Completed ball quota (\(player1.ballsFaced)/\(player1.ballQuota) balls)"
        }
        
        if let batter2 = gameState.currentBatter2,
           let player2 = battingTeamPlayers.first(where: { $0.id == batter2.id }),
           player2.ballsFaced >= player2.ballQuota {
            return "\(player2.name) - Completed ball quota (\(player2.ballsFaced)/\(player2.ballQuota) balls)"
        }
        
        return "Unknown batter"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Batter Quota Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text("Replace: \(batterToReplace)")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
                
                if availableBatters.isEmpty {
                    // Handle single batter case
                    VStack(spacing: 15) {
                        Text("Only one batter remaining!")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("The remaining batter will continue playing alone for the rest of the innings.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            handleSingleBatterSituation()
                        }) {
                            Text("Continue with Single Batter")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 250, height: 50)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
                } else {
                    Text("Select Next Batter")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ForEach(availableBatters, id: \.id) { batter in
                        Button(action: {
                            replaceBatter(with: batter)
                        }) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(batter.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                HStack {
                                    Text("\(batter.role.rawValue)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(batter.ballsFaced)/\(batter.ballQuota) balls faced")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    Text("• \(batter.runsScored) runs")
                                        .font(.caption)
                                        .foregroundColor(batter.runsScored < 0 ? .red : .green)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Replace Batter")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
    
    private func handleSingleBatterSituation() {
        let battingTeamPlayers = gameState.battingTeam == 0 ? gameState.teamA.players : gameState.teamB.players
        
        // Find the remaining batter (the one who hasn't completed quota)
        let remainingBatter = battingTeamPlayers.first { player in
            (player.role == .batter || player.role == .allRounder) &&
            player.ballsFaced < player.ballQuota &&
            (player.id == gameState.currentBatter1?.id || player.id == gameState.currentBatter2?.id)
        }
        
        if let remaining = remainingBatter {
            // Set the remaining batter as batter1 and on strike
            gameState.currentBatter1 = remaining
            gameState.currentBatter2 = nil
            gameState.onStrike = 0 // Always on strike since they're alone
        }
        
        isPresented = false
    }
    
    private func replaceBatter(with newBatter: Player) {
        let battingTeamPlayers = gameState.battingTeam == 0 ? gameState.teamA.players : gameState.teamB.players
        
        // Find and replace the batter who has completed their quota
        if let batter1 = gameState.currentBatter1,
           let player1 = battingTeamPlayers.first(where: { $0.id == batter1.id }),
           player1.ballsFaced >= player1.ballQuota {
            
            gameState.currentBatter1 = newBatter
            isPresented = false
            return
        }
        
        if let batter2 = gameState.currentBatter2,
           let player2 = battingTeamPlayers.first(where: { $0.id == batter2.id }),
           player2.ballsFaced >= player2.ballQuota {
            
            gameState.currentBatter2 = newBatter
            isPresented = false
            return
        }
    }
}
