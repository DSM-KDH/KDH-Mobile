#if os(watchOS)
import SwiftUI

struct TodayRoutineView: View {
    @EnvironmentObject private var connectivityManager: WatchConnectivityManager

    @State private var workouts: [Workout] = []
    @State private var apiState: RoutineAPIState = .idle

    var body: some View {
        VStack {
            HStack {
                Text("오늘의 루틴은?")
                    .font(.kdf(.body3))
                    .foregroundStyle(.gray800)
                    .padding(.leading, 16)

                Spacer()
            }

            ScrollView {
                VStack(spacing: 8) {
                    contentView
                }
                .padding(.horizontal, 8)
                .padding(.top, 6)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .onAppear {
            Swift.Task {
                await fetchRoutineIfPossible()
            }
        }
        .onChange(of: connectivityManager.isReachable) { _, _ in
            Swift.Task {
                await fetchRoutineIfPossible()
            }
        }
        .onChange(of: connectivityManager.hasAccessToken) { _, _ in
            Swift.Task {
                await fetchRoutineIfPossible()
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if !connectivityManager.isReachable {

            message("iPhone 앱을 실행해주세요")

        } else if connectivityManager.isReachable &&
                    !connectivityManager.hasAccessToken {

            message("iPhone 앱과 연결을 실패했습니다.")

        } else {

            switch apiState {

            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)

            case .failed:
                message("루틴 호출을 실패했습니다")

            case .loaded:
                if workouts.isEmpty {

                    message("오늘은 루틴이 없습니다")

                } else {

                    ForEach(workouts, id: \.exerciseId) { workout in
                        RoutineListCell(
                            exerciseName: workout.exerciseName,
                            countText: workout.repsTime,
                            isChecked: workout.completed,
                            checkButtonTap: {},
                            arrowButtonTap: {}
                        )
                    }
                }
            }
        }
    }

    private func message(_ text: String) -> some View {
        Text(text)
            .font(.kdf(.body5))
            .foregroundStyle(.gray500)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
    }

    @MainActor
    private func fetchRoutineIfPossible() async {
        print("[WatchAPI] fetchRoutineIfPossible called")

        guard connectivityManager.isReachable else {
            apiState = .idle
            workouts = []
            return
        }

        guard
            let accessToken = connectivityManager.accessToken(),
            !accessToken.isEmpty
        else {
            apiState = .idle
            workouts = []
            return
        }

        apiState = .loading

        do {
            let response = try await RoutineService.shared
                .fetchTodayRoutine(accessToken: accessToken)

            workouts = response.workouts
            apiState = .loaded

        } catch {
            print("[WatchAPI] fetchRoutine error: \(error)")

            workouts = []
            apiState = .failed
        }
    }
}

private enum RoutineAPIState {
    case idle
    case loading
    case loaded
    case failed
}

#Preview {
    TodayRoutineView()
}
#endif
