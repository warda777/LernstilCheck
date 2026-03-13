import SwiftUI
import Combine

final class Keyboard: ObservableObject {
    @Published var height: CGFloat = 0
    private var bag = Set<AnyCancellable>()

    init() {
        let nc = NotificationCenter.default
        let willChange = nc.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
        let willHide   = nc.publisher(for: UIResponder.keyboardWillHideNotification)

        willChange
            .merge(with: willHide)
            .sink { [weak self] note in
                guard let self else { return }
                let end = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
                let screen = UIScreen.main.bounds
                let newHeight = max(0, screen.height - end.origin.y)

                withAnimation(.easeOut(duration: 0.25)) {
                    self.height = newHeight
                }
            }
            .store(in: &bag)
    }
}
