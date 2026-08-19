//
//  CameraDetailView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import SwiftUI

struct CameraDetailView: View {
    let camera: Camera
    var initialNotificationId: String? = nil
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.colorScheme) private var colorScheme
    @State private var notificationsViewModel: RecentNotificationsViewModel?
    @State private var cameraLocation: String
    @State private var navigateToNotifications = false
    @State private var notificationScrollTarget: String? = nil
    @State private var isShowingSettings = false

    init(camera: Camera, initialNotificationId: String? = nil) {
        self.camera = camera
        self.initialNotificationId = initialNotificationId
        self._cameraLocation = State(initialValue: camera.location)
    }

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
        .navigationTitle(cameraLocation)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Settings", systemImage: "gearshape.fill") {
                    isShowingSettings = true
                }
                .buttonStyle(.borderless)
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            CameraSettingsSheetView(
                camera: camera,
                cameraService: dependencies.cameraService,
                onSave: { newLocation in cameraLocation = newLocation }
            )
            .presentationDetents([PresentationDetent.medium])
        }
        .background(
            Constants.UI.backgroundGradient(for: colorScheme).ignoresSafeArea()
        )
        .navigationDestination(isPresented: $navigateToNotifications) {
            NotificationsView(cameraId: camera.id, scrollToId: notificationScrollTarget)
        }
        .onAppear {
            if let id = initialNotificationId, !navigateToNotifications {
                notificationScrollTarget = id
                navigateToNotifications = true
            }
            Task {
                if notificationsViewModel == nil {
                    notificationsViewModel = RecentNotificationsViewModel(
                        cameraId: camera.id,
                        notificationService: dependencies.notificationService
                    )
                }
                await notificationsViewModel?.loadInitial()
                notificationsViewModel?.startPolling()
            }
        }
        .onDisappear {
            notificationsViewModel?.stopPolling()
        }
    }

    // MARK: - Sections

    private var liveViewCard: some View {
        CameraLiveViewCard(camera: camera, previewImage: previewImage)
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

            NavigationLink(
                destination: NotificationsView(cameraId: camera.id)
            ) {
                CameraDetailButton(
                    image: Image(systemName: "bell.fill"),
                    imageColor: Color.yellow
                ) {
                    Text("Notifications")
                }
            }
            .buttonStyle(.plain)

//            CameraDetailButton(
//                image: Image(systemName: "chart.xyaxis.line"),
//                imageColor: Color.green
//            ) {
//                Text("Stats")
//            }
        }
        .padding(.horizontal)
    }

    private var recentNotificationsSection: some View {
        RecentNotificationsSectionView(notificationsViewModel: notificationsViewModel) { tapped in
            notificationScrollTarget = tapped.publicNotificationId
            navigateToNotifications = true
        }
    }
}

#Preview {
    let dependencies = AppDependencies()
    NavigationStack {
        CameraDetailView(
            camera: Camera(
                id: "cam-preview-001",
                location: "Living Room",
                cameraPreviewUrl: nil,
                previewUpdatedAt: nil
            )
        )
    }
    .environment(dependencies)
}
