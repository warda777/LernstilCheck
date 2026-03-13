import SwiftUI

// Liefert den verschachtelten Typ, den wir unten verwenden
extension LottieMascotView {
    struct Names {
        let sleep: String
        let idle: String
        let wave: String
        let jump: String
        let flykiss: String
        let hugkiss: String
    }
}


// Zentrale Stelle für Lottie-Dateien des Maskottchens
enum MascotTheme {
    // Dateinamen OHNE .json (liegen im Target unter “Copy Bundle Resources”)
    static let mapping: [MascotState: String] = [
        .sleep:   "mascot_sleep",
        .idle:    "mascot_idle",
        .flykiss: "mascot_flykiss",
        .hugkiss: "mascot_hugkiss",
        .jump:    "mascot_jump",
        .wave:    "mascot_wave"
    ]

    // Pool für fröhliche Einmal-Animationen
    static let happy: [MascotState] = [.flykiss, .hugkiss, .jump, .wave]

    // Genau der Typ, den LottieMascotView erwartet
    static var lottieNames: LottieMascotView.Names {
        .init(
            sleep:   mapping[.sleep]   ?? "mascot_sleep",
            idle:    mapping[.idle]    ?? "mascot_idle",
            wave:    mapping[.wave]    ?? "mascot_wave",
            jump:    mapping[.jump]    ?? "mascot_jump",
            flykiss: mapping[.flykiss] ?? "mascot_flykiss",
            hugkiss: mapping[.hugkiss] ?? "mascot_hugkiss"
        )
    }
}
