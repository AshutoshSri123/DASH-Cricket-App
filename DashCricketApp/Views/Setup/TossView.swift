import SwiftUI

struct TossView: View {
    @ObservedObject var gameState: GameState
    @State private var tossWinner: Int? = nil
    @State private var tossDecision: String? = nil
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Toss")
                .font(.title)
                .fontWeight(.bold)
            
            // Display team names
            HStack(spacing: 30) {
                VStack {
                    Text(gameState.teamA.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    Text("Team A")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text("VS")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack {
                    Text(gameState.teamB.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    Text("Team B")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            
            Text("Who won the toss?")
                .font(.title2)
            
            HStack(spacing: 20) {
                Button(action: {
                    tossWinner = 0
                    tossDecision = nil // Reset decision when toss winner changes
                }) {
                    Text(gameState.teamA.name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 50)
                        .background(tossWinner == 0 ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    tossWinner = 1
                    tossDecision = nil // Reset decision when toss winner changes
                }) {
                    Text(gameState.teamB.name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 50)
                        .background(tossWinner == 1 ? Color.red : Color.gray)
                        .cornerRadius(10)
                }
            }
            
            if tossWinner != nil {
                Text("What does \(tossWinner == 0 ? gameState.teamA.name : gameState.teamB.name) choose?")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 20) {
                    Button(action: {
                        tossDecision = "Bat"
                        gameState.battingTeam = tossWinner!
                        gameState.bowlingTeam = tossWinner! == 0 ? 1 : 0
                    }) {
                        Text("Bat First")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(tossDecision == "Bat" ? Color.green : Color.gray)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        tossDecision = "Bowl"
                        gameState.bowlingTeam = tossWinner!
                        gameState.battingTeam = tossWinner! == 0 ? 1 : 0
                    }) {
                        Text("Bowl First")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(tossDecision == "Bowl" ? Color.green : Color.gray)
                            .cornerRadius(10)
                    }
                }
            }
            
            if tossDecision != nil {
                VStack(spacing: 10) {
                    Text("Match Setup:")
                        .font(.headline)
                    Text("\(gameState.battingTeam == 0 ? gameState.teamA.name : gameState.teamB.name) will bat first")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Text("\(gameState.bowlingTeam == 0 ? gameState.teamA.name : gameState.teamB.name) will bowl first")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
                
                NavigationLink(
                    destination: OpeningBattersView(gameState: gameState),
                    label: {
                        Text("Start Match")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                )
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Toss")
    }
}
