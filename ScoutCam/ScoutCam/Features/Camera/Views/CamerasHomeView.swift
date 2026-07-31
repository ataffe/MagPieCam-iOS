//
//  CamerasHomeView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import SwiftUI

struct CamerasHomeView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.colorScheme) private var colorScheme
    @State var cameraHomeViewModel: CameraHomeViewModel

    private var cameras: [Camera] { dependencies.cameraStore.cameras }

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    init(cameraService: CameraService) {
        cameraHomeViewModel = CameraHomeViewModel(cameraService: cameraService)
    }

    var body: some View {
        NavigationStack {
            if cameraHomeViewModel.isLoading {
                ProgressView()
                Text("Loading Cameras...")
            }
            ScrollView {
                ForEach(cameras) { camera in
                    NavigationLink(destination: CameraDetailView(camera: camera)) {
                        CameraHomeCardView(
                            camera: camera,
                            previewImage: dependencies.cameraStore.previewImages[camera.id]
                        )
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                    }
                    .buttonStyle(.plain)
                }.padding(.horizontal)
                
                if cameras.isEmpty && !cameraHomeViewModel.isLoading {
                    QRScannerNavLink(
                        cameraService: dependencies.cameraService) {
                            AddCameraCard()
                        }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Cameras")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign Out") {
                        Task {
                            await dependencies.authService.logOut()
                        }
                    }
                    .foregroundStyle(.red)
                }
                if dependencies.cameraStore.cameras.count > 0 {
                    ToolbarItem(placement: .topBarLeading) {
                        QRScannerNavLink(
                            cameraService: dependencies.cameraService) {
                                Image(systemName: "plus")
                            }
                    }
                }
            }
            .background(Constants.UI.backgroundGradient(for: colorScheme).ignoresSafeArea())
        }
        .onAppear {
            Task {
                await cameraHomeViewModel.getUserCameras()
            }
        }
    }
    
    private struct QRScannerNavLink<CONTENT: View>: View {
        let cameraService: CameraService
        @ViewBuilder let content: CONTENT
        
        var body: some View {
            NavigationLink(
                destination: QRScannerView(
                    qrScannerViewModel: QRScannerViewModel(
                        cameraService: cameraService
                    )
                )
            ) {
                content
            }
        }
    }
}


#Preview {
    let deps = AppDependencies()
    deps.cameraStore.cameras = [
        Camera(
            id: "cam-preview-001",
            location: "Front Door",
            cameraPreviewUrl: nil
        ),
        Camera(
            id: "cam-preview-002",
            location: "Backyard",
            cameraPreviewUrl: nil
        ),
    ]
    return CamerasHomeView(cameraService: deps.cameraService)
        .environment(deps)
}
