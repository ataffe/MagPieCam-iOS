//
//  CameraLiveVideoView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/25/26.
//

import SwiftUI
import WebRTC
import os

struct CameraStreamingView: View {
    let camera: Camera
    @State private var whepClient: WHEPClient
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var isTimedOut = false

    private var isLandscape: Bool { verticalSizeClass == .compact }

    private var isConnected: Bool {
        whepClient.connectionState == .connected
            || whepClient.connectionState == .completed
    }

    init(camera: Camera) {
        self.camera = camera
        _whepClient = State(initialValue: WHEPClient(whepURL: AppConfig.whepUrl(for: camera.id)))
    }

    private func requestLandscape() {
        AppDelegate.orientationLock = .landscapeRight
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        scene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight)) { error in
            Logger.whepClient.error("Failed to rotate to landscape: \(error.localizedDescription)")
        }
    }

    private func requestPortrait() {
        AppDelegate.orientationLock = .portrait
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        scene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) { error in
            Logger.whepClient.error("Failed to rotate to portrait: \(error.localizedDescription)")
        }
    }

    var body: some View {
        ZStack {
            if isLandscape {
                Color.black.ignoresSafeArea()
                RTCVideoView(track: whepClient.remoteVideoTrack)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .overlay(alignment: .topTrailing) {
                        if isConnected {
                            Button { requestPortrait() } label: {
                                Image(systemName: "arrow.down.right.and.arrow.up.left")
                                    .foregroundStyle(.white)
                                    .padding(8)
                                    .background(.ultraThinMaterial, in: Circle())
                                    .font(.largeTitle)
                            }
                            .padding(12)
                        }
                    }
            } else {
                Constants.UI.backgroundGradient(for: colorScheme)
                    .ignoresSafeArea()
                RTCVideoView(track: whepClient.remoteVideoTrack)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius))
                    .overlay(alignment: .bottomTrailing) {
                        if isConnected {
                            Button { requestLandscape() } label: {
                                Image(systemName: "arrow.down.left.and.arrow.up.right")
                                    .foregroundStyle(Color.primary)
                                    .padding(8)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            .padding(12)
                        }
                    }
                    .shadow(
                        color: .black.opacity(Constants.UI.cardShadowOpacity),
                        radius: Constants.UI.cardShadowRadius,
                        y: Constants.UI.cardShadowY
                    )
                    .padding()
            }

            if !isConnected {
                if isTimedOut || whepClient.isOffline {
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 48))
                            .foregroundStyle(isLandscape ? .white : .primary)
                        Text("Camera Offline")
                            .font(.headline)
                            .foregroundStyle(isLandscape ? .white : .primary)
                        Text("It looks like \(camera.location) is offline right now.")
                            .font(.subheadline)
                            .foregroundStyle(isLandscape ? .white.opacity(0.8) : .secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(isLandscape ? .white : .primary)
                            .scaleEffect(1.5)
                        Text("Connecting to \(camera.location)...")
                            .foregroundStyle(isLandscape ? .white : .primary)
                            .font(.subheadline)
                    }
                }
            }
        }
        .navigationTitle("\(camera.location) Live View")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(isLandscape ? .hidden : .visible, for: .navigationBar)
        .onAppear {
            whepClient.tokenProvider = { [dependencies] in
                try await dependencies.authService.validAccessToken()
            }
            Task {
                try? await dependencies.streamingService.start(cameraId: camera.id)
                whepClient.connect()
            }
        }
        .onDisappear {
            whepClient.disconnect()
            AppDelegate.orientationLock = .portrait
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                scene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) { _ in }
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(30))
            if !isConnected { isTimedOut = true }
        }
    }
}

struct RTCVideoView: UIViewRepresentable {
    let track: RTCVideoTrack?

    func makeUIView(context: Context) -> RTCMTLVideoView {
        let view = RTCMTLVideoView()
        view.videoContentMode = .scaleAspectFit
        return view
    }

    func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {
        track?.add(uiView)
    }
}

//#Preview {
//    NavigationStack {
//        CameraStreamingView(camera: Camera(id: "testId", location: "Office", cameraPreviewUrl: nil, previewUpdatedAt: nil))
//    }
//    .environment(AppDependencies())
//}
