import Foundation

struct Chord: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let emoji: String
    let sound: String
    
    static func == (lhs: Chord, rhs: Chord) -> Bool {
        lhs.id == rhs.id
    }
}

struct Note: Identifiable {
    let id = UUID()
    let name: String
    let sound: String
    let range: NoteRange
}

enum NoteRange {
    case high, mid, low
}

struct ChordGroup: Identifiable {
    let id = UUID()
    var chords: [Chord]
    
    init(chords: [Chord] = []) {
        self.chords = chords
    }
} 