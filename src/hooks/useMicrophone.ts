import { useState, useCallback } from 'react';

export const useMicrophone = () => {
  const [isPermissionGranted, setIsPermissionGranted] = useState(false);
  const [isPermissionDenied, setIsPermissionDenied] = useState(false);
  const [isRecording, setIsRecording] = useState(false);
  const [isPlaying, setIsPlaying] = useState(false);
  const [audioChunks, setAudioChunks] = useState<Blob[]>([]);
  const [audioContext, setAudioContext] = useState<AudioContext | null>(null);
  const [mediaRecorder, setMediaRecorder] = useState<MediaRecorder | null>(null);

  const requestMicrophonePermission = useCallback(async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      stream.getTracks().forEach(track => track.stop());
      setIsPermissionGranted(true);
      setIsPermissionDenied(false);
      return true;
    } catch (error) {
      console.error('Error requesting microphone permission:', error);
      setIsPermissionDenied(true);
      return false;
    }
  }, []);

  const startRecording = useCallback(async () => {
    if (!isPermissionGranted) {
      const granted = await requestMicrophonePermission();
      if (!granted) return;
    }

    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const recorder = new MediaRecorder(stream);
      const chunks: Blob[] = [];

      recorder.ondataavailable = (e) => {
        if (e.data.size > 0) {
          chunks.push(e.data);
        }
      };

      recorder.onstop = () => {
        setAudioChunks(chunks);
        stream.getTracks().forEach(track => track.stop());
      };

      recorder.start();
      setMediaRecorder(recorder);
      setIsRecording(true);
    } catch (error) {
      console.error('Error starting recording:', error);
    }
  }, [isPermissionGranted, requestMicrophonePermission]);

  const stopRecording = useCallback(() => {
    if (mediaRecorder && isRecording) {
      mediaRecorder.stop();
      setIsRecording(false);
    }
  }, [mediaRecorder, isRecording]);

  const playAudio = useCallback(async () => {
    if (audioChunks.length === 0) return;

    try {
      const audioBlob = new Blob(audioChunks, { type: 'audio/webm' });
      const audioUrl = URL.createObjectURL(audioBlob);
      const audio = new Audio(audioUrl);
      
      setIsPlaying(true);
      await audio.play();
      
      audio.onended = () => {
        setIsPlaying(false);
        URL.revokeObjectURL(audioUrl);
      };
    } catch (error) {
      console.error('Error playing audio:', error);
      setIsPlaying(false);
    }
  }, [audioChunks]);

  return {
    isPermissionGranted,
    isPermissionDenied,
    isRecording,
    isPlaying,
    requestMicrophonePermission,
    startRecording,
    stopRecording,
    playAudio
  };
}; 