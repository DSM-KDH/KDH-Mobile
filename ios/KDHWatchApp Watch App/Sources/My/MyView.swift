#if os(watchOS)
//
//  MyView.swift
//  Runner
//
//  Created by hawon on 4/17/26.
//

import SwiftUI

struct MyView: View {
    @State private var my: My = .init(name: "하원", info: "")

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image("profile")
                    .resizable()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text(my.name)
                        .foregroundStyle(Color.gray800)
                        .font(.kdf(.caption1))
                    Text((my.info?.isEmpty ?? true) ? "사용자 정보를 입력해주세요" : my.info!)
                        .foregroundStyle(Color.gray300)
                        .font(.kdf(.caption4))
                }
                Spacer()
            }
            .padding(.leading, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.background)
    }
}

private struct My: Identifiable {
    let id = UUID()
    let name: String
    let info: String?
}


#Preview {
    MyView()
}
#endif
