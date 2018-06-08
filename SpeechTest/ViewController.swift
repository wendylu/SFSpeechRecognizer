//
//  ViewController.swift
//  SpeechTest
//
//  Created by Wendy Lu on 2/17/18.
//  Copyright © 2018 Wendy Lu. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController {
    let label = CustomLabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(label)

        askPermission()
        //recognizeRecording()

        do {
            try startRecording()
        } catch {
            print("Error")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func recognizeRecording() {
        guard let url = Bundle.main.url(forResource: "hi", withExtension: "m4a") else {
            return
        }

        guard let recognizer = SFSpeechRecognizer() else {
            // Device or locale not supported
            return
        }
        if !recognizer.isAvailable {
            // Internet connection may not be available
            return
        }
        let request = SFSpeechURLRecognitionRequest(url: url)
        recognizer.recognitionTask(with: request) { [weak self] (result, error)  in
            guard let result = result, let weakself = self else {
                return
            }

            var resultString = "Result: \(result.bestTranscription.formattedString)\n\n"

            if result.isFinal {
                resultString = "Final Result: \(result.bestTranscription.formattedString)\n\n"
            }

            weakself.updateLabel(text: resultString)
        }
    }

    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()

    func startRecording() throws {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, _) in
            self?.request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            guard let result = result else {
                return
            }
            print("result: \(result.bestTranscription.formattedString)")
        })
    }

    func stopRecording() {
        audioEngine.stop()
        request.endAudio()
    }

    private func askPermission() {
        SFSpeechRecognizer.requestAuthorization { (status) in
        }
    }

    private func updateLabel(text: String) {
        var labelText = label.text
        if (labelText == nil){
            labelText = ""
        }
        
        label.text = labelText! + text
        label.frame = CGRect(x:0, y:0, width:view.frame.size.width, height:1)
        label.sizeToFit()
        label.center = view.center
    }
}

class CustomLabel : UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        font = UIFont.systemFont(ofSize: 24.0)
        textColor = .darkGray
        numberOfLines = 0
        backgroundColor = .white
        textAlignment = NSTextAlignment.center
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

