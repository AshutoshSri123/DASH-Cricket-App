import SwiftUI

struct BowlerChangeView: View {
    @ObservedObject var gameState: GameState
    @Binding var isPresented: Bool
    @State private var selectedBowler: Player?
    
    var availableBowlers: [Player] {
        let team = gameState.bowlingTeam == 0 ? gameState.teamA : gameState.teamB
        return team.players.filter { player in
            (player.role == .bowler || player.role == .allRounder) &&
            player.ballsBowled < player.bowlingQuota
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Select Next Bowler")
                    .font(.title)
                    .fontWeight(.bold)
                
                ForEach(availableBowlers, id: \.id) { bowler in
                    Button(action: {
                        selectedBowler = bowler
                        gameState.currentBowler = bowler
                        isPresented = false
                    }) {
                        VStack(alignment: .leading) {
                            Text(bowler.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("\(bowler.role.rawValue) - \(bowler.ballsBowled)/\(bowler.bowlingQuota) balls bowled")
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
            .navigationTitle("Select Bowler")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    isPresented = false
                }
            )
        }
    }
}
