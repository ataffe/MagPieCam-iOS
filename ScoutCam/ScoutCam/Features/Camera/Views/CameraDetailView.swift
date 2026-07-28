//
//  CameraDetailView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import SwiftUI

struct CameraDetailView: View {
    let camera: Camera
    let previewImage: UIImage?
    let cameraService: CameraService
    let rulesService: RulesService
    @Environment(\.colorScheme) private var colorScheme

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    init(
        camera: Camera,
        previewImage: UIImage?,
        cameraService: CameraService,
        rulesService: RulesService
    ) {
        self.camera = camera
        self.previewImage = previewImage
        self.cameraService = cameraService
        self.rulesService = rulesService
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(
                ofSize: Constants.UI.navTitleFontSize,
                weight: .semibold
            ),
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.systemBlue
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(destination: CameraLiveVideoView(camera: camera))
                {
                    if let previewImage {
                        CameraDetailPreviewCardView(
                            previewImage: previewImage,
                            location: camera.location
                        )
                    } else {
                        CameraDetailButton(image: Image(systemName: "video")) {
                            Text("Go Live")
                        }
                        .foregroundStyle(Color.red)
                    }
                }
                ScrollView {
                    NavigationLink(
                        destination: NotificationRulesView(
                            rulesViewModel: RulesViewModel(
                                camera: camera,
                                rulesService: rulesService
                            )
                        )
                    ) {
                        CameraDetailButton(
                            image: Image(
                                "CatIconNoBackground"
                            ),
                            imageHeight: 80,
                            buttonHeight: 140,
                            buttonSpacing: 0,
                            imageTextPadding: 5,
                        ) {
                            Text("Tell me what to look for!")
                        }
                    }
                    CameraDetailButton(image: Image(systemName: "bell.fill")) {
                        Text("Notifications")
                    }
                    CameraDetailButton(
                        image: Image(systemName: "chart.xyaxis.line")
                    ) {
                        Text("Stats")
                    }
                    Text("Recent Notifications")
                        .font(.title2)
                        .bold()
                        .padding(.vertical)
                    RecentNotificationView()
                    
                }

            }
            .navigationTitle(camera.location)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings", systemImage: "gearshape.fill") {
                        print("Setting sheet")
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .background(
            Constants.UI.backgroundGradient(for: colorScheme).ignoresSafeArea()
        )
    }
}

#Preview {
    let dependencies = AppDependencies()
    NavigationStack {
        CameraDetailView(
            camera: Camera(
                id: "cam-preview-001",
                location: "living room".capitalized,
                cameraPreviewUrl: nil
            ),
            previewImage: nil,
            cameraService: dependencies.cameraService,
            rulesService: dependencies.rulesService
        )
    }
}
