import SwiftUI

struct InitialSetupView: View {
    @State private var teamAName = ""
    @State private var teamBName = ""
    @StateObject private var gameState = GameState()
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Dash Cricket")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text("Setup Teams")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Team A Name")
                        .font(.headline)
                    TextField("Enter Team A name", text: $teamAName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading) {
                    Text("Team B Name")
                        .font(.headline)
                    TextField("Enter Team B name", text: $teamBName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding(.horizontal)
            
            NavigationLink(
                destination: PlayerEntryView(gameState: gameState),
                label: {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(teamAName.isEmpty || teamBName.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
            )
            .disabled(teamAName.isEmpty || teamBName.isEmpty)
            .simultaneousGesture(TapGesture().onEnded {
                if !teamAName.isEmpty && !teamBName.isEmpty {
                    gameState.teamA.name = teamAName
                    gameState.teamB.name = teamBName
                }
            })
            
            Spacer()
        }
        .padding()
        .navigationBarHidden(true)
    }
}
