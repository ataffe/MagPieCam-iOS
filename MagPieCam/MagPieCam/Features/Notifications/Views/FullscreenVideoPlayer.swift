//
//  FullscreenVideoPlayer.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 8/11/26.
//

import AVKit
import SwiftUI

struct FullscreenVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.videoGravity = .resizeAspect
        controller.showsPlaybackControls = true
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}

    final class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        private var dismissalTimer: Timer?

        func playerViewController(
            _ playerViewController: AVPlayerViewController,
            willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
        ) {
            AppDelegate.orientationLock = .landscapeRight
            let wasPlaying = playerViewController.player?.timeControlStatus == .playing
            coordinator.animate(alongsideTransition: nil) { _ in
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                scene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight)) { _ in }
                if wasPlaying {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        playerViewController.player?.play()
                    }
                }
            }
            startMonitoringForDismissal()
        }

        private func startMonitoringForDismissal() {
            dismissalTimer?.invalidate()
            // Poll the presentation chain — when the fullscreen AVPlayerViewController is gone, rotate back.
            // This is necessary because AVKit's fullscreen VC is a different instance from the inline one,
            // and its delegate callbacks are unreliable in UIViewControllerRepresentable contexts.
            dismissalTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] timer in
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return }
                var top: UIViewController = root
                while let next = top.presentedViewController { top = next }
                guard !(top is AVPlayerViewController) else { return }
                timer.invalidate()
                self?.dismissalTimer = nil
                AppDelegate.orientationLock = .portrait
                scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) { _ in }
            }
        }

        deinit {
            dismissalTimer?.invalidate()
        }
    }
}
