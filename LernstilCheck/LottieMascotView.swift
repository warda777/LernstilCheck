import SwiftUI
import Lottie

/// Zustände, die du aus SwiftUI setzt.
enum MascotState: Equatable { case sleep, idle, wave, clap, celebrate, flykiss, hugkiss, jump }

/// SwiftUI-Wrapper für Lottie 4.x, der Animationen je nach `state` abspielt.
struct LottieMascotView: UIViewRepresentable {
    @Binding var state: MascotState

    /// Mapping von Zustand -> JSON-Dateiname im Bundle (ohne .json)
    var names: [MascotState: String]

    /// Skalierung und Geschwindigkeit optional anpassbar
    var contentMode: UIView.ContentMode = .scaleAspectFit
    var speed: CGFloat = 1.0

    // MARK: - Coordinator hält den LottieAnimationView
    class Coordinator {
        let animationView = LottieAnimationView()
        var lastState: MascotState?
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let av = context.coordinator.animationView
        av.translatesAutoresizingMaskIntoConstraints = false
        av.contentMode = contentMode
        av.backgroundBehavior = .pauseAndRestore
        container.addSubview(av)
        NSLayoutConstraint.activate([
            av.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            av.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            av.topAnchor.constraint(equalTo: container.topAnchor),
            av.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        // Erste Anzeige
        setAnimation(for: state, coordinator: context.coordinator)
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard context.coordinator.lastState != state else { return }
        setAnimation(for: state, coordinator: context.coordinator)
    }

    private func setAnimation(for state: MascotState, coordinator: Coordinator) {
        coordinator.lastState = state
        guard let name = names[state] ?? names[.idle] else { return }

        let view = coordinator.animationView
        view.animation = LottieAnimation.named(name)
        view.animationSpeed = speed

        // <- hier entscheidest du, ob geloopt wird oder nur einmal
        let shouldLoop = (state == .idle || state == .sleep)
        view.loopMode = shouldLoop ? .loop : .playOnce

        view.play()
    }
}
