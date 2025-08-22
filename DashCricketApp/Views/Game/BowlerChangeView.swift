import SwiftUI

struct BowlerChangeView: View {
    @ObservedObject var gameState: GameState
    @Binding var isPresented: Bool
    @State private var selectedBowler: Player?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Select Next Bowler")
                    .font(.title)
                    .fontWeight(.bold)
                
                if let lastBowler = gameState.lastBowler {
                    Text("⚠️ \(lastBowler.name) cannot bowl consecutive overs")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                }
                
                if gameState.availableBowlers.isEmpty {
                    Text("No bowlers available!")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ForEach(gameState.availableBowlers, id: \.id) { bowler in
                        Button(action: {
                            selectedBowler = bowler
                            gameState.currentBowler = bowler
                            isPresented = false
                        }) {
                            VStack(alignment: .leading) {
                                Text(bowler.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                HStack {
                                    Text("\(bowler.role.rawValue)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(bowler.ballsBowled)/\(bowler.bowlingQuota) balls bowled")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("• \(bowler.runsConceded) runs")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
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
