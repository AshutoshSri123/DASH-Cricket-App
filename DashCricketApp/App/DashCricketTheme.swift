import SwiftUI

// MARK: - App Color Palette
struct DashColor {
    static let blue = Color(red: 0.13, green: 0.37, blue: 0.90)
    static let lightBlue = Color(red: 0.54, green: 0.76, blue: 0.98)
    static let green = Color(red: 0.17, green: 0.87, blue: 0.46)
    static let orange = Color(red: 1.00, green: 0.68, blue: 0.19)
    static let red = Color(red: 0.98, green: 0.32, blue: 0.40)
    static let purple = Color(red: 0.58, green: 0.42, blue: 0.93)
    static let pale = Color(red: 0.97, green: 0.97, blue: 1.00)
}

// MARK: - Gradient Backgrounds
extension LinearGradient {
    static let appBackground = LinearGradient(
        gradient: Gradient(colors: [DashColor.blue.opacity(0.4), DashColor.green.opacity(0.3), .white]),
        startPoint: .top, endPoint: .bottom)
}

// MARK: - Button Style
struct DashButtonStyle: ButtonStyle {
    var gradient: LinearGradient = LinearGradient(
        colors: [DashColor.blue, DashColor.green],
        startPoint: .leading, endPoint: .trailing)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(gradient)
            .cornerRadius(14)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .shadow(color: DashColor.blue.opacity(0.18), radius: 8, x: 0, y: 2)
            .foregroundColor(.white)
            .font(.headline)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}
