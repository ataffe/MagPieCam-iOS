//
//  RecentNotificationsCard.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/27/26.
//

import SwiftUI

struct RecentNotificationView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
            .fill(.clear)
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
                    .border(.primary)
            )
    }
}

#Preview {
    RecentNotificationView()
}
