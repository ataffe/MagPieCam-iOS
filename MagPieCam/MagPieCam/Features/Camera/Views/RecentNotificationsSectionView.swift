//
//  RecentNotificationsSectionView.swift
//  MagPieCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import SwiftUI

struct RecentNotificationsSectionView: View {
    let notificationsViewModel: RecentNotificationsViewModel?
    let onNotificationTapped: (NotificationResponse) -> Void

    @State private var confirmingClearAll = false
    @State private var clearAllFeedbackTrigger = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Notifications")
                    .font(.title2)
                    .bold()
                Spacer()
                if let notificationsViewModel, !notificationsViewModel.notifications.isEmpty {
                    Text(confirmingClearAll ? "Hold to confirm" : "Clear All")
                        .font(.subheadline)
                        .foregroundStyle(confirmingClearAll ? .red : .secondary)
                        .animation(.default, value: confirmingClearAll)
                        .onTapGesture {
                            confirmingClearAll = true
                        }
                        .onLongPressGesture {
                            guard confirmingClearAll else { return }
                            notificationsViewModel.clearAll()
                            clearAllFeedbackTrigger.toggle()
                            confirmingClearAll = false
                        }
                        .sensoryFeedback(.success, trigger: clearAllFeedbackTrigger)
                        .onDisappear { confirmingClearAll = false }
                }
            }
            .padding(.horizontal)
            if let notificationsViewModel {
                RecentNotificationView(viewModel: notificationsViewModel) { tapped in
                    onNotificationTapped(tapped)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding(.vertical)
    }
}
