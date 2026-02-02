//
//  ContentView.swift
//  CameraApp
//
//  Created by Nimalan Arulvelan on 1/21/26.
//

import SwiftUI
import Combine

struct ContentView: View {

    @StateObject private var cameraManager = CameraManager()

    var body: some View {
        ZStack {
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()

            VStack {
                Spacer()

                Button(action: {
                    print("Capture tapped")
                }) {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 4)
                        .frame(width: 70, height: 70)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                        )
                }
                .padding(.bottom, 30)
            }
        }
    }
}
