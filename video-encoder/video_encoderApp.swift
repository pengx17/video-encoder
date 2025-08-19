//
//  video_encoderApp.swift
//  video-encoder
//
//  Created by 肖鹏 on 2025/8/19.
//

import SwiftUI

@main
struct video_encoderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 700, height: 400)
        .windowStyle(.hiddenTitleBar)
    }
}