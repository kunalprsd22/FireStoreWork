//
//  IDRecorderView.swift
//  UChat
//
//  Created by Admin on 04/04/19.
//  Copyright © 2019 UChat. All rights reserved.
//

import UIKit
import AVFoundation
import Shimmer



class IDRecorderView: UIView {

    private let kInitialCancelViewTrailingConstant: CGFloat = 50.0
    
    // MARK: - Properties
    public var audioRecorder: AVAudioRecorder?
    public var deleteAnimationProcessing: Bool = false
    public var isRecordingLocked: Bool = false
    public var initialCenter: CGPoint? = nil
    private var meterTimer:Timer?
    private var audioFileName: String? = nil
    public var recordedVoiceMsgHandler: ((String?, Double) -> Void)? = nil
    public var removeRecorderHandler: ((Bool) -> Void)? = nil
    private var lastLocation: CGPoint? = nil
    private var initialVoiceBtnCenter: CGPoint!
    private var removingRecorderView: Bool = false
    
    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var recorderIcon: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblSlideToCancel: UILabel!
    @IBOutlet weak var lockContainerView: UIView!
    @IBOutlet weak var dustIMage: UIImageView!
    @IBOutlet weak var binImage: UIImageView!
    @IBOutlet weak var btnVoiceMsg: UIButton!
    @IBOutlet weak var cancelLabelView: FBShimmeringView!
    @IBOutlet weak var leadingContainerViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var topLockViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingAudioBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var recorderIconCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var lockViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var audioBtnCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelViewTrailingSpace: NSLayoutConstraint!
    @IBOutlet weak var btnCancel: UIButton!
    
    
    // MARK: - Life cycle Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeFromNib()
        self.setupFont()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeFromNib()
        self.setupFont()
    }
    
    // MARK: - Private Methods
    private func setupFont() {
        self.lblSlideToCancel.font = AppFonts.SF_Pro_Regular.withSize(14)
        self.lblSlideToCancel.text = "<" + StringConstants.slideToCancel.localized
        self.lblTime.font = AppFonts.SF_Pro_Regular.withSize(14)
        self.btnCancel.setTitle(StringConstants.Cancel.localized, for: .normal)
    }
    private func initializeFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "IDRecorderView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
        self.shimmerViews()
    }
    
    override func layoutSubviews() {
        self.containerView.round(radius: self.containerView.frame.height)
    }
    
    private func shimmerViews() {
        self.cancelLabelView.contentView = lblSlideToCancel
        self.cancelLabelView.shimmeringDirection = .left
        self.cancelLabelView.shimmeringSpeed = 150
        self.cancelLabelView.shimmeringHighlightLength = 0.4
        self.cancelLabelView.isShimmering = true
    }

    @IBAction func tapSendVoiceMsg(_ sender: UIButton) {
        self.finishAudioRecording(success: true)
        self.removeRecorderHandler?(true)
    }
    
    @IBAction func tapCencelRecording(_ sender: Any) {
        self.animateDeletion()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.finishAudioRecording(success: false)
            self.removeRecorderHandler?(true)
        }
    }
    
    
    private func checkRecordPermission(completionHandler: @escaping ((Bool) -> Void)) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            completionHandler(true)
            break
        case AVAudioSession.RecordPermission.denied:
            completionHandler(false)
            break
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                completionHandler(allowed)
            })
            break
        default:
            break
        }
    }
    
    private func getFilePathForAudio() -> URL? {
        let fileName = LocalFileOperation.shared.uniqueFileNameWithExtention(fileExtension: "m4a")
        self.audioFileName = fileName
        let filePath = LocalFileOperation.shared.getCompleteFilePath(fileName: fileName, mediaType: .audio)
        return filePath
    }
    
    func setupRecorder() {
        guard let filePath = self.getFilePathForAudio() else { return }
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .default)
            try session.setActive(true)
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey:AVAudioQuality.min.rawValue
            ]
            audioRecorder = try AVAudioRecorder(url: filePath, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
        }
        catch let error {
            print_debug(error.localizedDescription)
        }
    }

    private func lockRecording() {
        if self.deleteAnimationProcessing { return }
        self.isRecordingLocked = true
        let isRecording = self.audioRecorder?.isRecording ?? false
        if !isRecording {
            self.startRecording()
        }
        self.btnVoiceMsg.isUserInteractionEnabled = true
        self.trailingAudioBtnConstraint.constant = 15.0
        self.audioBtnCenterYConstraint.constant = 0.0
        self.lockContainerView.isHidden = true
        self.btnCancel.isHidden = false
        self.cancelLabelView.isHidden = true
        self.btnVoiceMsg.isHidden = true
        self.btnVoiceMsg.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.btnVoiceMsg.isSelected = true
        self.btnVoiceMsg.isHidden = false
    }
    
    public func showAnimatedRecorderView() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5.0, options: .curveEaseInOut, animations: { [weak self] () -> Void in
            guard let self = self else { return }
            self.btnVoiceMsg.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
            self.leadingContainerViewConstraint.constant = 0.0
            self.layoutIfNeeded()
        }) { (isCompleted) in
            if isCompleted  {
                self.initialVoiceBtnCenter = self.btnVoiceMsg.center
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {[weak self] in
                    guard let self = self else { return }
                    if !(self.removingRecorderView || self.deleteAnimationProcessing || self.isRecordingLocked) {
                        self.startRecording()
                    }
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                    if !(self.removingRecorderView || self.deleteAnimationProcessing || self.isRecordingLocked) {
                        self.animateLockViewAppearance()
                    }
                })
            }
        }
    }
    
    public func hideAnimatedRecorderView(completion: @escaping ((Bool) -> Void)) {
        self.btnCancel.isHidden = true
        self.btnVoiceMsg.isHidden = true
        self.lockContainerView.isHidden = true
        self.removingRecorderView = true
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5.0, options: .curveEaseInOut, animations: { [weak self] () -> Void in
            guard let self = self else { return }
            self.leadingContainerViewConstraint.constant = UIDevice.width
            self.btnVoiceMsg.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.topLockViewConstraint.constant = 50.0
            guard let originalPosition = self.initialCenter else { return }
            self.btnVoiceMsg.center = originalPosition
        }) {(isCompleted) in
            completion(isCompleted)
        }
    }
    
    private func animateLockViewAppearance() {
        self.lockContainerView.isHidden = false
        self.topLockViewConstraint.constant = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            self.topLockViewConstraint.constant = -150.0
            self.layoutIfNeeded()
        }, completion: { (isCompleted) in
            
        })
    }
    
    @objc func animateDeletion() {
        if deleteAnimationProcessing { return }
        self.deleteAnimationProcessing = true
        self.btnVoiceMsg.isHidden = true
        self.cancelLabelView.isHidden = true
        self.btnCancel.isHidden = true
        self.lblTime.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            // Animate Recorder Icon
            let prevRecorderYPosition =  self.recorderIcon.frame.origin.y
            let prevCenterYConstraint = self.recorderIconCenterYConstraint.constant
            self.dustIMage.isHidden = false
            self.binImage.isHidden = false
            self.dustIMage.frame.origin.y = 80.0
            self.binImage.frame.origin.y = 76.0
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                guard let self = self else { return }
                self.recorderIconCenterYConstraint.constant = -150.0
                self.dustIMage.frame.origin.y = prevRecorderYPosition
                self.binImage.frame.origin.y = prevRecorderYPosition - 4.0
                self.layoutIfNeeded()
                }, completion: { [weak self] (isCompleted) in
                    guard let self = self else { return }
                    UIView.animate(withDuration: 0.3, animations: { [weak self] in
                        guard let self = self else { return }
                        var transform = CGAffineTransform.identity
                        transform = transform.translatedBy(x: -15.0, y: -6.0)
                        transform = transform.rotated(by: -CGFloat.pi/3.0)
                        self.binImage.transform = transform
                        self.layoutIfNeeded()
                    })
                    UIView.animate(withDuration: 0.5, animations: { [weak self] in
                        guard let self = self else { return }
                        self.recorderIcon.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
                        self.recorderIconCenterYConstraint.constant = prevCenterYConstraint
                        self.layoutIfNeeded()
                        }, completion: { [weak self] (isCompleted) in
                            guard let self = self else { return }
                            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                                guard let self = self else { return }
                                var transform = CGAffineTransform.identity
                                transform = transform.translatedBy(x: 0.0, y: 0.0)
                                transform = transform.rotated(by: 0.0)
                                self.binImage.transform = transform
                                self.layoutIfNeeded()
                                }, completion: { (isCompleted) in
                                    UIView.animate(withDuration: 0.3, animations: { [weak self] in
                                        guard let self = self else { return }
                                        self.recorderIconCenterYConstraint.constant = 100.0
                                        self.dustIMage.frame.origin.y = 100.0
                                        self.binImage.frame.origin.y = 100.0
                                        self.layoutIfNeeded()
                                        }, completion: { (isCompleted) in
                                            self.deleteAnimationProcessing = false
                                    })
                            })
                    })
            })
        })
    }
 
    public func animateVoiceBtnMovementFor(location: CGPoint, gestureControl: @escaping ((Bool) -> Void)) {

        guard let initialLocation = self.initialCenter else { return }

        let xDisplacement = initialLocation.x - location.x
        let yDisplacemnet = initialLocation.y - location.y

        if let prevLocation = self.lastLocation, prevLocation != initialLocation {
            if prevLocation.x == initialLocation.x && yDisplacemnet > 0.0  {
                // Move Vertically

                let diff = abs(initialLocation.y - location.y)
                self.audioBtnCenterYConstraint.constant = -diff
                let currentValue = abs(self.btnVoiceMsg.frame.origin.y)
                if currentValue > 15 {
                    let scalingRatio = (115-currentValue)/100
                    self.lockViewHeightConstraint.constant = scalingRatio * 160.0
                    print_debug(scalingRatio)
                    if scalingRatio <= 0.33 {
                        self.lockRecording()
                        gestureControl(true)
                    } else {
                        self.btnVoiceMsg.transform = CGAffineTransform(scaleX: 2.5*scalingRatio, y: 2.5*scalingRatio)
                    }
                    self.layoutIfNeeded()
                }
            } else if prevLocation.y == initialLocation.y && xDisplacement > 0.0 {
                // Move horizontally
                self.lockContainerView.isHidden = true
                if (self.cancelLabelView.frame.origin.x) <= (self.lblTime.frame.origin.x + self.lblTime.frame.width) {
                    self.animateDeletion()
                } else {
                    self.cancelViewTrailingSpace.constant = xDisplacement + kInitialCancelViewTrailingConstant
                    self.trailingAudioBtnConstraint.constant = xDisplacement + 15.0
                }
                self.lastLocation = CGPoint(x: location.x, y: initialLocation.y)
            } else {
                self.trailingAudioBtnConstraint.constant = 15.0
                self.audioBtnCenterYConstraint.constant = 0.0
                self.lastLocation = self.initialCenter
                print_debug("Reset Position")
            }
        } else {
            // It is the first location update
            if xDisplacement > yDisplacemnet && xDisplacement > 0.0{
                self.lockContainerView.isHidden = true
                if (self.cancelLabelView.frame.origin.x) <= (self.lblTime.frame.origin.x + self.lblTime.frame.width) {
                    self.animateDeletion()
                } else {
                    self.cancelViewTrailingSpace.constant = xDisplacement + kInitialCancelViewTrailingConstant
                    self.trailingAudioBtnConstraint.constant = xDisplacement + 15.0
                }
                self.lastLocation = CGPoint(x: location.x, y: initialLocation.y)
            } else if yDisplacemnet > xDisplacement && yDisplacemnet > 0.0 {
                let diff = abs(initialLocation.y - location.y)
                self.audioBtnCenterYConstraint.constant = -diff
                let currentValue = abs(self.btnVoiceMsg.frame.origin.y)
                if currentValue > 15 {
                    let scalingRatio = (115-currentValue)/100
                    self.lockViewHeightConstraint.constant = scalingRatio * 160.0
                    print_debug(scalingRatio)
                    if scalingRatio <= 0.33 {
                        self.lockRecording()
                        gestureControl(true)
                    } else {
                        self.btnVoiceMsg.transform = CGAffineTransform(scaleX: 2.5*scalingRatio, y: 2.5*scalingRatio)
                    }
                    self.layoutIfNeeded()
                }
            } else {
                self.trailingAudioBtnConstraint.constant = 15.0
                self.audioBtnCenterYConstraint.constant = 0.0
                self.lastLocation = self.initialCenter
                print_debug("print Reset Position")
            }
        }

        if self.btnVoiceMsg.center == self.initialVoiceBtnCenter && !self.isRecordingLocked {
            self.lockContainerView.isHidden = false
        }
    }
    
    func startRecording() {
        self.checkRecordPermission { [weak self] (isPermissionGranted) in
            guard let self = self else {return}
            self.setupRecorder()
            self.audioRecorder?.record()
            self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
        }
    }
    
    @objc func updateAudioMeter(timer: Timer) {
        guard let audioRecorder = self.audioRecorder else { return }
        if audioRecorder.isRecording {
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d", min, sec)
            self.lblTime.text = totalTimeString
            audioRecorder.updateMeters()
        }
    }
    
    public func finishAudioRecording(success: Bool) {
        let duration: Double = audioRecorder?.currentTime ?? 0.0
        self.audioRecorder?.stop()
        self.audioRecorder = nil
        self.meterTimer?.invalidate()
        if success {
            self.recordedVoiceMsgHandler?(self.audioFileName, ceil(duration))
            print_debug("recorded successfully.")
        } else  {
            print_debug("Recording failed")
        }
    }
}

extension IDRecorderView: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            self.finishAudioRecording(success: false)
        }
    }
}

extension IDRecorderView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
