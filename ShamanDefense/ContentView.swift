//
//  ContentView.swift
//  ShamanDefense
//
//  Created by Richie Daryl Kwenandar on 06/05/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenStartStory") private var hasSeenStartStory = false

    var body: some View {
        Group {
            if hasSeenStartStory {
                GameScreen()
            } else {
                StartStoryScreen {
                    hasSeenStartStory = true
                }
            }
        }
        // selalu tampil story screen dulu 
        .onAppear {
            hasSeenStartStory = false
        }
    }
}
