//
//  ViewController.swift
//  Snap
//
//  Created by Muhd Mirza on 14/1/17.
//  Copyright © 2017 muhdmirzamz. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

	@IBOutlet var flashBtn: UIButton!

	let captureSession = AVCaptureSession()
	var device: AVCaptureDevice?
	var previewLayer: CALayer?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		// this causes the layer to go full screen
		// AVCaptureSessionPresetLow follows output aspect ratio, not what you want
		self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
		
		self.device = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
		
		if device != nil {
			self.beginSession()
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func beginSession() {
		let err: NSError?
	
		do {
			try self.captureSession.addInput(AVCaptureDeviceInput.init(device: self.device))
		} catch {
			err = NSError()
			print((err?.localizedDescription)!)
		}
		
		// configure layer
		self.previewLayer = AVCaptureVideoPreviewLayer.init(session: self.captureSession)
		self.previewLayer?.frame = self.view.layer.frame
		
		self.view.layer.addSublayer(previewLayer!)

		self.captureSession.startRunning()
	}
	
	@IBAction func toggleFlash() {
		if (self.device?.hasTorch)! {
			if self.device?.torchMode == AVCaptureTorchMode.off {
				do {
					try self.device?.lockForConfiguration()
					
					self.device?.torchMode = AVCaptureTorchMode.on
					
					self.device?.unlockForConfiguration()
				} catch {
					print("Error")
				}
			} else {
				do {
					try self.device?.lockForConfiguration()
					
					self.device?.torchMode = AVCaptureTorchMode.off
					
					self.device?.unlockForConfiguration()
				} catch {
					print("Error")
				}
			}
		}
	}
}

