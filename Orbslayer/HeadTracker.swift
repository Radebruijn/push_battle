import AVFoundation
import Combine
import Vision
import UIKit

/// Volgt de hoogte van je hele hoofd via de camera en zet die beweging om in reps.
///
/// De telefoon staat rechtop naast je en filmt je van opzij. Een houdingsmodel
/// geeft losse punten voor neus, ogen en oren; we middelen alles wat het van je
/// hoofd ziet. Dat is bewust breder dan gezichtsherkenning: onderin een push-up
/// kijk je naar de grond en is je gezicht niet meer te zien, maar je oor en
/// achterhoofd wel. Zo blijf je ook op je laagste punt gevolgd.
@MainActor
final class HeadTracker: NSObject, ObservableObject {

    /// De punten van het houdingsmodel die bij je hoofd horen.
    static let headJoints: [VNHumanBodyPoseObservation.JointName] =
        [.nose, .leftEye, .rightEye, .leftEar, .rightEar]

    enum Phase { case up, down }

    /// Genormaliseerde hoogte van het midden van je hoofd: 0 = vloer, 1 = bovenkant beeld.
    @Published private(set) var headHeight: Double = 0.5
    @Published private(set) var seesHead = false
    @Published private(set) var phase: Phase = .up
    @Published private(set) var isRunning = false
    @Published var errorMessage: Tk?

    /// Wordt aangeroepen bij elke voltooide rep (omhoog na beneden geweest te zijn).
    var onRep: (@MainActor () -> Void)?

    /// Kalibratie: hoofdhoogte bij gestrekte armen (top) en onderin (bottom).
    private(set) var calTop: Double = 0.75
    private(set) var calBottom: Double = 0.25

    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "orbslayer.camera")

    private var wentDown = false
    private var lastRepAt = Date.distantPast
    /// Reps sneller dan dit zijn vrijwel zeker ruis in plaats van echte push-ups.
    private let minRepInterval: TimeInterval = 0.45
    private var smoothed: Double?
    private var missedFrames = 0

    var captureSession: AVCaptureSession { session }

    /// Hoeveel van je gekalibreerde bereik je moet afleggen voordat een rep
    /// telt. 0.6 laat de drempels op 80% en 20% liggen; hoger is strenger.
    var depth: Double = 0.6

    private var edge: Double { (1 - depth) / 2 }
    var upThreshold: Double { calBottom + (calTop - calBottom) * (1 - edge) }
    var downThreshold: Double { calBottom + (calTop - calBottom) * edge }

    func applyCalibration(top: Double, bottom: Double) {
        guard top - bottom > 0.05 else { return }
        calTop = top
        calBottom = bottom
    }

    // MARK: Sessiebeheer

    func start() {
        guard !isRunning else { return }
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            Task { @MainActor in
                guard let self else { return }
                guard granted else {
                    self.errorMessage = .cam_settings
                    return
                }
                self.configureIfNeeded()
                guard self.errorMessage == nil else { return }
                self.queue.async { [weak self] in
                    guard let self else { return }
                    if !self.session.isRunning { self.session.startRunning() }
                }
                self.isRunning = true
            }
        }
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        queue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    private var configured = false

    private func configureIfNeeded() {
        guard !configured else { return }
        session.beginConfiguration()
        session.sessionPreset = .medium

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            errorMessage = .cam_none
            return
        }
        session.addInput(input)

        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        if session.canAddOutput(videoOutput) { session.addOutput(videoOutput) }

        session.commitConfiguration()
        configured = true
    }

    // MARK: Verwerking

    fileprivate func handle(height: Double?) {
        guard let raw = height else {
            missedFrames += 1
            if missedFrames > 15 { seesHead = false }
            return
        }
        missedFrames = 0
        seesHead = true

        // Lichte demping tegen jitter, zonder de beweging traag te maken.
        let value = smoothed.map { $0 * 0.6 + raw * 0.4 } ?? raw
        smoothed = value
        headHeight = value

        if value <= downThreshold {
            wentDown = true
            phase = .down
        } else if value >= upThreshold {
            phase = .up
            if wentDown {
                wentDown = false
                let now = Date()
                if now.timeIntervalSince(lastRepAt) >= minRepInterval {
                    lastRepAt = now
                    onRep?()
                }
            }
        }
    }
}

extension HeadTracker: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // De telefoon staat rechtop in portret naast je; .right zet het beeld
        // voor Vision overeind zodat "omhoog" in het beeld ook omhoog is.
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .right, options: [:])
        let request = VNDetectHumanBodyPoseRequest()
        try? handler.perform([request])

        var height: Double?
        if let pose = request.results?.first {
            // Alles wat we van het hoofd zien middelen: neus, ogen en oren.
            // Vision's y loopt van 0 (onder) naar 1 (boven).
            let points = Self.headJoints.compactMap { joint -> Double? in
                guard let p = try? pose.recognizedPoint(joint), p.confidence > 0.3 else { return nil }
                return Double(p.location.y)
            }
            if !points.isEmpty {
                height = points.reduce(0, +) / Double(points.count)
            }
        }

        Task { @MainActor [weak self] in
            self?.handle(height: height)
        }
    }
}
