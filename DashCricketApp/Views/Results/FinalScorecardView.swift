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
                    
                    if gameState.teamA.players.filter({ $0.ballsFaced > 0 }).isEmpty {
                        Text("No batting statistics")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        ForEach(gameState.teamA.players.filter { $0.ballsFaced > 0 }, id: \.id) { player in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(player.name)
                                        .font(.headline)
                                    Text("(\(player.role.rawValue))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(player.runsScored) runs")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(player.runsScored < 0 ? .red : .primary)
                                    Text("(\(player.ballsFaced) balls)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(8)
                        }
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
                    
                    if gameState.teamA.players.filter({ $0.ballsBowled > 0 }).isEmpty {
                        Text("No bowling statistics")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        ForEach(gameState.teamA.players.filter { $0.ballsBowled > 0 }, id: \.id) { player in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(player.name)
                                        .font(.headline)
                                    Text("(\(player.role.rawValue))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(player.runsConceded) runs")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text("(\(player.ballsBowled) balls - \(player.oversBowled) overs)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(8)
                        }
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
                    
                    if gameState.teamB.players.filter({ $0.ballsFaced > 0 }).isEmpty {
                        Text("No batting statistics")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        ForEach(gameState.teamB.players.filter { $0.ballsFaced > 0 }, id: \.id) { player in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(player.name)
                                        .font(.headline)
                                    Text("(\(player.role.rawValue))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(player.runsScored) runs")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(player.runsScored < 0 ? .red : .primary)
                                    Text("(\(player.ballsFaced) balls)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(8)
                        }
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
                    
                    if gameState.teamB.players.filter({ $0.ballsBowled > 0 }).isEmpty {
                        Text("No bowling statistics")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        ForEach(gameState.teamB.players.filter { $0.ballsBowled > 0 }, id: \.id) { player in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(player.name)
                                        .font(.headline)
                                    Text("(\(player.role.rawValue))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(player.runsConceded) runs")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text("(\(player.ballsBowled) balls - \(player.oversBowled) overs)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(15)
                
                // Match Summary
                VStack(alignment: .leading, spacing: 10) {
                    Text("Match Summary")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    HStack {
                        Text("Total Innings:")
                        Spacer()
                        Text("3")
                    }
                    
                    HStack {
                        Text("Total Balls:")
                        Spacer()
                        Text("100 (25 + 50 + 25)")
                    }
                    
                    HStack {
                        Text("Boundary Runs:")
                        Spacer()
                        let boundaryRuns = (gameState.teamA.totalRuns + gameState.teamB.totalRuns) -
                        (gameState.teamA.players.compactMap { $0.ballsFaced > 0 ? ($0.runsScored < 10 ? $0.runsScored : 0) : 0 }.reduce(0, +) +
                         gameState.teamB.players.compactMap { $0.ballsFaced > 0 ? ($0.runsScored < 10 ? $0.runsScored : 0) : 0 }.reduce(0, +))
                        Text("\(boundaryRuns)")
                    }
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(15)
                
                // Navigation to Home
                NavigationLink(
                    destination: InitialSetupView(),
                    label: {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Start New Match")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 50)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                )
                .navigationBarBackButtonHidden(true)
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}
