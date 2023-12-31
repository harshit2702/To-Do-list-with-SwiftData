import SwiftUI
import AVFoundation

struct AudioRecordingView: View {
    @State private var isRecording = false
    @State private var isPlaying = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioEncoderQuality: AVAudioQuality = .high
    @State private var playbackTimer: Timer?
    @State private var playbackProgress: CGFloat = 0.0
    @State private var audioData: [Float] = []

    var body: some View {
        VStack {
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }) {
                Text(isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .background(isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            print(audioData)

            if isRecording {
                FrequencyGraphView(audioData: audioData)
                    .frame(height: 200)
                    .padding()
            }
            Button(action: {
                if isPlaying {
                    stopPlayback()
                } else {
                    startPlayback()
                }
            }) {
                Text(isPlaying ? "Stop Playback" : "Start Playback")
                    .padding()
                    .background(isPlaying ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            if isPlaying {
                Slider(value: $playbackProgress, in: 0...1)
                    .padding()
                    .accentColor(.blue)
                    .disabled(true)
            }
            
            Picker("Encoder Quality", selection: $audioEncoderQuality) {
                Text("High").tag(AVAudioQuality.high)
                Text("Low").tag(AVAudioQuality.low)
                Text("Max").tag(AVAudioQuality.max)
                Text("Medium").tag(AVAudioQuality.medium)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            if isRecording {
                FrequencyGraphView(audioData: audioData)
                    .frame(height: 200)
                    .padding()
            }
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: audioEncoderQuality.rawValue
        ] as [String : Any]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
    }
    
    func startPlayback() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        if FileManager.default.fileExists(atPath: audioFilename.path) {
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.playback, mode: .spokenAudio)
                try audioSession.setActive(true)
                
                audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
                audioPlayer?.play()
                isPlaying = true
                
                playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    if let audioPlayer = audioPlayer {
                        playbackProgress = CGFloat(audioPlayer.currentTime / audioPlayer.duration)
                    }
                }
            } catch {
                print("Failed to start playback: \(error.localizedDescription)")
            }
        } else {
            print("No file available for playback")
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        playbackTimer?.invalidate()
        playbackTimer = nil
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to reset audio session for recording: \(error.localizedDescription)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension AudioRecordingView: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            do {
                let audioFile = try AVAudioFile(forReading: recorder.url)
                let audioFormat = audioFile.processingFormat
                let audioFrameCount = UInt32(audioFile.length)
                let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
                try audioFile.read(into: audioBuffer!)
                
                let floatChannelData = audioBuffer!.floatChannelData!
                let channelCount = Int(audioBuffer!.format.channelCount)
                let frameLength = Int(audioBuffer!.frameLength)
                
                var audioData: [Float] = []
                for frame in 0..<frameLength {
                    var channelData: [Float] = []
                    for channel in 0..<channelCount {
                        let sample = floatChannelData[channel][frame]
                        channelData.append(sample)
                    }
                    audioData.append(contentsOf: channelData)
                }
                
                self.audioData = audioData
            } catch {
                print("Failed to read audio file: \(error.localizedDescription)")
            }
        }
    }
}

struct FrequencyGraphView: View {
    let audioData: [Float]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                let xScale: CGFloat = width / CGFloat(audioData.count)
                let yScale: CGFloat = height / 2
                
                path.move(to: CGPoint(x: 0, y: height / 2))
                
                for (index, sample) in audioData.enumerated() {
                    let x = CGFloat(index) * xScale
                    let y = CGFloat(sample) * yScale + height / 2
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
    }
}

struct AudioRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        AudioRecordingView()
    }
}
