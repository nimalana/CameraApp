import SwiftUI
import Combine

struct ContentView: View {

    @StateObject private var cameraManager = CameraManager()
    @ObservedObject private var library = PhotoLibraryManager.shared

    @State private var lastZoomFactor: CGFloat = 1.0
    @State private var focusPoint: CGPoint?
    @State private var showGallery = false

    var body: some View {
        ZStack {

            // MARK: - Camera Preview
            GeometryReader { geometry in
                CameraPreview(
                    session: cameraManager.session,
                    focusAction: { _ in }
                )
                .ignoresSafeArea()
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            cameraManager.setZoom(lastZoomFactor * value)
                        }
                        .onEnded { _ in
                            lastZoomFactor = cameraManager.zoomFactor
                        }
                )
                .onTapGesture { location in
                    let normalizedPoint = CGPoint(
                        x: location.x / geometry.size.width,
                        y: location.y / geometry.size.height
                    )

                    cameraManager.focus(at: normalizedPoint)
                    focusPoint = location

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        focusPoint = nil
                    }
                }
            }

            // MARK: - Focus Ring Animation
            if let focusPoint = focusPoint {
                Circle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .frame(width: 80, height: 80)
                    .position(focusPoint)
                    .transition(.opacity)
            }

            // MARK: - Bottom Controls
            VStack {
                Spacer()

                HStack {

                    // Thumbnail
                    Button {
                        showGallery = true
                    } label: {
                        Group {
                            if let image = library.images.first {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Color.black
                            }
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 1)
                        )
                    }

                    Spacer()

                    // Capture Button
                    Button {
                        cameraManager.capturePhoto()
                    } label: {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 4)
                            .frame(width: 75, height: 75)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                            )
                    }

                    Spacer()

                    // Zoom indicator
                    Text(String(format: "%.1fx", cameraManager.zoomFactor))
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                        .frame(width: 60)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showGallery) {
            PhotoGalleryView()
        }
        .onAppear {
            cameraManager.startSession()
        }
    }
}
