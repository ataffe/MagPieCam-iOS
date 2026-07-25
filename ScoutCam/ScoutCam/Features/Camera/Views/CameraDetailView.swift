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
            CameraDetailButton(image: Image(systemName: "video"))
            {Text("Go Live")}
                .foregroundStyle(Color.red)
                .padding(.horizontal)
            
            Divider()
            LazyVGrid(columns: columns, spacing: 16) {
                NavigationLink(
                    destination: RulesView(
                        rulesViewModel: RulesViewModel(
                            camera: camera,
                            rulesService: rulesService
                        )
                    )
                ) {
                    CameraDetailButton(image: Image(systemName: "checklist.checked")) {Text("Rules")}
                }
                CameraDetailButton(image: Image(systemName: "bell.fill")) {
                    Text("Notifications")
                }
            }
            CameraDetailButton(image: Image(systemName: "chart.xyaxis.line")) {
                Text("Stats")
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
                RecentNotificationCard()
            }
        }
    }
    
    struct RecentNotificationCard: View {
        var body: some View {
            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                .fill(Color(.secondarySystemBackground))
                .frame(height: 70)
                .overlay(
                    HStack(alignment: .center) {
                        VStack {
                            Text("Rule")
                                .font(.headline)
                                .underline()
                                .padding(.bottom, 5)
                            Text("Cat in kitchen")
                        }
                        .frame(maxWidth: .infinity)
                        Divider()
                        VStack {
                            Text("Date: 07/24/2026")
                                .font(.headline)
                            Text("Time:  @ 10:00PM")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                    }
                )
        }
    }
    
    struct CameraDetailButton<TEXT: View> : View {
        let image: Image
        @ViewBuilder let text: TEXT

        var body: some View {
            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
            .fill(Color(.secondarySystemBackground))
            .frame(height: 130)
            .overlay(
                VStack {
                    image
                        .resizable()
                        .scaledToFit()
                    text
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color.primary)
                        .padding(.top, 10)
                }
                .padding()
            )
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
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
