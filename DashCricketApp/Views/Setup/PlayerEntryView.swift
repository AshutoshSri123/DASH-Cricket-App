import SwiftUI

struct PlayerEntryView: View {
    @ObservedObject var gameState: GameState
        
        // Fix: Create unique Player instances instead of repeating the same one
        @State private var teamAPlayers: [Player] = (0..<10).map { _ in Player(name: "", role: .batter) }
        @State private var teamBPlayers: [Player] = (0..<10).map { _ in Player(name: "", role: .batter) }
        
        @State private var showError = false
        @State private var errorMessage = ""
    
    // Computed properties to check team composition
    private var teamAComposition: (batters: Int, allRounders: Int, bowlers: Int) {
        let batters = teamAPlayers.filter { $0.role == .batter }.count
        let allRounders = teamAPlayers.filter { $0.role == .allRounder }.count
        let bowlers = teamAPlayers.filter { $0.role == .bowler }.count
        return (batters, allRounders, bowlers)
    }
    
    private var teamBComposition: (batters: Int, allRounders: Int, bowlers: Int) {
        let batters = teamBPlayers.filter { $0.role == .batter }.count
        let allRounders = teamBPlayers.filter { $0.role == .allRounder }.count
        let bowlers = teamBPlayers.filter { $0.role == .bowler }.count
        return (batters, allRounders, bowlers)
    }
    
    private var isValidComposition: Bool {
        let teamA = teamAComposition
        let teamB = teamBComposition
        
        let teamAValid = teamA.batters == 4 && teamA.allRounders == 2 && teamA.bowlers == 4
        let teamBValid = teamB.batters == 4 && teamB.allRounders == 2 && teamB.bowlers == 4
        let allNamesEntered = !teamAPlayers.contains { $0.name.isEmpty } && !teamBPlayers.contains { $0.name.isEmpty }
        
        return teamAValid && teamBValid && allNamesEntered
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Enter Players")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Team A Players
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("\(gameState.teamA.name) Players")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        // Team A composition indicator
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Required: 4B, 2AR, 4Bo")
                                .font(.caption)
                                .foregroundColor(.gray)
                            let comp = teamAComposition
                            Text("Current: \(comp.batters)B, \(comp.allRounders)AR, \(comp.bowlers)Bo")
                                .font(.caption)
                                .foregroundColor(comp.batters == 4 && comp.allRounders == 2 && comp.bowlers == 4 ? .green : .red)
                        }
                    }
                    
                    ForEach(0..<10, id: \.self) { index in
                        HStack {
                            TextField("Player \(index + 1) name", text: $teamAPlayers[index].name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Picker("Role", selection: $teamAPlayers[index].role) {
                                ForEach(PlayerRole.allCases, id: \.self) { role in
                                    Text(role.rawValue).tag(role)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 120)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Team B Players
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("\(gameState.teamB.name) Players")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                        
                        Spacer()
                        
                        // Team B composition indicator
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Required: 4B, 2AR, 4Bo")
                                .font(.caption)
                                .foregroundColor(.gray)
                            let comp = teamBComposition
                            Text("Current: \(comp.batters)B, \(comp.allRounders)AR, \(comp.bowlers)Bo")
                                .font(.caption)
                                .foregroundColor(comp.batters == 4 && comp.allRounders == 2 && comp.bowlers == 4 ? .green : .red)
                        }
                    }
                    
                    ForEach(0..<10, id: \.self) { index in
                        HStack {
                            TextField("Player \(index + 1) name", text: $teamBPlayers[index].name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Picker("Role", selection: $teamBPlayers[index].role) {
                                ForEach(PlayerRole.allCases, id: \.self) { role in
                                    Text(role.rawValue).tag(role)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 120)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Validation summary
                if !isValidComposition {
                    VStack(spacing: 5) {
                        Text("Team Composition Requirements:")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Text("Each team needs exactly 4 Batters, 2 All-Rounders, and 4 Bowlers")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.orange)
                        Text("All player names must be entered")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.orange)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
                }
                
                NavigationLink(
                    destination: TossView(gameState: gameState),
                    label: {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(isValidComposition ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                )
                .disabled(!isValidComposition)
                .simultaneousGesture(TapGesture().onEnded {
                    if isValidComposition {
                        gameState.teamA.players = teamAPlayers
                        gameState.teamB.players = teamBPlayers
                    }
                })
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Player Entry")
    }
}
