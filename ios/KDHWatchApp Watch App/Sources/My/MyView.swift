//
//  MyView.swift
//  Runner
//
//  Created by hawon on 4/17/26.
//

import SwiftUI

struct MyView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("마이 페이지")
                .font(.kdf(.body3))
                .foregroundStyle(.gray800)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.background)
    }
}

#Preview {
    MyView()
}
