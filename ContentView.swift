import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject private var audioManager: AudioManager
    
    // Chord data
    let availableChords: [Chord] = [
        Chord(name: "Happy", emoji: "😊", sound: "happy"),
        Chord(name: "Sad", emoji: "😢", sound: "sad"),
        Chord(name: "Excited", emoji: "😁", sound: "excited"),
        Chord(name: "Calm", emoji: "😌", sound: "calm"),
        Chord(name: "Mysterious", emoji: "🧐", sound: "mysterious"),
        Chord(name: "Tense", emoji: "😬", sound: "tense")
    ]
    
    // Note data
    let notes: [Note] = [
        // High range notes
        Note(name: "C5", sound: "c5", range: .high),
        Note(name: "D5", sound: "d5", range: .high),
        Note(name: "E5", sound: "e5", range: .high),
        Note(name: "G5", sound: "g5", range: .high),
        Note(name: "A5", sound: "a5", range: .high),
        
        // Mid range notes
        Note(name: "C4", sound: "c4", range: .mid),
        Note(name: "D4", sound: "d4", range: .mid),
        Note(name: "E4", sound: "e4", range: .mid),
        Note(name: "G4", sound: "g4", range: .mid),
        Note(name: "A4", sound: "a4", range: .mid),
        
        // Low range notes
        Note(name: "C3", sound: "c3", range: .low),
        Note(name: "D3", sound: "d3", range: .low),
        Note(name: "E3", sound: "e3", range: .low),
        Note(name: "G3", sound: "g3", range: .low),
        Note(name: "A3", sound: "a3", range: .low)
    ]
    
    // State
    @State private var chordGroups: [ChordGroup] = [ChordGroup()]
    @State private var currentGroupIndex = 0
    @State private var currentChordSelection: [Chord] = []
    
    var body: some View {
        VStack(spacing: 20) {
            // Upper section - Chord buttons
            VStack(alignment: .leading) {
                Text("Select Chords")
                    .font(.headline)
                    .padding(.horizontal)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                    ForEach(availableChords) { chord in
                        Button(action: {
                            selectChord(chord)
                        }) {
                            VStack {
                                Text(chord.emoji)
                                    .font(.system(size: 40))
                                Text(chord.name)
                                    .font(.caption)
                            }
                            .frame(width: 80, height: 80)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.15))
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Middle section - Sound track
            VStack {
                Text("Chord Progression")
                    .font(.headline)
                
                HStack {
                    Button(action: {
                        if chordGroups.count > 1 {
                            chordGroups.removeLast()
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                    .disabled(chordGroups.count <= 1)
                    .padding(.leading)
                    
                    TabView(selection: $currentGroupIndex) {
                        ForEach(chordGroups.indices, id: \.self) { index in
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                                
                                if chordGroups[index].chords.isEmpty {
                                    Text("Select 4 chords for this progression")
                                        .foregroundColor(.gray)
                                } else {
                                    HStack(spacing: 20) {
                                        ForEach(chordGroups[index].chords) { chord in
                                            Text(chord.emoji)
                                                .font(.system(size: 34))
                                        }
                                    }
                                }
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height: 120)
                    
                    Button(action: {
                        if chordGroups.count < 2 {
                            chordGroups.append(ChordGroup())
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.green)
                    }
                    .disabled(chordGroups.count >= 2)
                    .padding(.trailing)
                }
                
                HStack(spacing: 30) {
                    Button(action: {
                        togglePlayback()
                    }) {
                        HStack {
                            Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.title)
                            Text(audioManager.isPlaying ? "Pause" : "Play")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        clearCurrentGroup()
                    }) {
                        HStack {
                            Image(systemName: "trash.circle.fill")
                                .font(.title)
                            Text("Clear")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                }
                .padding(.top, 5)
            }
            
            // Lower section - Note buttons
            VStack(alignment: .leading) {
                Text("Melody Notes")
                    .font(.headline)
                    .padding(.horizontal)
                
                // High range notes
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(notes.filter { $0.range == .high }) { note in
                            Button(action: {
                                playNote(note)
                            }) {
                                Text(note.name)
                                    .frame(width: 50, height: 50)
                                    .background(Color.orange.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Mid range notes
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(notes.filter { $0.range == .mid }) { note in
                            Button(action: {
                                playNote(note)
                            }) {
                                Text(note.name)
                                    .frame(width: 50, height: 50)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Low range notes
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(notes.filter { $0.range == .low }) { note in
                            Button(action: {
                                playNote(note)
                            }) {
                                Text(note.name)
                                    .frame(width: 50, height: 50)
                                    .background(Color.purple.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
    }
    
    // MARK: - Interaction Methods
    
    func selectChord(_ chord: Chord) {
        audioManager.playSound(chord.sound)
        
        if chordGroups[currentGroupIndex].chords.count < 4 {
            chordGroups[currentGroupIndex].chords.append(chord)
        }
    }
    
    func playNote(_ note: Note) {
        audioManager.playSound(note.sound)
    }
    
    func togglePlayback() {
        if audioManager.isPlaying {
            audioManager.stopChordProgression()
        } else {
            if !chordGroups.isEmpty {
                let firstGroup = chordGroups[0].chords
                let secondGroup = chordGroups.count > 1 ? chordGroups[1].chords : []
                
                if !firstGroup.isEmpty {
                    audioManager.startChordProgression(chords: firstGroup, secondGroup: secondGroup)
                }
            }
        }
    }
    
    func clearCurrentGroup() {
        chordGroups[currentGroupIndex].chords = []
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AudioManager())
    }
} 