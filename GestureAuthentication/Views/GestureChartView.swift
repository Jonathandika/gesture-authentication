//
//  GestureChartView.swift
//  GestureAuthentication
//
//  Created by Jonathan Andika on 27/01/24.
//

import SwiftUI
import Charts

struct GestureChartView: View {
    @ObservedObject var gestureModel: GestureModel

    var body: some View {
        
        Chart {
            ForEach(gestureModel.recordedData.indices, id: \.self) { index in
                LineMark(
                    x: .value("Index", index),
                    y: .value("X", gestureModel.recordedData[index].acceleration.x),
                    series: .value("Axis", "X")
                )
                .foregroundStyle(.red)

                LineMark(
                    x: .value("Index", index),
                    y: .value("Y", gestureModel.recordedData[index].acceleration.y),
                    series: .value("Axis", "Y")
                )
                .foregroundStyle(.green)

                LineMark(
                    x: .value("Index", index),
                    y: .value("Z", gestureModel.recordedData[index].acceleration.z),
                    series: .value("Axis", "Z")
                )
                .foregroundStyle(.blue)
            }
        }
        .chartLegend(position: .top, alignment: .leading, spacing: 8)
        .frame(height: 90)
    }
}
