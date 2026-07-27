//
//  CameraDetailView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import SwiftUI

struct CameraDetailView: View {
    let camera: Camera
    let cameraService: CameraService
    let rulesService: RulesService
    @Environment(\.colorScheme) private var colorScheme

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    init(
        camera: Camera,
        cameraService: CameraService,
        rulesService: RulesService
    ) {
        self.camera = camera
        self.cameraService = cameraService
        self.rulesService = rulesService
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: Constants.UI.navTitleFontSize, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.systemBlue]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(destination: CameraLiveVideoView(camera: camera)) {
                    CameraDetailButton(image: Image(systemName: "video"))
                    {Text("Go Live")}
                        .foregroundStyle(Color.red)

                }
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
                CameraDetailButton(image: Image(systemName: "chart.xyaxis.line")) {
                    Text("Stats")
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
            
            Text("Recent Notifications")
                .font(.title2)
                .bold()
                .padding(.vertical)
            ScrollView {
                RecentNotificationView()
            }
        }
        .background(Constants.UI.backgroundGradient(for: colorScheme).ignoresSafeArea())
    }
    
    struct CameraDetailButton<TEXT: View> : View {
        let image: Image
        var imageHeight: CGFloat? = nil
        var buttonHeight: CGFloat = 130
        var buttonSpacing: CGFloat? = nil
        var imageTextPadding: CGFloat = 10
        @ViewBuilder let text: TEXT

        var body: some View {
            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                .fill(.clear)
            .frame(height: buttonHeight)
            .overlay(
                VStack(spacing: buttonSpacing) {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: imageHeight)
                    text
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color.primary)
                        .padding(.top, imageTextPadding)
                }
                .padding()
            )
            .glassEffect(in: .rect(cornerRadius: Constants.UI.cardCornerRadius))
            .padding(.vertical, 3)
            .padding(.horizontal)
        }
    }
}

#Preview {
    let dependencies = AppDependencies()
    NavigationStack {
        CameraDetailView(
            camera: Camera(
                id: "cam-preview-001",
                location: "living room".capitalized
            ),
            cameraService: dependencies.cameraService,
            rulesService: dependencies.rulesService
        )
    }
}
