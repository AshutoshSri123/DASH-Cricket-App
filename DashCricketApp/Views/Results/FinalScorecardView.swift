import SwiftUI

struct FinalScorecardView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Match Completed!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text(gameState.matchResult)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.blue)
                
                // Final Scores
                HStack {
                    VStack {
                        Text(gameState.teamA.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text("\(gameState.teamA.totalRuns) runs")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Text("VS")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    VStack {
                        Text(gameState.teamB.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        Text("\(gameState.teamB.totalRuns) runs")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                
                // Team A Batting Stats
                VStack(alignment: .leading, spacing: 15) {
                    Text("\(gameState.teamA.name) - Batting")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    ForEach(gameState.teamA.players.filter { $0.ballsFaced > 0 }, id: \.id) { player in
                        HStack {
                            Text(player.name)
                                .font(.headline)
                            Spacer()
                            Text("\(player.runsScored) runs (\(player.ballsFaced) balls)")
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)
                
                // Team A Bowling Stats
                VStack(alignment: .leading, spacing: 15) {
                    Text("\(gameState.teamA.name) - Bowling")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    ForEach(gameState.teamA.players.filter { $0.ballsBowled > 0 }, id: \.id) { player in
                        HStack {
                            Text(player.name)
                                .font(.headline)
                            Spacer()
                            Text("\(player.runsConceded) runs (\(player.ballsBowled) balls)")
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)
                
                // Team B Batting Stats
                VStack(alignment: .leading, spacing: 15) {
                    Text("\(gameState.teamB.name) - Batting")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    ForEach(gameState.teamB.players.filter { $0.ballsFaced > 0 }, id: \.id) { player in
                        HStack {
                            Text(player.name)
                                .font(.headline)
                            Spacer()
                            Text("\(player.runsScored) runs (\(player.ballsFaced) balls)")
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(15)
                
                // Team B Bowling Stats
                VStack(alignment: .leading, spacing: 15) {
                    Text("\(gameState.teamB.name) - Bowling")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    ForEach(gameState.teamB.players.filter { $0.ballsBowled > 0 }, id: \.id) { player in
                        HStack {
                            Text(player.name)
                                .font(.headline)
                            Spacer()
                            Text("\(player.runsConceded) runs (\(player.ballsBowled) balls)")
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(15)
                
                NavigationLink(
                    destination: InitialSetupView(),
                    label: {
                        Text("Home")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                )
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}
