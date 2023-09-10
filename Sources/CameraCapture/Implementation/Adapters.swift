import AVFoundation

enum ZoomScaleToMultiplication {
    static func adapt(deviceType: DeviceType, scale: Double) -> Double {
        switch deviceType {
        case .dualWideCamera, .tripleCamera:
            return scale * 0.5
        case .dualCamera:
            return scale * 1.11
        default:
            return scale * 0.5
        }
    }
}

enum ZoomMultiplcationToScale {
    static func adapt(deviceType: DeviceType, multiplier: Double) -> Double {
        switch deviceType {
        case .dualWideCamera, .tripleCamera:
            return multiplier / 0.5
        case .dualCamera:
            return multiplier / 1.11
        default:
            return multiplier / 0.5
        }
    }
}

enum AVCaptureDeviceToCameraAdapter {
    
    static func adapt(device: AVCaptureDevice) -> Device {
        var zoomOptions: [Double] = []
        
        switch device.deviceType {
        case .builtInDualWideCamera, .builtInTripleCamera:
            zoomOptions.append(0.5)
            break
        case .builtInDualCamera:
            zoomOptions.append(1.0)
            break
        default:
            break
        }
        
        zoomOptions.append(contentsOf: device.virtualDeviceSwitchOverVideoZoomFactors.map { ZoomScaleToMultiplication.adapt(deviceType: self.adapt(device: device.deviceType),
                                                                                                                            scale: $0.doubleValue) })

        return Device(id: device.uniqueID,
                      type: self.adapt(device: device.deviceType),
                      position: self.adapt(position: device.position),
                      hasFlash: device.hasTorch,
                      isFlashOn: device.isTorchActive,
                      zoomOptions: zoomOptions,
                      currentZoom: device.videoZoomFactor * 0.5,
                      maxZoom: min(device.maxAvailableVideoZoomFactor * 0.5, 10),
                      minZoom: device.minAvailableVideoZoomFactor * 0.5)
    }
    
    private static func adapt(device: AVCaptureDevice.DeviceType?) -> DeviceType {
        guard let device = device else {
            return .unspecified
        }
        switch device {
        case .builtInUltraWideCamera: return .ultraWideCamera
        case .builtInTelephotoCamera: return .telephotoCamera
        case .builtInWideAngleCamera: return .wideAngleCamera
        case .builtInDualCamera: return .dualCamera
        case .builtInDualWideCamera: return .dualWideCamera
        case .builtInTripleCamera: return .tripleCamera
        default:
            return .unspecified
        }
    }
    
    private static func adapt(position: AVCaptureDevice.Position) -> DevicePosition {
        switch position {
        case .back: return .back
        case .front: return .front
        case .unspecified: return .notStated
        @unknown default: return .notStated
        }
    }
}


