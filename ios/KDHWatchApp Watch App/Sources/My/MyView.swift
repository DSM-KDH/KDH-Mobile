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
            HStack(spacing: 12) {
                Image("profile")
                    .resizable()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text("하원")
                        .foregroundStyle(Color.gray800)
                        .font(.kdf(.caption1))
                    Text("사용자 정보를 입력해주세요")
                        .foregroundStyle(Color.gray300)
                        .font(.kdf(.caption4))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.background)
    }
}

#Preview {
    MyView()
}
