import SwiftUI
import Foundation

struct ContentView: View {
    var body: some View {
        NavigationView {
            InitialSetupView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
