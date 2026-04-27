//
//  TimerSelectView.swift
//  Runner
//
//  Created by hawon on 4/24/26.
//

import SwiftUI

struct TimerSelectView: View {
    @State private var selectedMinute: Int = 20
    private let timerOptions = [10, 20, 30, 45]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("타이머 선택")
                .font(.kdf(.body3))
                .foregroundStyle(.gray800)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.background)
    }
}

#Preview {
    TimerSelectView()
}
