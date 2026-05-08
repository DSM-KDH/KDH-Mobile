#if os(watchOS)
import SwiftUI

struct TodayRoutineView: View {
    @EnvironmentObject private var connectivityManager: WatchConnectivityManager
    @State private var routines: [RoutineItem] = []

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
                    VStack {
                        Text(connectivityManager.isReachable ? "iPhone 연결됨" : "iPhone 연결 대기중")
                            .font(.kdf(.body5))
                            .foregroundStyle(.gray500)
                        Spacer()
                        Text(connectivityManager.hasAccessToken ? "토큰 저장됨" : "토큰 수신 대기")
                            .font(.kdf(.body5))
                            .foregroundStyle(connectivityManager.hasAccessToken ? .red400 : .gray500)
                    }
                    .padding(.horizontal, 8)

                    if let errorMessage = connectivityManager.lastErrorMessage {
                        Text(errorMessage)
                            .font(.kdf(.body5))
                            .foregroundStyle(.red400)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                    }

                    if routines.isEmpty && connectivityManager.isReachable {
                        Text("표시할 루틴이 없습니다.")
                            .font(.kdf(.body5))
                            .foregroundStyle(.gray500)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                    } else {
                        ForEach(routines) { routine in
                            RoutineListCell(
                                exerciseName: routine.exerciseName,
                                countText: routine.countText,
                                isChecked: routine.isChecked,
                                checkButtonTap: {
                                    toggleRoutineCheck(id: routine.id)
                                },
                                arrowButtonTap: {
                                    // TODO: 루틴 상세 화면 이동 또는 액션 연결
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 6)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }

    private func toggleRoutineCheck(id: UUID) {
        guard let index = routines.firstIndex(where: { $0.id == id }) else { return }
        routines[index].isChecked.toggle()
    }

}

private struct RoutineItem: Identifiable {
    let id = UUID()
    let exerciseName: String
    let countText: String
    var isChecked: Bool
}

#Preview {
    TodayRoutineView()
}
#endif
