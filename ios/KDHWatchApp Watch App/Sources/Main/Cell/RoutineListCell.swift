//
//  RoutineListCell.swift
//  Runner
//
//  Created by hawon on 4/13/26.
//
import SwiftUI

struct RoutineListCell: View {
    @State var isChecked: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            Image(isChecked ? "checkBoxOn" : "checkBoxOff")
                .onTapGesture {
                    isChecked = isChecked ? false : true
                }

            VStack(alignment: .leading, spacing: 4) {
                Text("인터벌 러닝")
                    .font(.kdf(.caption1))
                    .foregroundStyle(Color.gray800)

                Text("2시간 · 3-1-2")
                    .font(.kdf(.caption5))
                    .foregroundStyle(Color.gray400)
            }

            Spacer()

            Image(systemName: "arrow.forward")
                .foregroundStyle(Color.red400)
            
        }
        .padding(12)
        .background(Color.red50)
        .cornerRadius(20)
    }
}

#Preview {
    RoutineListCell()
}
