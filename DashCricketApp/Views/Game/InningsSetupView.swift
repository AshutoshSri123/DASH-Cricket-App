import SwiftUI

struct InningsSetupView: View {
    @ObservedObject var gameState: GameState
    @State private var selectedBatter1: Player?
    @State private var selectedBatter2: Player?
    @State private var selectedBowler: Player?
    @State private var onStrike: Int = 0
    @State private var currentStep = 1
    
    var battingPlayers: [Player] {
        let team = gameState.battingTeam == 0 ? gameState.teamA : gameState.teamB
        return team.players.filter { $0.role == .batter || $0.role == .allRounder }
    }
    
    var bowlingPlayers: [Player] {
        let team = gameState.bowlingTeam == 0 ? gameState.teamA : gameState.teamB
        return team.players.filter { $0.role == .bowler || $0.role == .allRounder }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Innings header
            VStack(spacing: 10) {
                Text("Innings \(gameState.currentInnings.rawValue) Setup")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("\(gameState.totalBallsInInnings) balls")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 30) {
                    VStack {
                        Text("Batting:")
                            .font(.headline)
                        Text(gameState.battingTeam == 0 ? gameState.teamA.name : gameState.teamB.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    Text("VS")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack {
                        Text("Bowling:")
                            .font(.headline)
                        Text(gameState.bowlingTeam == 0 ? gameState.teamA.name : gameState.teamB.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            }
            
            if currentStep == 1 {
                // Step 1: Select Batters
                selectBattersView
            } else if currentStep == 2 {
                // Step 2: Select who's on strike
                selectStrikeView
            } else if currentStep == 3 {
                // Step 3: Select Bowler
                selectBowlerView
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
    
    var selectBattersView: some View {
        VStack(spacing: 20) {
            Text("Select Opening Batters")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 15) {
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
            }
            
            if selectedBatter1 != nil && selectedBatter2 != nil {
                Button(action: {
                    currentStep = 2
                }) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    var selectStrikeView: some View {
        VStack(spacing: 20) {
            Text("Who is on strike?")
                .font(.title2)
                .fontWeight(.semibold)
            
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
            
            Button(action: {
                currentStep = 3
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
    
    var selectBowlerView: some View {
        VStack(spacing: 20) {
            Text("Select Opening Bowler")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading) {
                Text("Select Bowler")
                    .font(.headline)
                
                Picker("Select Bowler", selection: $selectedBowler) {
                    Text("Select Player").tag(nil as Player?)
                    ForEach(gameState.availableBowlers, id: \.id) { player in
                        Text("\(player.name) (\(player.role.rawValue))").tag(player as Player?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            if selectedBowler != nil {
                Button(action: {
                    startInnings()
                }) {
                    Text("Start Innings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
        }
    }

    
    private func startInnings() {
        gameState.currentBatter1 = selectedBatter1
        gameState.currentBatter2 = selectedBatter2
        gameState.currentBowler = selectedBowler
        gameState.onStrike = onStrike
    }
}
