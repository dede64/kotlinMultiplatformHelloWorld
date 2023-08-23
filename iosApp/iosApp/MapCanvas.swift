//
//  MapCanvas.swift
//  iosApp
//
//  Created by Dan Ridzon on 22.08.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import shared

struct MapCanvas: View {
    /**
     Renders fetched measurements on the canvas as points based on the longitude and latitude of the real weather stations.
     */

    @ObservedObject var viewModel: MapCanvasViewModel
    
    var body: some View {
        
        Canvas { context, size in
            
            // MARK: - Point rendering
            for canvasPoint in viewModel.getCanvasPoints() {
                
                // Points have coordinates as floats in range 0...1, so they need to be scaled to the canvas.
                let circleCenter = CGPoint(x: canvasPoint.x * size.width, y: canvasPoint.y * size.height)

                let circleRadius = 2.0
                let circleRect = CGRect(
                    x: circleCenter.x - circleRadius,
                    y: circleCenter.y - circleRadius,
                    width: circleRadius * 2,
                    height: circleRadius * 2
                )
               
               // Draw the circle
                context.stroke(
                    Path(ellipseIn: circleRect),
                    
                    // Color of the point is based on the measurement value.
                    with: .color(
                        red: canvasPoint.value,
                        green: 0.2,
                        blue: 1.0 - canvasPoint.value),
                    lineWidth: 5
                )
           }
        }
        .aspectRatio(1, contentMode: .fit)
        .border(Color.blue)
        .onAppear{
            viewModel.initializeCanvasData()
        }
    }
}

struct CanvasPoint {
    let x: CGFloat
    let y: CGFloat
    let value: CGFloat
}

class MapCanvasViewModel: ObservableObject {
    
    @Published var measurements: [DataMeasurement] = []
    
    private var minX: Double = 0
    private var maxX: Double = 0
    private var minY: Double = 0
    private var maxY: Double = 0
    private var minVal: Double = 0
    private var maxVal: Double = 0
    private var scaleFactor: Double = 1
    
    init(measurements: [DataMeasurement]) {
        self.measurements = measurements
    }
    
    func initializeCanvasData(){
        
        // Get min and max values from all the measurements.
        minX = Double(measurements.min { $0.location.longitude < $1.location.longitude}?.location.longitude ?? 0.0)
        maxX = Double(measurements.max { $0.location.longitude < $1.location.longitude}?.location.longitude ?? 0.0)
        minY = Double(measurements.min { $0.location.latitude < $1.location.latitude}?.location.latitude ?? 0.0)
        maxY = Double(measurements.max { $0.location.latitude < $1.location.latitude}?.location.latitude ?? 0.0)
        minVal = Double(measurements.min { $0.value < $1.value }?.value ?? 0.0)
        maxVal = Double(measurements.max { $0.value < $1.value }?.value ?? 0.0)
        
        let width = maxX - minX
        let height = maxY - minY
        
        // The minimum and maximum values are slightly modified, so there is an empty border on the edge of the canvas.
        minX -= width * 0.2
        maxX += width * 0.2
        minY -= height * 0.2
        maxY += height * 0.2
        
        // Because the map should be scaled by the same amount on both axes - the length of the longer side is used as scale value
        scaleFactor = [maxX - minX, maxY - minY].max()!
    }
    
    func getCanvasPoints() -> [CanvasPoint] {
        /**
         Converts fetched measurements to the canvas points.
         */
        
        var result: [CanvasPoint] = []
        
        for measurement in measurements {
            
            // Converts real world coordinates to values between 0 and 1 (same for the measurement value, which is used for color gradient)
            let x: Double = (Double(measurement.location.longitude) - minX) / scaleFactor + ((scaleFactor + minX - maxX) / (2 * scaleFactor))
            let y: Double = 1.0 - ((Double(measurement.location.latitude) - minY) / scaleFactor + ((scaleFactor + minY - maxY) / (2 * scaleFactor)))
            let value: Double = (Double(measurement.value) - minVal) / (maxVal - minVal)
            
            result.append(CanvasPoint(
                x: CGFloat(x),
                y: CGFloat(y),
                value: CGFloat(value)
            ))
        }
        return result
    }
}

struct MapCanvas_Previews: PreviewProvider {
    
    static var dummyMeasuredValue = MicroclimateMeasuredValue(
        measure: "temperature",
        title: "teplota",
        unit: "C"
    )
    
    static var previews: some View {
        MapCanvas(
            viewModel: MapCanvasViewModel(
                measurements: [
                    DataMeasurement(
                        value: 10,
                        measuredValue: dummyMeasuredValue,
                        location: MicroclimatePoint(
                            latitude: 14,
                            longitude: 10,
                            pointID: 0, locationID: 0, measuredValues: []
                        )
                    ),
                    DataMeasurement(
                        value: 15,
                        measuredValue: dummyMeasuredValue,
                        location: MicroclimatePoint(
                            latitude: 17,
                            longitude: 1,
                            pointID: 0, locationID: 0, measuredValues: []
                        )
                    ),
                    DataMeasurement(
                        value: 3,
                        measuredValue: dummyMeasuredValue,
                        location: MicroclimatePoint(
                            latitude: 5,
                            longitude: -2,
                            pointID: 0, locationID: 0, measuredValues: []
                        )
                    ),
                    DataMeasurement(
                        value: 12,
                        measuredValue: dummyMeasuredValue,
                        location: MicroclimatePoint(
                            latitude: -7,
                            longitude: 126,
                            pointID: 0, locationID: 0, measuredValues: []
                        )
                    ),
                ]
            )
        )
    }
}
