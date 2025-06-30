import Flutter
import UIKit
import Vision
import VisionKit

@available(iOS 10.0, *)
public class ReceiptScannerPlugin: NSObject, FlutterPlugin {
    private var flutterResult: FlutterResult?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "receipt_scanner_plugin", binaryMessenger: registrar.messenger())
        let instance = ReceiptScannerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isAvailable":
            if #available(iOS 13.0, *) {
                result(VNDocumentCameraViewController.isSupported)
            } else {
                result(false)
            }
        case "scanImage":
            guard let args = call.arguments as? [String: Any],
                  let imagePath = args["imagePath"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Image path is required", details: nil))
                return
            }
            scanImageWithVision(imagePath: imagePath, result: result)
        case "scanDocument":
            if #available(iOS 13.0, *) {
                self.flutterResult = result
                presentDocumentScanner()
            } else {
                result(FlutterError(code: "UNSUPPORTED", message: "VisionKit is not available", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func scanImageWithVision(imagePath: String, result: @escaping FlutterResult) {
        guard let image = UIImage(contentsOfFile: imagePath),
              let cgImage = image.cgImage else {
            result(FlutterError(code: "INVALID_IMAGE", message: "Could not load image", details: nil))
            return
        }
        
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                result("")
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }
            
            result(recognizedStrings.joined(separator: "\n"))
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            result(FlutterError(code: "VISION_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    @available(iOS 13.0, *)
    private func presentDocumentScanner() {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = self
        
        guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
            flutterResult?(FlutterError(code: "NO_CONTROLLER", message: "Could not find view controller", details: nil))
            return
        }
        
        viewController.present(scannerViewController, animated: true)
    }
}

@available(iOS 13.0, *)
extension ReceiptScannerPlugin: VNDocumentCameraViewControllerDelegate {
    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true)
        
        var imagePaths: [String] = []
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        for pageIndex in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageIndex)
            let imageName = "scanned_\(Date().timeIntervalSince1970)_\(pageIndex).jpg"
            let imagePath = "\(documentsPath)/\(imageName)"
            
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                do {
                    try imageData.write(to: URL(fileURLWithPath: imagePath))
                    imagePaths.append(imagePath)
                } catch {
                    print("Error saving image: \(error)")
                }
            }
        }
        
        flutterResult?(imagePaths)
        flutterResult = nil
    }
    
    public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
        flutterResult?([])
        flutterResult = nil
    }
    
    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true)
        flutterResult?(FlutterError(code: "SCANNER_ERROR", message: error.localizedDescription, details: nil))
        flutterResult = nil
    }
}