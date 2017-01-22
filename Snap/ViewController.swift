//
//  ViewController.swift
//  Snap
//
//  Created by Muhd Mirza on 14/1/17.
//  Copyright © 2017 muhdmirzamz. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {

	@IBOutlet var imageView: UIImageView!
	@IBOutlet var flashBtn: UIButton!
	@IBOutlet var toggleScreensBtn: UIButton!
	@IBOutlet var captureBtn: UIButton!

	let captureSession = AVCaptureSession()
	var photoOutput = AVCapturePhotoOutput()
	var device: AVCaptureDevice?
	var previewLayer: CALayer?
	var baseLayer: CALayer?
	
	var captureScreenVisible = false
	
	var lastPoint: CGPoint?
	var tmpImageView: UIImageView?
	var lines = [Line]()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tmpImageView = UIImageView.init(frame: self.view.frame)
		
		// this causes the layer to go full screen
		// AVCaptureSessionPresetLow follows output aspect ratio, not what you want
		self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
		
		self.device = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
		
		if device != nil {
			// setup layer without adding to sublayer
			self.previewLayer = AVCaptureVideoPreviewLayer.init(session: self.captureSession)
			self.previewLayer?.frame = self.view.layer.frame
			
			self.baseLayer = CALayer()
			self.baseLayer?.backgroundColor = UIColor.white.cgColor
			self.baseLayer?.frame = self.view.layer.frame
			
			// adding preview first before baseLayer means preview stays at the back of baseLayer
			self.view.layer.addSublayer(self.previewLayer!)
			self.view.layer.addSublayer(self.baseLayer!)
			
			self.flashBtn.layer.zPosition = 1
			self.captureBtn.layer.zPosition = 1
			self.baseLayer?.zPosition = 1
			self.toggleScreensBtn.layer.zPosition = 2
			
			print("View layer: \(self.view.layer.zPosition)")
			print("preview layer: \(self.previewLayer!.zPosition)")
			print("image layer: \(self.imageView.layer.zPosition)")
			print("flash layer: \(self.flashBtn.layer.zPosition)")
			print("capture layer: \(self.captureBtn.layer.zPosition)")
			print("toggleScreenBtn layer: \(self.toggleScreensBtn.layer.zPosition)")
			
			self.captureSession.startRunning()
		}
	}
	
	@IBAction func toggleScreens() {
		if self.captureScreenVisible {
			print("Going back")
			self.captureScreenVisible = false
			
			for input in (self.captureSession.inputs as? [AVCaptureDeviceInput])!{
				self.captureSession.removeInput(input)
			}
			self.captureSession.removeOutput(self.photoOutput)
			
			// rearrange layers
			self.previewLayer?.zPosition = 0
			self.baseLayer?.zPosition = 1
			self.flashBtn.layer.zPosition = 2
			self.captureBtn.layer.zPosition = 2
			self.imageView.layer.zPosition = 3
			self.toggleScreensBtn.layer.zPosition = 4
			
			self.captureSession.stopRunning()
		} else {
			print("Going to record screen")
			
			self.captureScreenVisible = true
			
			let err: NSError?
			
			do {
				try self.captureSession.addInput(AVCaptureDeviceInput.init(device: self.device))
				self.captureSession.addOutput(self.photoOutput)
			} catch {
				err = NSError()
				print((err?.localizedDescription)!)
			}
			
			print("Before capture")
			print("Input: \(self.captureSession.inputs.count)")
			print("Output: \(self.captureSession.outputs.count)")
			
			// rearrange layers
			self.baseLayer?.zPosition = 0
			self.imageView.layer.zPosition = 1
			self.previewLayer?.zPosition = 2
			self.flashBtn.layer.zPosition = 3
			self.toggleScreensBtn.layer.zPosition = 3
			self.captureBtn.layer.zPosition = 3
		
			self.captureSession.startRunning()
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
	
	@IBAction func takePicture() {
		if (self.photoOutput.connection(withMediaType: AVMediaTypeVideo)) != nil {
			// got to init a new one every time
			let photoSettings = AVCapturePhotoSettings()
			let previewPixelType = photoSettings.availablePreviewPhotoPixelFormatTypes.first!
			let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
								 kCVPixelBufferWidthKey as String: 160,
								 kCVPixelBufferHeightKey as String: 160,
								 ]
			photoSettings.previewPhotoFormat = previewFormat
			self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
		}
	}
	
	public func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
		print("CAPTURE")
	
		let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer!)
		let image = UIImage.init(data: imageData!)
		
		self.imageView.image = image
		
		UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil);
		
		self.captureSession.stopRunning()
		
		self.captureScreenVisible = false
		
		// rearrange layers
		self.previewLayer?.zPosition = 0
		self.flashBtn.layer.zPosition = 1
		self.captureBtn.layer.zPosition = 1
		self.baseLayer?.zPosition = 2
		self.imageView.layer.zPosition = 3
		self.toggleScreensBtn.layer.zPosition = 4
		
		for input in (self.captureSession.inputs as? [AVCaptureDeviceInput])!{
			self.captureSession.removeInput(input)
		}
		self.captureSession.removeOutput(self.photoOutput)
		
		print("After capture")
		print("Input: \(self.captureSession.inputs.count)")
		print("Output: \(self.captureSession.outputs.count)")
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.lastPoint = touches.first?.location(in: self.view)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		print("Touchsfef")
		
		let currPoint = touches.first?.location(in: self.view)
		self.lines.append(Line.init(startPoint: self.lastPoint!, endPoint: currPoint!))
		
		UIGraphicsBeginImageContextWithOptions((self.imageView.image?.size)!, false, 0)
		let context = UIGraphicsGetCurrentContext()
		self.tmpImageView?.image?.draw(in: self.view.frame)
		
		for line in self.lines {
			context?.move(to: line.startPoint)
			context?.addLine(to: line.endPoint)
		}
		context?.setLineCap(.round)
		context?.setLineWidth(10)
		context?.setStrokeColor(UIColor.red.cgColor)
		context?.strokePath()
		self.tmpImageView?.image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		self.lastPoint = currPoint
		
		self.view.setNeedsDisplay()
		
		UIGraphicsBeginImageContext(self.view.frame.size)
		self.imageView.image?.draw(in: self.view.frame)
		self.tmpImageView?.image?.draw(in: self.view.frame)
		self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		self.tmpImageView?.image = nil
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.lines.removeAll()
	}
}

