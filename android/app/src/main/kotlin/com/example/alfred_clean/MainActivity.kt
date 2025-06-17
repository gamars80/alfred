package com.example.alfred_clean

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Log
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

    // 침묵 타이머
    private val silenceTimeout = 3500L
    private val silenceHandler = Handler(Looper.getMainLooper())
    private val silenceRunnable = Runnable {
        Log.d("Voice", "3.5초간 침묵 - 자동 종료: stopListening 호출")
        speechRecognizer.stopListening()
    }

    // 권한 요청 코드 식별자
    private val REQUEST_RECORD_AUDIO = 100

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 스플래시 화면 설정
        window.setFlags(
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        )
        setTheme(R.style.LaunchTheme)

        // 앱 시작 시 마이크 권한 요청
        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.RECORD_AUDIO
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.RECORD_AUDIO),
                REQUEST_RECORD_AUDIO
            )
        }
    }

    override fun onFlutterUiDisplayed() {
        super.onFlutterUiDisplayed()
        Handler(Looper.getMainLooper()).postDelayed({
            window.decorView.animate()
                .alpha(0f)
                .setDuration(1500)
                .withEndAction {
                    setTheme(R.style.NormalTheme)
                    window.decorView.alpha = 1f
                    window.clearFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)
                }
                .start()
        }, 500)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "startListening") {
                    resultHandler = result

                    // 1) 권한 상태 확인
                    val status = ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.RECORD_AUDIO
                    )

                    if (status != PackageManager.PERMISSION_GRANTED) {
                        // 권한이 없는 경우 시스템 권한 요청 다이얼로그 표시
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(Manifest.permission.RECORD_AUDIO),
                            REQUEST_RECORD_AUDIO
                        )
                    } else {
                        // 이미 허용된 상태
                        doStartListening()
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    // 실제 음성 인식 로직을 분리해서 메서드로 둡니다.
    private fun doStartListening() {
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
                    silenceHandler.removeCallbacks(silenceRunnable)
                    silenceHandler.postDelayed(silenceRunnable, silenceTimeout)
                }
            }

            override fun onBufferReceived(buffer: ByteArray?) {}
            override fun onEndOfSpeech() {
                Log.d("Voice", "onEndOfSpeech: 말하는 끝 감지")
            }

            override fun onError(error: Int) {
                Log.e("Voice", "에러 발생: $error")
                silenceHandler.removeCallbacks(silenceRunnable)
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
                val finalText = results
                    .getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                    ?.getOrNull(0) ?: ""
                if (!hasResponded) {
                    resultHandler?.success(finalText)
                    hasResponded = true
                }
            }

            override fun onEvent(eventType: Int, params: Bundle?) {}
        })

        // 타이머 시작
        silenceHandler.removeCallbacks(silenceRunnable)
        silenceHandler.postDelayed(silenceRunnable, silenceTimeout)

        speechRecognizer.startListening(intent)
    }

    // 사용자가 권한 요청 팝업에 응답했을 때 콜백
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_RECORD_AUDIO) {
            // 사용자가 마이크 권한을 허용했을 경우
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                doStartListening()
            } else {
                // 권한을 거부한 경우, 빈 문자열이나 에러를 반환
                resultHandler?.success("")
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        speechRecognizer.destroy()
    }
}
