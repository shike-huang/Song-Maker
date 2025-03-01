import SwiftUI
import AVFoundation

@main
struct ChordMelodyApp: App {
    @StateObject private var audioManager = AudioManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioManager)
                .onAppear {
                    audioManager.preloadSounds()
                }
        }
    }
} 