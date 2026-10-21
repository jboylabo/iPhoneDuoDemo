import SwiftUI

struct ContentView: View {
    @State private var hinge: DeviceHinge?

    var body: some View {
        VStack {
            if let hinge {
                switch hinge.status {
                case .closed:
                    Text("Closed")
                case .fullyOpen:
                    Text("Fully Open")
                case .partiallyOpen:
                    Text("Partially Open")
                default:
                    Text("Unknown")
                }

                Text("Angle: \(hinge.angle.degrees, specifier: "%.1f")°")
//            } else {
//                ContentUnavailableView(
//                    "Hinge Unavailable",
//                    systemImage: "rectangle.split.2x1"
//                )
            }
        }
        .onHingeChange { oldContext, newContext in
            hinge = newContext.hinge
        }
    }
}

#Preview {
    ContentView()
}
