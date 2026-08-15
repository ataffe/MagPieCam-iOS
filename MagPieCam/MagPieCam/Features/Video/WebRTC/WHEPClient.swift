//
//  WHEPClient.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/25/26.
//

import Foundation
import WebRTC
import os

extension Logger {
    nonisolated static let whepClient = Logger(
        subsystem: "scout.scoutcam",
        category: "whepClient"
    )
}

// MARK: - WHEP client

/// Connects to a MediaMTX WHEP endpoint (e.g. http://<pi-ip>:8889/cam/whep)
/// and exposes the resulting remote video track for SwiftUI to render.
@Observable
final class WHEPClient: NSObject {

    var remoteVideoTrack: RTCVideoTrack?
    var connectionState: RTCIceConnectionState = .new
    var isOffline: Bool = false
    var tokenProvider: (() async throws -> String?)?

    private let whepURL: URL

    // The factory is expensive to create, so it's shared across connections,
    // per stasel's own demo app.
    private static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let encoder = RTCDefaultVideoEncoderFactory()
        let decoder = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(
            encoderFactory: encoder,
            decoderFactory: decoder
        )
    }()

    private var peerConnection: RTCPeerConnection?

    init(whepURL: URL) {
        self.whepURL = whepURL
    }

    func connect() {
        let config = RTCConfiguration()
        //        config.iceServers = [RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])]
        config.iceServers = []
        config.sdpSemantics = .unifiedPlan
        // WHEP is non-trickle: gather all ICE candidates up front, then send
        // one complete offer. .gatherOnce matches that.
        config.continualGatheringPolicy = .gatherOnce

        let constraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: nil
        )

        guard
            let pc = Self.factory.peerConnection(
                with: config,
                constraints: constraints,
                delegate: self
            )
        else {
            Logger.whepClient.error("WHEP: failed to create peer connection")
            return
        }
        peerConnection = pc

        // recvOnly because WHEP is one-way "egress" — we're a viewer, not a publisher.
        let transceiverInit = RTCRtpTransceiverInit()
        transceiverInit.direction = .recvOnly
        _ = pc.addTransceiver(of: .video, init: transceiverInit)

        let offerConstraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: nil
        )
        pc.offer(for: offerConstraints) { [weak self] sdp, error in
            guard let self, let sdp else {
                Logger.whepClient.error(
                    "WHEP: offer failed: \(error?.localizedDescription ?? "unknown error")"
                )
                return
            }
            pc.setLocalDescription(sdp) { error in
                if let error {
                    Logger.whepClient.error(
                        "WHEP: setLocalDescription failed: \(error.localizedDescription)"
                    )
                    return
                }
                self.waitForGatheringComplete {
                    guard let finalSDP = pc.localDescription else { return }
                    self.postOffer(finalSDP)
                }
            }
        }
    }

    /// Polls for ICE gathering completion. Fine for a LAN test; a production
    /// version would drive this off the iceGatheringState delegate callback
    /// instead of polling.
    private func waitForGatheringComplete(_ completion: @escaping () -> Void) {
        func poll() {
            if self.peerConnection?.iceGatheringState == .complete {
                completion()
            } else {
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.1,
                    execute: poll
                )
            }
        }
        poll()
    }

    private func postOffer(_ localSDP: RTCSessionDescription, retryCount: Int = 0) {
        Task { [weak self] in
            guard let self else { return }
            var request = URLRequest(url: whepURL)
            request.httpMethod = "POST"
            request.setValue(
                "application/sdp",
                forHTTPHeaderField: "Content-Type"
            )
            if let token = try? await tokenProvider?() {
                request.setValue(
                    "Bearer \(token)",
                    forHTTPHeaderField: "Authorization"
                )
            }
            request.httpBody = localSDP.sdp.data(using: .utf8)

            do {
                let (data, response) = try await URLSession.shared.data(
                    for: request
                )
                guard let http = response as? HTTPURLResponse else { return }

                if http.statusCode == 404 {
                    if retryCount < 5 {
                        Logger.whepClient.info("WHEP: stream not ready (404), retrying (\(retryCount + 1)/5)...")
                        try? await Task.sleep(for: .seconds(2))
                        self.postOffer(localSDP, retryCount: retryCount + 1)
                    } else {
                        Logger.whepClient.error("WHEP: stream unavailable after \(retryCount) retries, camera is offline.")
                        await MainActor.run { self.isOffline = true }
                    }
                    return
                }

                guard (200..<300).contains(http.statusCode),
                    let sdpAnswer = String(data: data, encoding: .utf8)
                else {
                    Logger.whepClient.error("WHEP: server rejected offer: \(http.statusCode)")
                    return
                }

                let answer = RTCSessionDescription(
                    type: .answer,
                    sdp: sdpAnswer
                )
                self.peerConnection?.setRemoteDescription(answer) { error in
                    if let error {
                        Logger.whepClient.error(
                            "WHEP: setRemoteDescription failed: \(error.localizedDescription)"
                        )
                    }
                }
            } catch {
                Logger.whepClient.error(
                    "WHEP: post offer failed: \(error.localizedDescription)"
                )
            }
        }
    }

    func disconnect() {
        peerConnection?.close()
        peerConnection = nil
        remoteVideoTrack = nil
    }
}

extension WHEPClient: RTCPeerConnectionDelegate {

    // This is the one that matters: it fires when the remote video track
    // actually arrives on our recvOnly transceiver.
    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didStartReceivingOn transceiver: RTCRtpTransceiver
    ) {
        guard let track = transceiver.receiver.track as? RTCVideoTrack else {
            return
        }
        DispatchQueue.main.async {
            self.remoteVideoTrack = track
        }
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange newState: RTCIceConnectionState
    ) {
        DispatchQueue.main.async {
            self.connectionState = newState
        }
    }

    // Required by the protocol; unused for a receive-only WHEP client.
    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange stateChanged: RTCSignalingState
    ) {}
    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didAdd stream: RTCMediaStream
    ) {}
    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didRemove stream: RTCMediaStream
    ) {}
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}
    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange newState: RTCIceGatheringState
    ) {}
    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didGenerate candidate: RTCIceCandidate
    ) {}
    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didRemove candidates: [RTCIceCandidate]
    ) {}
    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didOpen dataChannel: RTCDataChannel
    ) {}
}
