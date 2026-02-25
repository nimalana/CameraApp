import AVFoundation
import SwiftUI
import Combine

final class CameraManager: NSObject, ObservableObject {

    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")

    private var videoDeviceInput: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()

    @Published var zoomFactor: CGFloat = 1.0

    override init() {
        super.init()
    }

    // MARK: - Session
    func startSession() {
        sessionQueue.async {
            if self.session.isRunning { return }
            self.configureSession()
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard
            let camera = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
            ),
            let input = try? AVCaptureDeviceInput(device: camera)
        else {
            session.commitConfiguration()
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
            self.videoDeviceInput = input
        }

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()
        session.startRunning()
    }

    // MARK: - Capture
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024)
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: - Focus
    func focus(at point: CGPoint) {
        sessionQueue.async {
            guard let device = self.videoDeviceInput?.device else { return }

            do {
                try device.lockForConfiguration()

                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = point
                    device.focusMode = .autoFocus
                }

                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = point
                    device.exposureMode = .autoExpose
                }

                device.unlockForConfiguration()
            } catch {
                print("Focus error:", error)
            }
        }
    }

    // MARK: - Zoom
    func setZoom(_ factor: CGFloat) {
        sessionQueue.async {
            guard let device = self.videoDeviceInput?.device else { return }

            let maxZoom = min(device.activeFormat.videoMaxZoomFactor, 5.0)
            let clamped = min(max(factor, 1.0), maxZoom)

            do {
                try device.lockForConfiguration()
                device.ramp(toVideoZoomFactor: clamped, withRate: 6.0)
                device.unlockForConfiguration()

                DispatchQueue.main.async {
                    self.zoomFactor = clamped
                }
            } catch {
                print("Zoom error:", error)
            }
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {

        guard
            error == nil,
            let data = photo.fileDataRepresentation()
        else { return }

        PhotoLibraryManager.shared.savePhoto(data)
    }
}
