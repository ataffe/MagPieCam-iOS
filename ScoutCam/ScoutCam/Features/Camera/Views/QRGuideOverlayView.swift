//
//  QRGuideOverlayView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/23/26.
//

import SwiftUI

struct QRGuideOverlayView: View {
    private let guideSize: CGFloat = 250
    private let cornerLength: CGFloat = 28
    private let cornerRadius: CGFloat = 4
    private let lineWidth: CGFloat = 4

    var body: some View {
        GeometryReader { geo in
            let origin = CGPoint(
                x: (geo.size.width - guideSize) / 2,
                y: (geo.size.height - guideSize) / 2
            )
            let guideRect = CGRect(origin: origin, size: CGSize(width: guideSize, height: guideSize))

            // Dimmed surround with a transparent cutout
            Path { path in
                path.addRect(CGRect(origin: .zero, size: geo.size))
                path.addRoundedRect(
                    in: guideRect,
                    cornerRadii: RectangleCornerRadii(
                        topLeading: cornerRadius, bottomLeading: cornerRadius,
                        bottomTrailing: cornerRadius, topTrailing: cornerRadius
                    )
                )
            }
            .fill(.black.opacity(0.55), style: FillStyle(eoFill: true))

            // Corner brackets
            Path { path in
                let corners: [(CGPoint, CGPoint, CGPoint)] = [
                    // top-left
                    (
                        CGPoint(x: guideRect.minX + cornerLength, y: guideRect.minY),
                        CGPoint(x: guideRect.minX, y: guideRect.minY),
                        CGPoint(x: guideRect.minX, y: guideRect.minY + cornerLength)
                    ),
                    // top-right
                    (
                        CGPoint(x: guideRect.maxX - cornerLength, y: guideRect.minY),
                        CGPoint(x: guideRect.maxX, y: guideRect.minY),
                        CGPoint(x: guideRect.maxX, y: guideRect.minY + cornerLength)
                    ),
                    // bottom-left
                    (
                        CGPoint(x: guideRect.minX, y: guideRect.maxY - cornerLength),
                        CGPoint(x: guideRect.minX, y: guideRect.maxY),
                        CGPoint(x: guideRect.minX + cornerLength, y: guideRect.maxY)
                    ),
                    // bottom-right
                    (
                        CGPoint(x: guideRect.maxX, y: guideRect.maxY - cornerLength),
                        CGPoint(x: guideRect.maxX, y: guideRect.maxY),
                        CGPoint(x: guideRect.maxX - cornerLength, y: guideRect.maxY)
                    ),
                ]
                for (start, corner, end) in corners {
                    path.move(to: start)
                    path.addLine(to: corner)
                    path.addLine(to: end)
                }
            }
            .stroke(.white, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
        }
    }
}

#Preview {
    QRGuideOverlayView()
}
