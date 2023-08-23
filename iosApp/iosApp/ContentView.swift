import SwiftUI
import shared

struct ContentView: View {
    @ObservedObject private(set) var viewModel: ViewModel
    @ObservedObject private(set) var mapViewModel: MapCanvasViewModel = MapCanvasViewModel(measurements: [])

    var body: some View {
        ScrollView(.vertical) {
            
            Button("Init data") {
                viewModel.initData()
            }
                .buttonStyle(.borderedProminent)
                .padding()
            
            Picker("Select a paint color", selection: $viewModel.selection) {
                ForEach(viewModel.choices, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.menu)
            
            Button("Fetch data") {
                viewModel.debugText = "---"
                viewModel.fetchMeasurements(mapViewModel: mapViewModel)
            }
                .buttonStyle(.borderedProminent)

            
            MapCanvas(viewModel: mapViewModel)
                .padding()
                .padding()
            
            Text(viewModel.debugText)
                .padding()
        }
    }
}

extension ContentView {
    
    class ViewModel: ObservableObject {
        
        @Published var text = "Loading..."
        @Published var debugText = "---"
        @Published var choices: [String] = []
        @Published var selection: String = ""

        var controller: MicroclimateDataController = MicroclimateDataController()
        
        func initData() {
            controller.initializeLocations { error in
                DispatchQueue.main.async {
                    let data = self.controller.getMeasuredValues()
                    self.choices = data.map{ $0.measure }
                    self.selection = self.choices.first ?? ""
                }
            }
        }
        
        func fetchMeasurements(mapViewModel: MapCanvasViewModel) {
            guard self.choices != [] else { return }
            
            controller.getDataMeasurements(measuredValue: self.selection, from: "2023-08-22T18:03:42.588Z", to: "2023-08-22T18:13:42.588Z") { result, error in
                DispatchQueue.main.async {
                    if let result = result {
                        self.debugText = result.map { "\($0.value) \($0.measuredValue.unit)   \($0.location.latitude), \($0.location.longitude)" }.joined(separator: "\n")
                        mapViewModel.measurements.removeAll()
                        mapViewModel.measurements.append(contentsOf: result)
                        mapViewModel.initializeCanvasData()
                    } else {
                        self.debugText = error?.localizedDescription ?? "error"
                    }
                }
            }
        }
    }
}