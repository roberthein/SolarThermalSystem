import SwiftUI

/// Presents a floating panel with dynamic corner radius that adapts to device screen curvature.
/// The panel can be persistent (automatically re-presenting) or dismissible.
extension View {
    @ViewBuilder
    func floatingPanel<PanelContent: View>(
        minimumCornerRadius: CGFloat = 30,
        padding: CGFloat,
        background: AnyShapeStyle,
        isPresented: Binding<Bool>,
        isPersistent: Bool = false,
        @ViewBuilder panelContent: @escaping () -> PanelContent
    ) -> some View {
        self
            .modifier(
                FloatingPanelModifier(
                    minimumCornerRadius: minimumCornerRadius,
                    padding: padding,
                    background: background,
                    isPresented: isPresented,
                    isPersistent: isPersistent,
                    panelContent: panelContent
                )
            )
    }
}

fileprivate struct FloatingPanelModifier<PanelContent: View>: ViewModifier {
    var minimumCornerRadius: CGFloat
    var padding: CGFloat
    var background: AnyShapeStyle
    @Binding var isPresented: Bool
    var isPersistent: Bool
    @ViewBuilder var panelContent: PanelContent

    @State private var progress: CGFloat = 0
    @State private var storedHeight: CGFloat = 0
    @State private var animationDuration: CGFloat = 0
    @State private var deviceCornerRadius: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                progress = 0
                storedHeight = 0
                animationDuration = 0

                if isPersistent {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPresented = true
                    }
                }
            } content: {
                let padding = needsPadding ? padding * (1 - progress) : 0
                let cornerRadius = deviceCornerRadius - padding

                panelContent
                    .compositingGroup()
                    .background {
                        if #available(iOS 26, *) {
                            Rectangle()
                                .fill(background)
                        } else {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(background)
                        }
                    }
                    .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
                    .padding([.horizontal, .bottom], padding)
                    .animation(.easeInOut(duration: animationDuration), value: progress)
                    .presentationCornerRadius(cornerRadius)
                    .presentationBackground(.clear)
                    .background {
                        PanelHelper { radius in
                            deviceCornerRadius = max(radius, minimumCornerRadius)
                        } height: { height in
                            let maxHeight = windowSize.height * 0.7
                            let progress = max(0, min(1, (height.rounded() / maxHeight)))
                            self.progress = progress

                            let diff = abs(height - storedHeight)
                            let duration = max(min(diff / 100, 0.22), 0)
                            if diff > 10 && storedHeight != 0 {
                                animationDuration = duration
                            }
                            storedHeight = height
                        }
                    }
                    .ignoresSafeArea(.all, edges: .bottom)
                    .persistentSystemOverlays(.hidden)
            }
    }

    private var needsPadding: Bool {
        if #available(iOS 26, *) {
            false
        } else {
            true
        }
    }

    private var windowSize: CGSize {
        if let screen = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen {
            return screen.bounds.size
        }

        return .zero
    }
}

/// UIKit bridge that extracts device corner radius and panel height from the underlying presentation layer.
/// This allows SwiftUI to adapt the panel appearance to match the device's physical characteristics.
fileprivate struct PanelHelper: UIViewRepresentable {
    var cornerRadius: (CGFloat) -> ()
    var height: (CGFloat) -> ()

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if let layer = view.superview?.superview?.superview?.layer {
                cornerRadius(layer.cornerRadius)
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if !context.coordinator.isShadowRemoved {
            DispatchQueue.main.async {
                if let layer = uiView.superview?.superview?.superview?.layer {
                    cornerRadius(layer.cornerRadius)
                }
                
                if let shadowView = uiView.dropShadowView {
                    shadowView.layer.shadowColor = UIColor.clear.cgColor
                    context.coordinator.isShadowRemoved = true
                }
            }
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIView, context: Context) -> CGSize? {
        if let height = proposal.height {
            self.height(height)
        }
        return nil
    }

    class Coordinator: NSObject {
        var isShadowRemoved: Bool = false
    }
}

/// Traverses the view hierarchy to find UIDropShadowView (used to remove default sheet shadow)
fileprivate extension UIView {
    var dropShadowView: UIView? {
        if let superview, String(describing: type(of: superview)) == "UIDropShadowView" {
            return superview
        }
        return superview?.dropShadowView
    }
}
