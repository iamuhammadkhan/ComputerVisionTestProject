//
//  Predictor.swift
//  ComputerVisionTest
//
//  Created by Muhammad Khan on 8/1/21.
//

import Foundation
import Vision

protocol PredictorDelegate: NSObject {
    func predictor(_ predictor: Predictor, points: [CGPoint])
}

class Predictor {
    
    weak var delegate: PredictorDelegate?
    
    func estimation(sampleBuffer: CMSampleBuffer) {
        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up)
        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Error:", error)
        }
    }
    
    func bodyPoseHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
        
        observations.forEach { processObservation($0) }
    }
    
    func processObservation(_ observation: VNHumanBodyPoseObservation) {
        do {
            let recognizedPoints = try observation.recognizedPoints(forGroupKey: .all)
            let displayPoints = recognizedPoints.map {
                CGPoint(x: $0.value.x, y: 1 - $0.value.y)
            }
            
            delegate?.predictor(self, points: displayPoints)
        } catch {
            print("Error:", error)
        }
    }
}
