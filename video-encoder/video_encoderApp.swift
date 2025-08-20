//
//  video_encoderApp.swift
//  video-encoder
//
//  Created by 肖鹏 on 2025/8/19.
//

import SwiftUI

@main
struct video_encoderApp: App {
    @StateObject private var viewModel = VideoEncoderViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}
