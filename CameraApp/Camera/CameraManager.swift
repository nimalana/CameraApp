//
//  CameraManager.swift
//  CameraApp
//
//  Created by Nimalan Arulvelan on 1/21/26.
//

import AVFoundation
import SwiftUI
import Combine

final class CameraManager: NSObject, ObservableObject {

    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")

    private var videoDeviceInput: AVCaptureDeviceInput?

    override init() {
        super.init()
        configureSession()
    }

    private func configureSession() {
        sessionQueue.async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            guard
                let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                     for: .video,
                                                     position: .back),
                let input = try? AVCaptureDeviceInput(device: camera)
            else {
                return
            }

            if self.session.canAddInput(input) {
                self.session.addInput(input)
                self.videoDeviceInput = input
            }

            self.session.commitConfiguration()
            self.session.startRunning()
            
            print("Session running:", self.session.isRunning)
        }
    }
}
