//
//  CameraDetailView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import SwiftUI

struct CameraDetailView: View {
    let camera: Camera
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.colorScheme) private var colorScheme
    @State private var notificationsViewModel: RecentNotificationsViewModel?

    private let actionColumns = [GridItem(.flexible()), GridItem(.flexible())]

    private var previewImage: UIImage? {
        dependencies.cameraStore.previewImages[camera.id]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                liveViewCard
                actionGrid
                recentNotificationsSection
            }
            .padding(.bottom)
        }
        .navigationTitle(camera.location)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Settings", systemImage: "gearshape.fill") {
                    print("Settings sheet")
                }
                .buttonStyle(.borderless)
            }
        }
        .background(
            Constants.UI.backgroundGradient(for: colorScheme).ignoresSafeArea()
        )
        .task {
            guard notificationsViewModel == nil else { return }
            let vm = RecentNotificationsViewModel(
                cameraId: camera.id,
                notificationService: dependencies.notificationService
            )
            notificationsViewModel = vm
            await vm.loadInitial()
        }
    }

    // MARK: - Sections

    private var liveViewCard: some View {
        NavigationLink(
            destination: CameraStreamingView(camera: camera)
        ) {
            if let previewImage {
                CameraDetailPreviewCardView(
                    previewImage: previewImage,
                    location: camera.location
                )
            } else {
                CameraDetailButton(image: Image(systemName: "video")) {
                    Text("Go Live")
                }
                .foregroundStyle(.red)
            }
        }
        .buttonStyle(.plain)
    }

    private var actionGrid: some View {
        LazyVGrid(columns: actionColumns, spacing: 12) {
            NavigationLink(
                destination: NotificationRulesView(
                    rulesViewModel: RulesViewModel(
                        camera: camera,
                        rulesService: dependencies.rulesService
                    )
                )
            ) {
                CameraDetailButton(
                    image: Image(systemName: "sparkle.text.clipboard"),
                    imageColor: Color.blue
                ) {
                    Text("Smart Alerts")
                }
            }
            .buttonStyle(.plain)

            CameraDetailButton(
                image: Image(systemName: "bell.fill"),
                imageColor: Color.yellow
            ) {
                Text("Notifications")
            }

            CameraDetailButton(
                image: Image(systemName: "chart.xyaxis.line"),
                imageColor: Color.green
            ) {
                Text("Stats")
            }
        }
        .padding(.horizontal)
    }

    private var recentNotificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Notifications")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            if let notificationsViewModel {
                RecentNotificationView(viewModel: notificationsViewModel)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    let dependencies = AppDependencies()
    NavigationStack {
        CameraDetailView(
            camera: Camera(
                id: "cam-preview-001",
                location: "Living Room",
                cameraPreviewUrl: nil
            )
        )
    }
    .environment(dependencies)
}
