//
//  RoutineListCell.swift
//  Runner
//
//  Created by hawon on 4/13/26.
//
import SwiftUI

struct RoutineListCell: View {
    let exerciseName: String
    let countText: String
    let isChecked: Bool
    let onImageTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(isChecked ? "checkBoxOn" : "checkBoxOff")

            VStack(alignment: .leading, spacing: 4) {
                Text(exerciseName)
                    .font(.kdf(.caption1))
                    .foregroundStyle(Color.gray800)

                Text(countText)
                    .font(.kdf(.caption5))
                    .foregroundStyle(Color.gray400)
            }

            Spacer()

            Image(systemName: "arrow.forward")
                .foregroundStyle(Color.red400)
                .onTapGesture {
                    onImageTap()
                }
        }
        .padding(12)
        .background(Color.red50)
        .cornerRadius(20)
    }
}

#Preview {
    RoutineListCell(
        exerciseName: "인터벌 러닝",
        countText: "2시간 · 3-1-2",
        isChecked: false,
        onImageTap: {}
    )
}
