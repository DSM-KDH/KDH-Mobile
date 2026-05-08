#if os(watchOS)
import SwiftUI

struct WatchTabbarView: View {
    @EnvironmentObject private var connectivityManager: WatchConnectivityManager
    @State private var selectedTab: WatchTab = .todayRoutine

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayRoutineView()
                .tag(WatchTab.todayRoutine)

            TimerSelectView()
                .tag(WatchTab.timer)

            MyView()
                .tag(WatchTab.my)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .onChange(of: selectedTab) { _, newValue in
            guard connectivityManager.isReachable else {
                if newValue != .todayRoutine {
                    selectedTab = .todayRoutine
                }
                return
            }
        }
    }
}

private enum WatchTab: Int {
    case todayRoutine
    case timer
    case my
}

#Preview {
    WatchTabbarView()
}
#endif
