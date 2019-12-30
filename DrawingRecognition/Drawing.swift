//
//  Drawing.swift
//  DrawingRecognition
//
//  Created by John Naylor on 12/30/19.
//  Copyright © 2019 John Naylor. All rights reserved.
//

import Foundation
import UIKit
import Vision

enum Drawing: String, CaseIterable {
    case apple, banana, bread, broccoli, cake, carrot, coffee, cookie
    case donut, grapes, hotdog, icecream, lollipop, mushroom, peanut, pear
    case pineapple, pizza, potato, sandwich, steak, strawberry, watermelon
    
    init?(rawValue: String) {
        if let match = Drawing.allCases.first(where: { $0.rawValue == rawValue }) {
            self = match
        } else {
            switch rawValue {
            case "coffee cup": self = .coffee
            case "hot dog": self = .hotdog
            case "ice cream": self = .icecream
            default: return nil
            }
        }
    }
    
    var icon: String {
        switch self {
            case .apple: return "🍎"
            case .banana: return "🍌"
            case .bread: return "🍞"
            case .broccoli: return "🥦"
            case .cake: return "🎂"
            case .carrot: return "🥕"
            case .coffee: return "☕️"
            case .cookie: return "🍪"
            case .donut: return "🍩"
            case .grapes: return "🍇"
            case .hotdog: return "🌭"
            case .icecream: return "🍦"
            case .lollipop: return "🍭"
            case .mushroom: return "🍄"
            case .peanut: return "🥜"
            case .pear: return "🍐"
            case .pineapple: return "🍍"
            case .pizza: return "🍕"
            case .potato: return "🥔"
            case .sandwich: return "🥪"
            case .steak: return "🥩"
            case .strawberry: return "🍓"
            case .watermelon: return "🍉"
        }
    }
}

extension VNImageRequestHandler {
    convenience init?(uiImage: UIImage) {
        guard let ciImage = CIImage(image: uiImage) else { return nil }
        let orientation = uiImage.cgImageOrientation
        
        self.init(ciImage: ciImage, orientation: orientation)
    }
}

extension DrawingClassifierModel {
    func configure(image: UIImage?) -> UIImage? {
        if let rotatedImage = image?.fixOrientation(),
            let grayscaleImage = rotatedImage.applying(filter: CIFilter.noir),
            let brightenedImage = grayscaleImage.applying(filter: CIFilter.brighten(amount: 0.4)),
            let contrastedImage = brightenedImage.applying(filter: CIFilter.contrast(amount: 10.0)) {
            
            return contrastedImage
        }
        
        return nil
    }
    
    func classify(_ image: UIImage?, completion: @escaping (Drawing?) -> ()) {
        
        guard let image = image, let model = try? VNCoreMLModel(for: self.model) else { return completion(nil) }
        
        let request = VNCoreMLRequest(model: model)
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let handler = VNImageRequestHandler(uiImage: image) {
                try? handler.perform([request])
                
                let results = request.results as? [VNClassificationObservation]
                
                let highestResult = results?.max { $0.confidence < $1.confidence }
                
                print(results?.list ?? "")
                
                completion(Drawing(rawValue: highestResult?.identifier ?? ""))
            } else {
                completion(nil)
            }
        }
    }
}

extension Collection where Element == VNClassificationObservation {
    var list: String {
        var string = ""
        for element in self {
            string += "\(element.identifier): \(element.confidence * 100)%"
        }
        
        return string
    }
}
