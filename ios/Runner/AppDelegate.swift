import Flutter
import UIKit
import AVFoundation
import Speech

@main
@objc class AppDelegate: FlutterAppDelegate {
  var audioEngine: AVAudioEngine?
  var speechRecognizer: SFSpeechRecognizer?
  var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  var recognitionTask: SFSpeechRecognitionTask?
  var silenceTimer: Timer?
  var lastSpeechTime: Date?
  let silenceTimeout: TimeInterval = 4.5
  var resultCallback: FlutterResult?
  var alreadyReturned = false
  var lastTranscription: String = ""
  var silenceTimeoutFired = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let voiceChannel = FlutterMethodChannel(name: "com.alfred/voice",
                                            binaryMessenger: controller.binaryMessenger)
    voiceChannel.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "startListening" {
        self.resultCallback = result
        self.alreadyReturned = false
        // 실무처럼 음성인식 권한과 마이크 권한을 모두 명확하게 체크/요청
        SFSpeechRecognizer.requestAuthorization { authStatus in
          switch authStatus {
          case .authorized:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
              if granted {
                // 메인스레드에서 세션 시작
                DispatchQueue.main.async {
                  // 세션 중복 방지
                  if self.audioEngine?.isRunning == true {
                    print("[iOS] 이미 인식 세션이 실행 중입니다. 중단합니다.")
                    self.stopRecognitionSession()
                  }
                  self.startRecognitionSession(result: result)
                }
              } else {
                print("[iOS] 마이크 권한 거부됨")
                self.returnErrorOnce(code: "PERMISSION_DENIED", message: "마이크 권한이 필요합니다.")
              }
            }
          case .denied, .restricted, .notDetermined:
            print("[iOS] 음성인식 권한 거부됨: \(authStatus)")
            self.returnErrorOnce(code: "PERMISSION_DENIED", message: "음성인식 권한이 필요합니다.")
          @unknown default:
            self.returnErrorOnce(code: "PERMISSION_DENIED", message: "알 수 없는 권한 상태")
          }
        }
      }
    })
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func startSpeechRecognition(result: @escaping FlutterResult) {
    // 권한 확인
    SFSpeechRecognizer.requestAuthorization { authStatus in
      switch authStatus {
      case .authorized:
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
          DispatchQueue.main.async {
            if granted {
              self.startRecognitionSession(result: result)
            } else {
              result(FlutterError(code: "PERMISSION_DENIED", message: "Microphone permission denied", details: nil))
            }
          }
        }
      case .denied, .restricted:
        result(FlutterError(code: "PERMISSION_DENIED", message: "Speech recognition permission denied", details: nil))
      case .notDetermined:
        result(FlutterError(code: "PERMISSION_NOT_DETERMINED", message: "Speech recognition permission not determined", details: nil))
      @unknown default:
        result(FlutterError(code: "PERMISSION_UNKNOWN", message: "Unknown speech recognition permission state", details: nil))
      }
    }
  }

  func startRecognitionSession(result: @escaping FlutterResult) {
    DispatchQueue.main.async {
      // 세션 중복 방지
      if self.audioEngine?.isRunning == true {
        print("[iOS] 이미 인식 세션이 실행 중입니다. 중단합니다.")
        self.stopRecognitionSession()
      }
      self.audioEngine?.stop()
      self.audioEngine = AVAudioEngine()
      self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
      self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
      self.recognitionTask?.cancel()
      self.recognitionTask = nil
      self.lastSpeechTime = Date()
      self.silenceTimeoutFired = false

      // AVAudioSession 설정 추가 (crash 방지)
      let audioSession = AVAudioSession.sharedInstance()
      do {
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
      } catch {
        print("[iOS] AUDIO_SESSION_ERROR: \(error.localizedDescription)")
        self.returnErrorOnce(code: "AUDIO_SESSION_ERROR", message: error.localizedDescription)
        return
      }

      guard let audioEngine = self.audioEngine,
            let recognitionRequest = self.recognitionRequest,
            let speechRecognizer = self.speechRecognizer,
            speechRecognizer.isAvailable else {
        print("[iOS] ENGINE_ERROR: Speech recognizer not available")
        self.returnErrorOnce(code: "ENGINE_ERROR", message: "Speech recognizer not available")
        return
      }

      let inputNode = audioEngine.inputNode
      recognitionRequest.shouldReportPartialResults = true

      // 침묵 타이머 시작
      self.startSilenceTimer(result: result)

      self.recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
        guard let self = self else { return }
        if let recognitionResult = result {
          let transcript = recognitionResult.bestTranscription.formattedString
          print("[iOS] 음성인식 중간 결과: \(transcript)")
          self.lastTranscription = transcript
          self.lastSpeechTime = Date()
          if recognitionResult.isFinal {
            print("[iOS] 음성인식 최종 결과: \(transcript)")
            self.stopRecognitionSession()
            self.returnResultOnce(transcript)
          }
        } else if let error = error {
          print("[iOS] 음성인식 에러: \(error.localizedDescription)")
          self.stopRecognitionSession()
          self.returnErrorOnce(code: "RECOGNITION_ERROR", message: error.localizedDescription)
        }
        // 침묵 타임아웃이 발생했고, isFinal 콜백이 오지 않은 경우 fallback
        if self.silenceTimeoutFired, !self.alreadyReturned {
          print("[iOS] 침묵 타임아웃 fallback, 마지막 중간 결과 반환: \(self.lastTranscription)")
          self.stopRecognitionSession()
          self.returnResultOnce(self.lastTranscription)
        }
      }

      let recordingFormat = inputNode.outputFormat(forBus: 0)
      inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, when) in
        self?.recognitionRequest?.append(buffer)
      }

      do {
        try audioEngine.start()
        print("[iOS] audioEngine.start() 성공, 음성인식 시작!")
      } catch {
        print("[iOS] AUDIO_ENGINE_ERROR: \(error.localizedDescription)")
        self.returnErrorOnce(code: "AUDIO_ENGINE_ERROR", message: error.localizedDescription)
      }
    }
  }

  func startSilenceTimer(result: @escaping FlutterResult) {
    self.silenceTimer?.invalidate()
    self.silenceTimer = Timer.scheduledTimer(withTimeInterval: self.silenceTimeout, repeats: false) { _ in
      print("[iOS] 침묵 타임아웃 발생, recognitionRequest.endAudio() 호출")
      self.silenceTimeoutFired = true
      self.recognitionRequest?.endAudio()
    }
  }

  func returnResultOnce(_ text: String) {
    guard !alreadyReturned, let result = resultCallback else { return }
    result(text)
    alreadyReturned = true
  }

  func returnErrorOnce(code: String, message: String) {
    guard !alreadyReturned, let result = resultCallback else { return }
    result(FlutterError(code: code, message: message, details: nil))
    alreadyReturned = true
  }

  func stopRecognitionSession() {
    print("[iOS] stopRecognitionSession 호출")
    audioEngine?.stop()
    audioEngine = nil
    recognitionTask?.cancel()
    recognitionTask = nil
    recognitionRequest = nil
    silenceTimer?.invalidate()
    silenceTimer = nil
  }
}
