import AVFoundation
import SwiftUI

class AudioManager: ObservableObject {
    private var audioEngine: AVAudioEngine
    private var players: [String: AVAudioPlayerNode] = [:]
    private var buffers: [String: AVAudioPCMBuffer] = [:]
    private var loopPlayers: [AVAudioPlayerNode] = []
    private var chordTimer: Timer?
    
    @Published var isPlaying = false
    
    init() {
        audioEngine = AVAudioEngine()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func preloadSounds() {
        // Chord sounds
        let chordSounds = [
            "happy", "sad", "excited", "calm", "mysterious", "tense"
        ]
        
        // Note sounds (3 octaves of a pentatonic scale)
        let noteSounds = [
            // High range
            "c5", "d5", "e5", "g5", "a5",
            // Mid range
            "c4", "d4", "e4", "g4", "a4",
            // Low range
            "c3", "d3", "e3", "g3", "a3"
        ]
        
        for sound in chordSounds + noteSounds {
            loadSound(sound)
        }
        
        do {
            try audioEngine.start()
        } catch {
            print("Could not start audio engine: \(error.localizedDescription)")
        }
    }
    
    private func loadSound(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Could not find sound file: \(name).mp3")
            createDummySound(for: name)
            return
        }
        
        do {
            let file = try AVAudioFile(forReading: url)
            let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
            
            try file.read(into: buffer!)
            
            let player = AVAudioPlayerNode()
            audioEngine.attach(player)
            audioEngine.connect(player, to: audioEngine.mainMixerNode, format: buffer!.format)
            
            players[name] = player
            buffers[name] = buffer
        } catch {
            print("Could not load sound \(name): \(error.localizedDescription)")
        }
    }
    
    private func createDummySound(for name: String) {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        let duration: Double = name.contains("happy") || name.contains("sad") || 
                               name.contains("excited") || name.contains("calm") || 
                               name.contains("mysterious") || name.contains("tense") ? 2.0 : 1.0
        
        let sampleRate = format.sampleRate
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            print("Could not create buffer for dummy sound")
            return
        }
        
        buffer.frameLength = frameCount
        
        let frequency = determineDummyFrequency(for: name)
        
        for frame in 0..<Int(frameCount) {
            let value = sin(2.0 * Float.pi * frequency * Float(frame) / Float(sampleRate))
            
            let normalizedPosition = Float(frame) / Float(frameCount)
            let envelope: Float
            
            if normalizedPosition < 0.1 {
                envelope = normalizedPosition / 0.1  // Attack
            } else if normalizedPosition > 0.8 {
                envelope = (1.0 - normalizedPosition) / 0.2  // Release
            } else {
                envelope = 1.0  // Sustain
            }
            
            let amplifiedValue = value * envelope * 0.5
            
            for channel in 0..<Int(format.channelCount) {
                buffer.floatChannelData?[channel][frame] = amplifiedValue
            }
        }
        
        let player = AVAudioPlayerNode()
        audioEngine.attach(player)
        audioEngine.connect(player, to: audioEngine.mainMixerNode, format: format)
        
        players[name] = player
        buffers[name] = buffer
    }
    
    private func determineDummyFrequency(for name: String) -> Float {
        // Notes
        if name.contains("c5") { return 523.25 }
        else if name.contains("d5") { return 587.33 }
        else if name.contains("e5") { return 659.25 }
        else if name.contains("g5") { return 783.99 }
        else if name.contains("a5") { return 880.00 }
        
        else if name.contains("c4") { return 261.63 }
        else if name.contains("d4") { return 293.66 }
        else if name.contains("e4") { return 329.63 }
        else if name.contains("g4") { return 392.00 }
        else if name.contains("a4") { return 440.00 }
        
        else if name.contains("c3") { return 130.81 }
        else if name.contains("d3") { return 146.83 }
        else if name.contains("e3") { return 164.81 }
        else if name.contains("g3") { return 196.00 }
        else if name.contains("a3") { return 220.00 }
        
        // Chords (representative frequencies with harmonics)
        else if name.contains("happy") { return 261.63 }      // C major-ish
        else if name.contains("sad") { return 246.94 }        // B minor-ish
        else if name.contains("excited") { return 293.66 }    // D major-ish
        else if name.contains("calm") { return 220.00 }       // A minor-ish
        else if name.contains("mysterious") { return 207.65 } // Ab diminished-ish
        else if name.contains("tense") { return 277.18 }      // C# diminished-ish
        
        return 440.0 // A4 as default
    }
    
    func playSound(_ name: String) {
        guard let player = players[name], let buffer = buffers[name] else {
            print("Sound not loaded: \(name)")
            return
        }
        
        player.stop()
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        player.play()
    }
    
    func startChordProgression(chords: [Chord], secondGroup: [Chord] = []) {
        stopChordProgression()
        isPlaying = true
        
        var allChords = chords
        if !secondGroup.isEmpty {
            allChords.append(contentsOf: secondGroup)
        }
        
        let interval = 2.0 // 2 seconds per chord
        var currentIndex = 0
        
        chordTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let chord = allChords[currentIndex]
            self.playSound(chord.sound)
            
            currentIndex = (currentIndex + 1) % allChords.count
        }
        
        // Play the first chord immediately
        if !allChords.isEmpty {
            playSound(allChords[0].sound)
        }
    }
    
    func stopChordProgression() {
        chordTimer?.invalidate()
        chordTimer = nil
        isPlaying = false
    }
} 