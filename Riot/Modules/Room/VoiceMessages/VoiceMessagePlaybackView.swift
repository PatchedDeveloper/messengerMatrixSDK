
// swiftlint:disable all

import Foundation
import Reusable
import UIKit
import MatrixSDK

protocol VoiceMessagePlaybackViewDelegate: AnyObject {
    func voiceMessagePlaybackViewDidRequestPlaybackToggle()
    func voiceMessagePlaybackViewDidRequestSeek(to progress: CGFloat)
    func voiceMessagePlaybackViewDidChangeWidth()
    func voiceMessagePlaybackViewDidRequestTranscription(completion: @escaping (String?) -> Void)
}

struct VoiceMessagePlaybackViewDetails {
    var currentTime: String = ""
    var progress = 0.0
    var samples: [Float] = []
    var playing: Bool = false
    var playbackEnabled = false
    var recording: Bool = false
    var loading: Bool = false
}

class VoiceMessagePlaybackView: UIView, NibLoadable, Themable {
    
    private enum Constants {
        static let backgroundCornerRadius: CGFloat = 12.0
    }
    
    private var _waveformView: VoiceMessageWaveformView!
    private var currentTheme: Theme?
    
    @IBOutlet private var backgroundView: UIView!
    @IBOutlet private var recordingIcon: UIView!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var transcriptionButton: UIButton!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet private var elapsedTimeLabel: UILabel!
    @IBOutlet private var waveformContainerView: UIView!
    @IBOutlet private (set)var stackViewTrailingContraint: NSLayoutConstraint!
    
    private var longPressGestureRecognizer: UILongPressGestureRecognizer!
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    weak var delegate: VoiceMessagePlaybackViewDelegate?
    
    var details: VoiceMessagePlaybackViewDetails?
        
    var waveformView: UIView {
        return _waveformView
    }
    
    /// Define the `backgroundView.backgroundColor`.
    /// By setting this value the theme color will not be applyied to `backgroundView` in `update(theme: Theme)` method.
    var customBackgroundViewColor: UIColor? {
        didSet {
            if let theme = currentTheme {
                self.update(theme: theme)
            }
        }
    }
    
    override var bounds: CGRect {
        didSet {
            if oldValue.width != bounds.width {
                delegate?.voiceMessagePlaybackViewDidChangeWidth()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundView.layer.cornerRadius = Constants.backgroundCornerRadius
        playButton.layer.cornerRadius = playButton.bounds.width / 2.0
        
        _waveformView = VoiceMessageWaveformView(frame: waveformContainerView.bounds)
        waveformContainerView.vc_addSubViewMatchingParent(_waveformView)
        
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.2
        waveformView.addGestureRecognizer(longPressGestureRecognizer)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.isEnabled = false
        waveformView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func configureWithDetails(_ details: VoiceMessagePlaybackViewDetails?) {
        guard let details = details else {
            return
        }
        
        playButton.isEnabled = details.playbackEnabled
        playButton.setImage((details.playing ? Asset.Images.voiceMessagePauseButton.image : Asset.Images.voiceMessagePlayButton.image), for: .normal)
        
        UIView.performWithoutAnimation {
            // UIStackView doesn't respond well to re-setting hidden states https://openradar.appspot.com/22819594
            if playButton.isHidden != details.recording {
                playButton.isHidden = details.recording
            }
            
            if transcriptionButton.isHidden != details.recording {
                transcriptionButton.isHidden = details.recording
            }
            
            // UIStackView doesn't respond well to re-setting hidden states https://openradar.appspot.com/22819594
            if recordingIcon.isHidden != !details.recording {
                recordingIcon.isHidden = !details.recording
            }
        }
        
        if details.loading {
            elapsedTimeLabel.text = "--:--"
            _waveformView.progress = 0
            _waveformView.samples = []
            _waveformView.alpha = 0.3
        } else {
            elapsedTimeLabel.text = details.currentTime
            _waveformView.progress = details.progress
            _waveformView.samples = details.samples
            _waveformView.alpha = 1.0
        }
        
        self.details = details
        
        guard let theme = currentTheme else {
            return
        }
        
        self.backgroundColor = theme.colors.background
        playButton.backgroundColor = theme.roomCellIncomingBubbleBackgroundColor
        playButton.tintColor = theme.colors.secondaryContent
        transcriptionButton.tintColor = theme.colors.secondaryContent
        
        transcriptionButton.isHidden = !RevenueCatUtils.isVip
        
        let backgroundViewColor = self.customBackgroundViewColor ?? theme.colors.quinaryContent
        
        backgroundView.backgroundColor = backgroundViewColor
        _waveformView.primaryLineColor =  theme.colors.quarterlyContent
        _waveformView.secondaryLineColor = theme.colors.secondaryContent
        elapsedTimeLabel.textColor = theme.colors.secondaryContent
        elapsedTimeLabel.font = theme.fonts.body
    }
    
    func getRequiredNumberOfSamples() -> Int {
        _waveformView.setNeedsLayout()
        _waveformView.layoutIfNeeded()
        return _waveformView.requiredNumberOfSamples
    }
    
    // MARK: - Themable
    
    func update(theme: Theme) {
        currentTheme = theme
        configureWithDetails(details)
    }
    
    func voiceMessagePlaybackViewDidReceiveTranscription(_ transcription: String) {
        print("voiceMessagePlaybackViewDidReceiveTranscription. \(transcription)")

        // Создаем UIAlertController
        let alertController = UIAlertController(title: "Транскрипция", message: transcription, preferredStyle: .alert)

        // Добавляем кнопку "Закрыть"
        let closeAction = UIAlertAction(title: "Закрыть", style: .default)
        alertController.addAction(closeAction)

        // Находим topmost controller
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            // Презентуем alertController
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    
//    func voiceMessagePlaybackViewDidReceiveTranscription(_ transcription: String) {
//        print("voiceMessagePlaybackViewDidReceiveTranscription. \(transcription)")
//        let transcriptionLabel = UILabel()
//        transcriptionLabel.text = transcription
//        transcriptionLabel.numberOfLines = 0
//        transcriptionLabel.textColor = currentTheme?.colors.secondaryContent
//        transcriptionLabel.font = currentTheme?.fonts.body
//        transcriptionLabel.textAlignment = .left
//        transcriptionLabel.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(transcriptionLabel)
//
//        NSLayoutConstraint.activate([
//            transcriptionLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10),
//            transcriptionLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -10),
//            transcriptionLabel.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 10),
//            transcriptionLabel.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -10)
//        ])
//
//        self.layoutIfNeeded()
//    }

        
    // MARK: - Private
        
    @IBAction private func onPlayButtonTap() {
        delegate?.voiceMessagePlaybackViewDidRequestPlaybackToggle()
    }
    
    @IBAction private func onTranscriptionButtonTap() {
        print("transcription")
        delegate?.voiceMessagePlaybackViewDidRequestTranscription { [weak self] transcription in
            guard let self = self, let transcription = transcription else { return }
            self.voiceMessagePlaybackViewDidReceiveTranscription(transcription)
        }
    }
    
    @objc private func handleLongPressGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        let x = gestureRecognizer.location(in: waveformContainerView).x.clamped(to: 0...waveformContainerView.bounds.width)
        let progress = x / waveformContainerView.bounds.width
        delegate?.voiceMessagePlaybackViewDidRequestSeek(to: progress)
        
        switch gestureRecognizer.state {
        case .began:
            panGestureRecognizer.isEnabled = true
        case .ended, .failed, .cancelled:
            panGestureRecognizer.isEnabled = false
        default:
            break
        }
    }
    
    @objc private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began, .changed:
            let x = gestureRecognizer.location(in: waveformContainerView).x.clamped(to: 0...waveformContainerView.bounds.width)
            let progress = x / waveformContainerView.bounds.width
            delegate?.voiceMessagePlaybackViewDidRequestSeek(to: progress)
        default:
            break
        }
    }
}
