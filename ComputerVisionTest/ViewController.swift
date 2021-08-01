//
//  ViewController.swift
//  ComputerVisionTest
//
//  Created by Muhammad Khan on 8/1/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    let videoCapture = VideoCapture()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var pointsLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoPreview()
    }

    private func setupVideoPreview() {
        videoCapture.startCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
        
        guard let previewLayer = previewLayer else { return }
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        videoCapture.predictor.delegate = self
        
        view.layer.addSublayer(pointsLayer)
        pointsLayer.frame = view.frame
        pointsLayer.strokeColor = UIColor.green.cgColor
    }
}

extension ViewController: PredictorDelegate {
    func predictor(_ predictor: Predictor, points: [CGPoint]) {
        guard let previewLayer = previewLayer else { return }
        
        let convertedPoints = points.map {
            previewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
        }
        let combinedPath = CGMutablePath()
        
        for point in convertedPoints {
            let dotPath = UIBezierPath(ovalIn: CGRect(x: point.x, y: point.y, width: 10, height: 10))
            combinedPath.addPath(dotPath.cgPath)
        }
        pointsLayer.path = combinedPath
        DispatchQueue.main.async { [weak self] in
            self?.pointsLayer.didChangeValue(for: \.path)
        }
    }
}
