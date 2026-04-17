import SwiftUI

struct TodayRoutineView: View {
    @State private var routines: [RoutineItem] = [
        .init(exerciseName: "인터벌 러닝", countText: "2시간 · 3-1-2", isChecked: false),
        .init(exerciseName: "스쿼트", countText: "20회 × 3세트", isChecked: true),
        .init(exerciseName: "플랭크", countText: "1분 × 3세트", isChecked: false)
    ]

    var body: some View {
        VStack {
            HStack {
                Text("오늘의 루틴은?")
                    .font(.kdf(.body4))
                    .foregroundStyle(.gray800)
                    .padding(.leading, 16)

                Spacer()
            }

            ScrollView {
                VStack(spacing: 8) {
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
