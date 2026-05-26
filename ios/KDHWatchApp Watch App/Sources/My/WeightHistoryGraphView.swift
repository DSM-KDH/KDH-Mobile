#if os(watchOS)
//
//  WeightHistoryGraphView.swift
//  Runner
//

import SwiftUI

struct MonthlyWeightPoint: Identifiable {
    let id = UUID()
    let monthLabel: String
    let date: Date
    let weight: Double
}

struct WeightHistoryGraph: View {
    let points: [MonthlyWeightPoint]

    var body: some View {
        let values = points.map(\.weight)
        let minWeight = floor(values.min() ?? 0)
        let maxWeight = ceil(values.max() ?? 0)
        let padding: Double = (maxWeight - minWeight) < 10 ? 3 : 5
        let yMin = minWeight - padding
        let yMax = maxWeight + padding

        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { proxy in
                let chartHeight = max(proxy.size.height - 24, 1)
                let chartWidth = max(proxy.size.width, 1)
                let rows = 4
                let columns = max(points.count - 1, 1)

                ZStack(alignment: .topLeading) {
                    ForEach(0...rows, id: \.self) { row in
                        let y = chartHeight * CGFloat(row) / CGFloat(rows)
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: chartWidth, y: y))
                        }
                        .stroke(
                            Color.gray300.opacity(0.45),
                            style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                        )
                    }

                    ForEach(0...columns, id: \.self) { col in
                        let x = chartWidth * CGFloat(col) / CGFloat(columns)
                        Path { path in
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: chartHeight))
                        }
                        .stroke(
                            Color.gray300.opacity(0.35),
                            style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                        )
                    }

                    weightAreaPath(
                        chartWidth: chartWidth,
                        chartHeight: chartHeight,
                        yMin: yMin,
                        yMax: yMax
                    )
                    .fill(Color.red200.opacity(0.28))

                    weightLinePath(
                        chartWidth: chartWidth,
                        chartHeight: chartHeight,
                        yMin: yMin,
                        yMax: yMax
                    )
                    .stroke(Color.red300, lineWidth: 2)

                    ForEach(Array(points.enumerated()), id: \.element.id) { idx, point in
                        Circle()
                            .fill(Color.red300)
                            .frame(width: 6, height: 6)
                            .position(
                                x: xPosition(index: idx, width: chartWidth),
                                y: yPosition(
                                    weight: point.weight,
                                    min: yMin,
                                    max: yMax,
                                    height: chartHeight
                                )
                            )
                    }
                }
            }
            .frame(height: 130)

            HStack {
                ForEach(points) { point in
                    Text(point.monthLabel)
                        .font(.kdf(.caption5))
                        .foregroundStyle(.gray500)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, 8)
        .padding(.horizontal, 8)
        .padding(.bottom, 10)
        .background(Color.red50)
        .cornerRadius(16)
    }

    private func xPosition(index: Int, width: CGFloat) -> CGFloat {
        guard points.count > 1 else { return width / 2 }
        return width * CGFloat(index) / CGFloat(points.count - 1)
    }

    private func yPosition(
        weight: Double,
        min: Double,
        max: Double,
        height: CGFloat
    ) -> CGFloat {
        let span = max - min
        guard span > 0 else { return height / 2 }
        let ratio = (weight - min) / span
        return height * CGFloat(1 - ratio)
    }

    private func weightLinePath(
        chartWidth: CGFloat,
        chartHeight: CGFloat,
        yMin: Double,
        yMax: Double
    ) -> Path {
        Path { path in
            guard !points.isEmpty else { return }

            for idx in points.indices {
                let x = xPosition(index: idx, width: chartWidth)
                let y = yPosition(
                    weight: points[idx].weight,
                    min: yMin,
                    max: yMax,
                    height: chartHeight
                )

                if idx == points.startIndex {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
    }

    private func weightAreaPath(
        chartWidth: CGFloat,
        chartHeight: CGFloat,
        yMin: Double,
        yMax: Double
    ) -> Path {
        Path { path in
            guard !points.isEmpty else { return }

            for idx in points.indices {
                let x = xPosition(index: idx, width: chartWidth)
                let y = yPosition(
                    weight: points[idx].weight,
                    min: yMin,
                    max: yMax,
                    height: chartHeight
                )

                if idx == points.startIndex {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }

            if let last = points.indices.last {
                path.addLine(
                    to: CGPoint(
                        x: xPosition(index: last, width: chartWidth),
                        y: chartHeight
                    )
                )
            }

            path.addLine(to: CGPoint(x: 0, y: chartHeight))
            path.closeSubpath()
        }
    }
}
#endif
