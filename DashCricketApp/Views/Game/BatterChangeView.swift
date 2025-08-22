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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Next Batter")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Current batter has completed their quota")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                
                ForEach(availableBatters, id: \.id) { batter in
                    Button(action: {
                        replaceBatter(with: batter)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(batter.name)
                                    .font(.headline)
                                Text("\(batter.role.rawValue) - \(batter.ballsFaced)/\(batter.ballQuota) balls")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Replace Batter")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func replaceBatter(with newBatter: Player) {
        // Find which batter needs replacement
        let battingTeamPlayers = gameState.battingTeam == 0 ? gameState.teamA.players : gameState.teamB.players
        
        // Check current batter 1
        if let batter1 = gameState.currentBatter1,
           let player1 = battingTeamPlayers.first(where: { $0.id == batter1.id }),
           player1.ballsFaced >= player1.ballQuota {
            gameState.currentBatter1 = newBatter
            isPresented = false
            return
        }
        
        // Check current batter 2
        if let batter2 = gameState.currentBatter2,
           let player2 = battingTeamPlayers.first(where: { $0.id == batter2.id }),
           player2.ballsFaced >= player2.ballQuota {
            gameState.currentBatter2 = newBatter
            isPresented = false
            return
        }
    }
}
