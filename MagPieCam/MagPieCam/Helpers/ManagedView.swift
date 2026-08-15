//
//  ManagedView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import SwiftUI

struct ManagedView<VM, Content: View>: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: VM?

    private let make: (AppDependencies) -> VM
    @ViewBuilder private let content: (VM) -> Content

    init(
        make: @escaping (AppDependencies) -> VM,
        @ViewBuilder content: @escaping (VM) -> Content
    ) {
        self.make = make
        self.content = content
    }

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel)
            } else {
                ProgressView()
            }
        }
        .onAppear { viewModel = viewModel ?? make(dependencies) }
    }
}
