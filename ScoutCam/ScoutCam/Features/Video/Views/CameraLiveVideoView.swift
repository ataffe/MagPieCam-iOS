//
//  CameraLiveVideoView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/25/26.
//

import SwiftUI
import WebRTC
import os

struct CameraLiveVideoView: View {
    let camera: Camera
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var whepClient = WHEPClient(
        whepURL: URL(string: "http://10.0.0.53:8889/cam/whep")!
    )

    private var isLandscape: Bool { verticalSizeClass == .compact }

    private var isConnected: Bool {
        whepClient.connectionState == .connected
            || whepClient.connectionState == .completed
    }

    init(camera: Camera) {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(
                ofSize: Constants.UI.navTitleFontSize,
                weight: .semibold
            ),
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        self.camera = camera
    }

    private func requestLandscape() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let prefs = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscapeRight)
        scene.requestGeometryUpdate(prefs) { error in
            Logger.whepClient.error("Failed to rotate to landscape: \(error.localizedDescription)")
        }
    }

    private func requestPortrait() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let prefs = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)
        scene.requestGeometryUpdate(prefs) { error in
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
                    .aspectRatio(16 / 9, contentMode: .fit)
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
        .navigationTitle("\(camera.location) Live View")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(isLandscape ? .hidden : .visible, for: .navigationBar)
        .onAppear { whepClient.connect() }
        .onDisappear { whepClient.disconnect() }
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

#Preview {
    CameraLiveVideoView(
        camera: Camera(id: "testId", location: "Office", cameraPreviewUrl: nil)
    )
}
