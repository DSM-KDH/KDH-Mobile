#if os(watchOS)
import SwiftUI

struct TodayRoutineView: View {
    @EnvironmentObject private var connectivityManager: WatchConnectivityManager

    @State private var workouts: [Workout] = []
    @State private var apiState: RoutineAPIState = .idle
    @State private var completionUpdatingIds: Set<Int> = []
    @State private var showTimerSelect = false

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
        .sheet(isPresented: $showTimerSelect) {
            TimerSelectView()
        }
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
                message("iPhone 앱을 실행해주세요")

            case .loaded:
                if workouts.isEmpty {

                    message("오늘은 루틴이 없습니다")

                } else {

                    ForEach(workouts, id: \.exerciseId) { workout in
                        RoutineListCell(
                            exerciseName: workout.exerciseName,
                            countText: workout.repsTime,
                            isChecked: workout.completed,
                            checkButtonTap: {
                                Swift.Task {
                                    await toggleCompletion(workout)
                                }
                            },
                            arrowButtonTap: {
                                showTimerSelect = true
                            }
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

    @MainActor
    private func toggleCompletion(_ workout: Workout) async {
        guard !completionUpdatingIds.contains(workout.exerciseId) else {
            return
        }

        guard
            let accessToken = connectivityManager.accessToken(),
            !accessToken.isEmpty
        else {
            return
        }

        let newCompleted = !workout.completed

        completionUpdatingIds.insert(workout.exerciseId)
        updateLocalWorkoutCompletion(
            exerciseId: workout.exerciseId,
            completed: newCompleted
        )

        do {
            try await RoutineService.shared.updateExerciseCompletion(
                exerciseId: workout.exerciseId,
                completed: newCompleted,
                accessToken: accessToken
            )
        } catch {
            print("[WatchAPI] updateCompletion error: \(error)")
            updateLocalWorkoutCompletion(
                exerciseId: workout.exerciseId,
                completed: workout.completed
            )
        }

        completionUpdatingIds.remove(workout.exerciseId)
    }

    @MainActor
    private func updateLocalWorkoutCompletion(
        exerciseId: Int,
        completed: Bool
    ) {
        workouts = workouts.map { item in
            guard item.exerciseId == exerciseId else { return item }

            return Workout(
                exerciseId: item.exerciseId,
                sectionName: item.sectionName,
                exerciseName: item.exerciseName,
                repsTime: item.repsTime,
                completed: completed
            )
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
