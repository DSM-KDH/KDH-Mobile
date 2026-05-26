#if os(watchOS)
import SwiftUI

struct TimerStartButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("시작하기")
                .font(.kdf(.caption1))
                .foregroundStyle(Color.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(isEnabled ? Color.red300 : Color.gray200)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
#endif
