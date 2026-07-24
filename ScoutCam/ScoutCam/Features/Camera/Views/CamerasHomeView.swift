//
//  CamerasHomeView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import SwiftUI

struct CamerasHomeView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State var cameraHomeViewModel: CameraHomeViewModel

    private var cameras: [Camera] { dependencies.cameraStore.cameras }

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    init(cameraService: CameraService) {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 25, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.systemBlue]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        cameraHomeViewModel = CameraHomeViewModel(cameraService: cameraService)
    }

    var body: some View {
        NavigationStack {
            Divider()
            if cameraHomeViewModel.isLoading {
                ProgressView()
                Text("Loading Cameras...")
            }
            ScrollView {
                ForEach(cameras) { camera in
                    NavigationLink(destination: CameraDetailView(camera: camera)) {
                        CameraCardView(camera: camera)
                    }
                    .buttonStyle(.plain)
                }.padding(.horizontal)

                NavigationLink(
                    destination: QRScannerView(
                        qrScannerViewModel: QRScannerViewModel(
                            cameraService: dependencies.cameraService
                        )
                    )
                ) {
                    AddCameraCard()
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
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
            }
        }.onAppear {
            Task {
                await cameraHomeViewModel.getCameras()
            }
        }
    }
}



private struct AddCameraCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.secondarySystemBackground))
            .frame(height: 120)
            .overlay(
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(.secondary)
            )
            .padding(5)
    }
}

#Preview {
    let deps = AppDependencies()
    deps.cameraStore.cameras = [
        Camera(id: "cam-preview-001", location: "Front Door"),
        Camera(id: "cam-preview-002", location: "Backyard"),
    ]
    return CamerasHomeView(cameraService: deps.cameraService)
        .environment(deps)
}
