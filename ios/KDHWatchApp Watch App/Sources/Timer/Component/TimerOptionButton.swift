#if os(watchOS)
//
//  TimerOptionButton.swift
//  Runner
//
//  Created by hawon on 5/12/26.
//
import SwiftUI

struct TimerOptionButton: View {
    let title: String
    let backgroundColor: Color
    let arrow: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.kdf(.body5))
                    .foregroundStyle(.gray800)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(arrow)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.gray800)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(backgroundColor)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TimerOptionButton(
        title: "인터벌 타이머",
        backgroundColor: .red50,
        arrow: "arrow1"
    ) {}
}
#endif
