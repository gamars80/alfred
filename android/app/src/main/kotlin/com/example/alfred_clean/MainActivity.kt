package com.example.alfred_clean

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import android.speech.RecognizerIntent
import android.speech.RecognitionListener
import android.speech.SpeechRecognizer
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.alfred/voice"
    private var resultHandler: MethodChannel.Result? = null
    private lateinit var speechRecognizer: SpeechRecognizer
    private var hasResponded = false // ✅ 중복 응답 방지
    private var partialTextBuffer: String = ""
    private val partialResultDelay = 4000L // 1초 후 최종 전달

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 🔐 마이크 권한 요청
        if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.RECORD_AUDIO)
            != PackageManager.PERMISSION_GRANTED) {
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
        hasResponded = false // ✅ 매번 초기화

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
            }

            override fun onRmsChanged(rmsdB: Float) {}
            override fun onBufferReceived(buffer: ByteArray?) {}

            override fun onEndOfSpeech() {
                Log.d("Voice", "onEndOfSpeech (무시)")
            }

            override fun onError(error: Int) {
                Log.e("Voice", "에러 발생: $error")
                Handler(Looper.getMainLooper()).post {
                    if (!hasResponded) {
                        resultHandler?.success("")
                        hasResponded = true
                    }
                }
            }

            override fun onResults(results: Bundle) {
                Log.d("Voice", "최종 결과 수신됨 (무시됨)")
            }

            override fun onPartialResults(partialResults: Bundle) {
                val partial = partialResults.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                val partialText = partial?.getOrNull(0) ?: ""
                Log.d("Voice", "실시간 인식 결과: $partialText")

                if (partialText.isNotBlank()) {
                    partialTextBuffer = partialText // 최신 결과로 업데이트

                    if (!hasResponded) {
                        hasResponded = true
                        Handler(Looper.getMainLooper()).postDelayed({
                            resultHandler?.success(partialTextBuffer)
                        }, partialResultDelay)
                    }
                }
            }

            override fun onEvent(eventType: Int, params: Bundle?) {}
        })

        speechRecognizer.startListening(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        speechRecognizer.destroy()
    }
}
