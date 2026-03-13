import SwiftUI
import UIKit

struct QuizView: View {
    // Environment
    @EnvironmentObject var quiz: QuizState
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    // Local State
    @State private var index: Int = 0
    @State private var showResult = false
    @State private var mascot: MascotState = .sleep
    @State private var showHome = false

    // Fortschritt & aktuelle Frage (globale questions-Liste)
    private var progress: Double { Double(index + 1) / Double(questions.count) }
    private var current: Question { questions[index] }

    // Glücks-Animation fürs Maskottchen
    private func playHappy() {
        mascot = MascotTheme.happy.randomElement() ?? .flykiss
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.9)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                Text("Selbsttest Lernstil")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text("Frage \(index + 1) von \(questions.count)")
                    .font(.headline)

                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(.white)
                    .shadow(color: .black.opacity(0.25), radius: 1, y: 1)
                    .padding(.horizontal)
                    .animation(.easeInOut, value: index)

                // Maskottchen (Lottie)
                LottieMascotView(state: $mascot, names: MascotTheme.mapping)
                    .frame(height: 120)
                    .padding(.bottom, 6)

                // Karte: Frage + Likert
                VStack(spacing: 16) {
                    Text(current.text)
                        .font(.title3)
                        .multilineTextAlignment(.center)

                    LikertScale(
                        selected: Binding(
                            get: { quiz.answers[index] ?? 0 },
                            set: { quiz.answers[index] = $0 }
                        ),
                        onSelect: { _ in playHappy() }
                    )
                }
                .padding(20)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.18), radius: 14, y: 8)
                .padding(.horizontal)
                .animation(.easeInOut, value: index)

                Spacer()

                // Bottom Buttons
                HStack {
                    // Zurück
                    Button {
                        if index > 0 {
                            index -= 1
                            mascot = .sleep
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Zurück").fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.6), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(index == 0)
                    .opacity(index == 0 ? 0.35 : 1)

                    Spacer()

                    // Weiter / Ergebnis
                    if index < questions.count - 1 {
                        Button {
                            if quiz.isAnswered(index) {
                                index += 1
                                mascot = .sleep
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text("Weiter").fontWeight(.semibold)
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
                        }
                        .buttonStyle(.plain)
                        .disabled(!quiz.isAnswered(index))
                        .opacity(quiz.isAnswered(index) ? 1 : 0.6)
                    } else {
                        Button { showResult = true } label: {
                            HStack(spacing: 8) {
                                Text("Ergebnis").fontWeight(.semibold)
                                Image(systemName: "checkmark.circle.fill")
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
                        }
                        .buttonStyle(.plain)
                        .disabled(!quiz.allAnswered)
                        .opacity(quiz.allAnswered ? 1 : 0.6)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Zurück")
                    }
                    .foregroundColor(.white)
                }
            }
        }

        // Ergebnis-Sheet
        .sheet(isPresented: $showResult, onDismiss: { index = 0 }) {
            ResultView(index: $index, onGoHome: {
                // Nach „Startseite“ im Ergebnis:
                quiz.reset()
                index = 0
                showHome = true          // Dashboard als Cover zeigen
            })
            .environmentObject(quiz)
            .environmentObject(app)
        }

        // Dashboard zeigen (Intro bleibt Root)
        .fullScreenCover(isPresented: $showHome) {
            NavigationStack {
                HomeView()
                    .environmentObject(app)
            }
        }

        // Feinschliff
        .onChange(of: index) { _ in mascot = .sleep }
        .tint(.white)
    }
}

// MARK: - Likert

struct LikertScale: View {
    @Binding var selected: Int
    var onSelect: ((Int) -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            Text("Bitte wähle 1–5 (1 = gar nicht, 5 = voll)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { val in
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        selected = val
                        onSelect?(val)
                    } label: {
                        Text("\(val)")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(selected == val ? Color.white.opacity(0.25)
                                                       : Color.white.opacity(0.12))
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(
                                    Color.white.opacity(selected == val ? 0.9 : 0.4),
                                    lineWidth: 1
                                )
                            )
                    }
                }
            }
        }
    }
}
