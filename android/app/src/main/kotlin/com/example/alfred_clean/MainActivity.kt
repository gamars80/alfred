package com.example.alfred_clean
import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Log
import android.view.View
import android.view.WindowManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.alfred/voice"
    private var resultHandler: MethodChannel.Result? = null
    private lateinit var speechRecognizer: SpeechRecognizer
    private var hasResponded = false
    private var partialTextBuffer: String = ""
    private var isUserSpeaking = false

    // 침묵 타이머 (필요 시 3500ms -> 4000ms 또는 5000ms로 조정 가능)
    private val silenceTimeout = 3500L
    private val silenceHandler = Handler(Looper.getMainLooper())
    private val silenceRunnable = Runnable {
        Log.d("Voice", "3.5초간 침묵 - 자동 종료: stopListening 호출")
        // 자동 종료 시에는 즉시 결과를 반환하지 않고, stopListening 호출 후 onResults에서 최종 결과를 처리하도록 함.
        speechRecognizer.stopListening()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 스플래시 화면을 확실히 표시하도록 설정
        window.setFlags(
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        )
        
        setTheme(R.style.LaunchTheme)
    }

    override fun onFlutterUiDisplayed() {
        super.onFlutterUiDisplayed()
        
        // Flutter UI가 준비되면 약간의 지연 후 스플래시를 천천히 페이드아웃
        Handler(Looper.getMainLooper()).postDelayed({
            window.decorView.animate()
                .alpha(0f)
                .setDuration(1500) // 페이드아웃 시간을 1.5초로 증가
                .withEndAction {
                    setTheme(R.style.NormalTheme)
                    window.decorView.alpha = 1f
                    window.clearFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)
                }
                .start()
        }, 500) // 0.5초 지연 후 페이드아웃 시작
    }

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.RECORD_AUDIO)
            != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.RECORD_AUDIO), 100)
        }

        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startListening") {
                resultHandler = result
                startListening()
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startListening() {
        hasResponded = false
        partialTextBuffer = ""
        isUserSpeaking = false

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault())
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
        }

        speechRecognizer.setRecognitionListener(object : RecognitionListener {
            override fun onReadyForSpeech(params: Bundle?) {
                Log.d("Voice", "준비 완료")
            }

            override fun onBeginningOfSpeech() {
                Log.d("Voice", "사용자가 말하기 시작함")
                isUserSpeaking = true
                silenceHandler.removeCallbacks(silenceRunnable)
                silenceHandler.postDelayed(silenceRunnable, silenceTimeout)
            }

            override fun onRmsChanged(rmsdB: Float) {
                if (isUserSpeaking) {
                    // 사용자의 소리 변화가 있을 때마다 타이머 리셋 (마지막 음성 캡처를 위한 시간 확보)
                    silenceHandler.removeCallbacks(silenceRunnable)
                    silenceHandler.postDelayed(silenceRunnable, silenceTimeout)
                }
            }

            override fun onBufferReceived(buffer: ByteArray?) {}

            override fun onEndOfSpeech() {
                Log.d("Voice", "onEndOfSpeech: 말하는 끝 감지")
                // onEndOfSpeech 시 stopListening()을 호출하여 onResults가 호출되도록 유도할 수도 있습니다.
                // speechRecognizer.stopListening() // 필요 시 주석 해제
            }

            override fun onError(error: Int) {
                Log.e("Voice", "에러 발생: $error")
                silenceHandler.removeCallbacks(silenceRunnable)
                // onResults가 호출되지 않은 경우 fallback 처리
                if (!hasResponded) {
                    resultHandler?.success(if (partialTextBuffer.isNotEmpty()) partialTextBuffer else "")
                    hasResponded = true
                }
            }

            override fun onPartialResults(partialResults: Bundle) {
                val partial = partialResults.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                val partialText = partial?.getOrNull(0) ?: ""
                Log.d("Voice", "실시간 인식 결과: $partialText")

                if (partialText.isNotBlank()) {
                    partialTextBuffer = partialText
                }
            }

            override fun onResults(results: Bundle) {
                Log.d("Voice", "최종 결과 수신됨")
                silenceHandler.removeCallbacks(silenceRunnable)
                val finalText = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)?.getOrNull(0) ?: ""
                if (!hasResponded) {
                    resultHandler?.success(finalText)
                    hasResponded = true
                }
            }

            override fun onEvent(eventType: Int, params: Bundle?) {}
        })

        // 시작할 때도 타이머 시작
        silenceHandler.removeCallbacks(silenceRunnable)
        silenceHandler.postDelayed(silenceRunnable, silenceTimeout)

        speechRecognizer.startListening(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        speechRecognizer.destroy()
    }
}
