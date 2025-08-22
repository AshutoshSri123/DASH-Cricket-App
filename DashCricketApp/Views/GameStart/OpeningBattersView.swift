import SwiftUI

struct OpeningBattersView: View {
    @ObservedObject var gameState: GameState
    @State private var selectedBatter1: Player?
    @State private var selectedBatter2: Player?
    @State private var onStrike: Int = 0
    
    var battingPlayers: [Player] {
        let team = gameState.battingTeam == 0 ? gameState.teamA : gameState.teamB
        return team.players.filter { $0.role == .batter || $0.role == .allRounder }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Select Opening Batters")
                .font(.title)
                .fontWeight(.bold)
            
            // Display batting team clearly
            VStack(spacing: 10) {
                Text("Batting Team:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(gameState.battingTeam == 0 ? gameState.teamA.name : gameState.teamB.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("First Batter")
                        .font(.headline)
                    
                    Picker("Select First Batter", selection: $selectedBatter1) {
                        Text("Select Player").tag(nil as Player?)
                        ForEach(battingPlayers, id: \.id) { player in
                            Text("\(player.name) (\(player.role.rawValue))").tag(player as Player?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                
                VStack(alignment: .leading) {
                    Text("Second Batter")
                        .font(.headline)
                    
                    Picker("Select Second Batter", selection: $selectedBatter2) {
                        Text("Select Player").tag(nil as Player?)
                        ForEach(battingPlayers.filter { $0.id != selectedBatter1?.id }, id: \.id) { player in
                            Text("\(player.name) (\(player.role.rawValue))").tag(player as Player?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                
                if selectedBatter1 != nil && selectedBatter2 != nil {
                    VStack {
                        Text("Who is on strike?")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                onStrike = 0
                            }) {
                                Text(selectedBatter1?.name ?? "")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 120, height: 50)
                                    .background(onStrike == 0 ? Color.blue : Color.gray)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                onStrike = 1
                            }) {
                                Text(selectedBatter2?.name ?? "")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 120, height: 50)
                                    .background(onStrike == 1 ? Color.blue : Color.gray)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
            }
            .padding()
            
            if selectedBatter1 != nil && selectedBatter2 != nil {
                NavigationLink(
                    destination: BowlerSelectionView(gameState: gameState),
                    label: {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                )
                .simultaneousGesture(TapGesture().onEnded {
                    gameState.currentBatter1 = selectedBatter1
                    gameState.currentBatter2 = selectedBatter2
                    gameState.onStrike = onStrike
                })
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Opening Batters")
    }
}
