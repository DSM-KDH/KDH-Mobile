import SwiftUI

struct TodayRoutineView: View {
    private let routines: [RoutineItem] = [
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
                            onImageTap: {
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
}

private struct RoutineItem: Identifiable {
    let id = UUID()
    let exerciseName: String
    let countText: String
    let isChecked: Bool
}

#Preview {
    TodayRoutineView()
}
