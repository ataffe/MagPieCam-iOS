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
            .font: UIFont.systemFont(ofSize: Constants.UI.navTitleFontSize, weight: .semibold)
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
                    NavigationLink(
                        destination: CameraDetailView(
                            camera: camera,
                            cameraService: dependencies.cameraService,
                            rulesService: dependencies.rulesService
                        )
                    ) {
                        CameraCardView(camera: camera)
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
                ToolbarItem(placement: .topBarLeading) {
                    QRScannerNavLink(
                        cameraService: dependencies.cameraService) {
                            Image(systemName: "plus")
                        }
                }
            }
        }.onAppear {
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
    
    private struct AddCameraCard: View {
        var body: some View {
            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                .fill(Color(.secondarySystemBackground))
                .frame(height: 120)
                .overlay(
                    Image(systemName: "plus.square")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(.secondary)
                )
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                .padding(5)
        }
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
