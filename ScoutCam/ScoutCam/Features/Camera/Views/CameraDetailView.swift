//
//  CameraDetailView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import SwiftUI

struct CameraDetailView: View {
    let camera: Camera
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    init(camera: Camera) {
        self.camera = camera
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 25, weight: .semibold)
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
                CameraDetailButton(image: Image(systemName: "checklist.checked")) {Text("Rules")}
                CameraDetailButton(image: Image(systemName: "bell.fill")) {
                    Text("Notifications")
                }
            }
            CameraDetailButton(image: Image(systemName: "chart.xyaxis.line")) {
                Text("Stats")
            }
            .navigationTitle(camera.location)
            .navigationBarTitleDisplayMode(.inline)
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
            RoundedRectangle(cornerRadius: 12)
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
            RoundedRectangle(cornerRadius: 12)
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
            .padding(.vertical, 3)
            .padding(.horizontal)
        }
    }
}

#Preview {
    NavigationStack {
        CameraDetailView(
            camera: Camera(
                id: "cam-preview-001",
                location: "living room".capitalized
            )
        )
    }
}
