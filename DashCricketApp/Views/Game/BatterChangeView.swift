import SwiftUI

struct BatterChangeView: View {
    @ObservedObject var gameState: GameState
    @Binding var isPresented: Bool
    @State private var selectedBatter: Player?
    
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
            VStack(spacing: 30) {
                Text("Select Next Batter")
                    .font(.title)
                    .fontWeight(.bold)
                
                ForEach(availableBatters, id: \.id) { batter in
                    Button(action: {
                        selectedBatter = batter
                        // Replace the batter who completed their quota
                        if gameState.onStrike == 0 {
                            gameState.currentBatter1 = batter
                        } else {
                            gameState.currentBatter2 = batter
                        }
                        isPresented = false
                    }) {
                        VStack(alignment: .leading) {
                            Text(batter.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("\(batter.role.rawValue) - \(batter.ballsFaced)/\(batter.ballQuota) balls faced")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Select Batter")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    isPresented = false
                }
            )
        }
    }
}
