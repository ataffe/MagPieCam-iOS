//
//  QRScannerView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import SwiftUI
import CodeScanner
internal import AVFoundation

struct QRScannerView: View {
    @State var qrScannerViewModel: QRScannerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        CodeScannerView(
            codeTypes: [.qr],
            simulatedData: "Test string 12345.",
            completion: qrScannerViewModel.handleScanResult
        )
        .overlay { QRGuideOverlayView() }
        .overlay {
            if qrScannerViewModel.isLoading {
                ProgressView("Registering camera…")
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .overlay(alignment: .top) {
            Text("Scan the QR code on your Scout Camera.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                .padding(.top)
        }
        .navigationTitle("Add a Camera")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: qrScannerViewModel.didSuccessfullyClaim) { _, succeeded in
            if succeeded { dismiss() }
        }
        .sheet(isPresented: $qrScannerViewModel.isShowingLocationPrompt,
               onDismiss: qrScannerViewModel.cancelClaim) {
            LocationPromptSheetView(viewModel: qrScannerViewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    QRScannerView(
        qrScannerViewModel: QRScannerViewModel(
            cameraService: AppDependencies().cameraService
        )
    )
}
