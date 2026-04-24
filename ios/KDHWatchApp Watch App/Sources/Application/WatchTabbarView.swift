import SwiftUI

struct WatchTabbarView: View {
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
