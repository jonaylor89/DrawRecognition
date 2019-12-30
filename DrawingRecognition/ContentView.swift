//
//  ContentView.swift
//  DrawingRecognition
//
//  Created by John Naylor on 12/29/19.
//  Copyright © 2019 John Naylor. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var imagePickerOpen: Bool = false
    @State private var cameraOpen: Bool = false
    @State private var image: UIImage? = nil
    @State private var classification: String? = nil
    
    private let classifier = DrawingClassifierModel()
    private let placeholderImage = UIImage(named: "placeholder")!
    
    private var cameraEnabled: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    private var classificationEnabled: Bool {
        image != nil && classification == nil
    }
    
    var body: some View {
        if imagePickerOpen { return imagePickerView() }
        if cameraOpen { return cameraView() }
        
        return mainView()
    }
    
    private func classify() {
        print("Analysing drawing...")
        classifier.classify(self.image) { result in
            self.classification = result?.icon
        }
    }
    
    private func controlReturned(image: UIImage?) {
        print("Image return \(image == nil ? "failure" : "success")...")
        
        self.image = classifier.configure(image: image)
    }
    
    private func summonImagePicker() {
        print("Summoning ImagePicker...")
        imagePickerOpen = true
    }
    
    private func summonCamera() {
        print("Summoning Camera...")
        cameraOpen = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
    private func mainView() -> AnyView {
        return AnyView(NavigationView {
            MainView(
                image: image ?? placeholderImage,
                text: "\(classification ?? "Nothing detected")"
            )
            {
                TwoStateButton(
                    text: "Classify",
                    disabled: !classificationEnabled,
                    action: classify
                )
            }
            .padding()
            .navigationBarTitle(Text("Detect Drawings"), displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: summonImagePicker) {
                    Text("Select")
                },
                trailing: Button(action: summonCamera) {
                    Image(systemName: "camera")
                }.disabled(!cameraEnabled)
            )
        })
    }
    
    private func imagePickerView() -> AnyView {
        return AnyView(ImagePicker { result in
            self.classification = nil
            self.controlReturned(image: result)
            self.imagePickerOpen = false
        })
    }
    
    private func cameraView() -> AnyView {
        return AnyView(ImagePicker(camera: true) { result in
            self.classification = nil
            self.controlReturned(image: result)
            self.cameraOpen = false
        })
    }
    
    
}
