// FeedbackView.swift
import SwiftUI
import UIKit

struct FeedbackView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var klarheit = 0
    @State private var design   = 0
    @State private var nuetzen  = 0
    @State private var kommentar = ""
    @FocusState private var focusComment: Bool

    @State private var sending = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var onHome: (() -> Void)?
    init(onHome: (() -> Void)? = nil) { self.onHome = onHome }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue.opacity(0.9), .purple.opacity(0.9)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Feedback")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)

                    LikertRow(title: "Klarheit",      selection: $klarheit)
                    LikertRow(title: "Design",        selection: $design)
                    LikertRow(title: "Nützlichkeit",  selection: $nuetzen)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Weitere Anmerkungen")
                            .font(.headline)
                            .foregroundColor(.white)

                        ZStack(alignment: .topLeading) {
                            if kommentar.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("Schreib’ uns hier, was wir noch verbessern können …")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                            }

                            TextEditor(text: $kommentar)
                                .focused($focusComment)
                                .frame(minHeight: 160, maxHeight: 200)
                                .padding(8)
                                .background(Color(uiColor: .systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .textInputAutocapitalization(.sentences)
                                .disableAutocorrection(false)
                        }
                    }
                    .padding(16)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }
                .padding(20)
                .foregroundColor(.white)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack {
                Button {
                    Task {
                        sending = true
                        defer { sending = false }

                        let rec = FeedbackRecord(
                            klarheit: klarheit,
                            design: design,
                            nuetzen: nuetzen,
                            kommentar: kommentar.trimmingCharacters(in: .whitespacesAndNewlines),
                            deviceId: UIDevice.current.identifierForVendor?.uuidString,
                            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                        )

                        do {
                            try await FeedbackService.submit(rec)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            kommentar = ""
                            klarheit = 0; design = 0; nuetzen = 0
                            if let onHome { onHome() } else { dismiss() }
                        } catch {
                            alertMessage = "Senden fehlgeschlagen: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        if sending { ProgressView().tint(.black) }
                        Image(systemName: "paperplane.fill")
                        Text(sending ? "Sende…" : "Feedback senden").fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 3)
                }
                .disabled(sending)
                .alert("Hinweis", isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(alertMessage)
                }

                Spacer(minLength: 0)

                Button {
                    focusComment = false
                    if let onHome { onHome() } else { dismiss() }
                } label: {
                    Text("Home").fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Fertig") { focusComment = false }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { focusComment = false }
    }
}

// Gleichmäßige 1–5-Reihe
private struct LikertRow: View {
    let title: String
    @Binding var selection: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline).foregroundColor(.white)
            Text("Bitte wähle 1–5 (1 = gar nicht, 5 = voll)")
                .font(.subheadline).foregroundStyle(.secondary)
            HStack {
                ForEach(1...5, id: \.self) { val in
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        selection = val
                    } label: {
                        Text("\(val)")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(selection == val ? Color.white.opacity(0.25)
                                                         : Color.white.opacity(0.12))
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.white.opacity(selection == val ? 0.9 : 0.4), lineWidth: 1)
                            )
                    }
                    if val != 5 { Spacer() }
                }
            }
        }
        .padding(16)
        .frame(minHeight: 160)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}
