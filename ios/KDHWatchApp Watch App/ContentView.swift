//
//  ContentView.swift
//  KDHWatchApp Watch App
//
//  Created by hawon on 4/1/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()

            Image("logo")
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 28)
            Text("AI가 만드는 나만의 루틴")
                .font(.kdf(.body1))
                .foregroundStyle(.gray100)

            Spacer()
        }
        .background(Color.background)
    }
}

#Preview {
    ContentView()
}
