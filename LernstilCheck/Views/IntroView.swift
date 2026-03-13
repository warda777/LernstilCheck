import SwiftUI

struct IntroView: View {
    @State private var mascot: MascotState = .idle
    @StateObject private var quiz = QuizState()   // wird an QuizView durchgereicht

    var body: some View {
        ZStack {
            // Hintergrund
            LinearGradient(
                colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.9)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer(minLength: 20)

                LottieMascotView(
                    state: $mascot,
                    names: [
                        .idle: "mascot_idle",
                        .wave: "mascot_wave",
                        .clap: "mascot_clap",
                        .celebrate: "mascot_celebrate"
                    ]
                )
                .frame(height: 180)
                .padding(.bottom, 8)

                // Titel + Subtext in „Glas“-Karte
                VStack(spacing: 12) {
                    Text("Lernstil-Check")
                        .font(.system(size: 36, weight: .bold))

                    Text("Beantworte 8 kurze Aussagen (1–5) und erfahre, ob du eher visuell, auditiv oder kinästhetisch lernst.")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding(20)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .padding(.horizontal)

                // Start-Button -> navigiert in den bereits vorhandenen NavigationStack (aus App)
                NavigationLink {
                    QuizView()
                        .environmentObject(quiz)     // QuizState an Ziel übergeben
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("Jetzt starten")
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial)
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
                }

                Text("Dauer: ca. 1 Minute • keine Speicherung")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 4)

                Spacer()
            }
            .foregroundColor(.white)
            .padding(.bottom, 24)
        }
        // KEINE NavigationView hier! Der NavigationStack kommt von LernstilCheckApp.
    }
}
