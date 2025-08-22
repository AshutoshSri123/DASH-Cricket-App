import SwiftUI

struct BowlerSelectionView: View {
    @ObservedObject var gameState: GameState
    @State private var selectedBowler: Player?
    
    var bowlingPlayers: [Player] {
        let team = gameState.bowlingTeam == 0 ? gameState.teamA : gameState.teamB
        return team.players.filter { $0.role == .bowler || $0.role == .allRounder }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Select Opening Bowler")
                .font(.title)
                .fontWeight(.bold)
            
            // Display bowling team clearly
            VStack(spacing: 10) {
                Text("Bowling Team:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(gameState.bowlingTeam == 0 ? gameState.teamA.name : gameState.teamB.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            }
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(10)
            
            VStack(alignment: .leading) {
                Text("Select Bowler")
                    .font(.headline)
                
                Picker("Select Bowler", selection: $selectedBowler) {
                    Text("Select Player").tag(nil as Player?)
                    ForEach(bowlingPlayers, id: \.id) { player in
                        Text("\(player.name) (\(player.role.rawValue))").tag(player as Player?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
            
            if selectedBowler != nil {
                NavigationLink(
                    destination: ScorecardView(gameState: gameState),
                    label: {
                        Text("Start Innings")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                )
                .simultaneousGesture(TapGesture().onEnded {
                    gameState.currentBowler = selectedBowler
                })
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Opening Bowler")
    }
}
