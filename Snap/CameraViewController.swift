//
//  CameraViewController.swift
//  Snap
//
//  Created by Muhd Mirza on 28/2/17.
//  Copyright © 2017 muhdmirzamz. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	@IBOutlet var imageView: UIImageView!
	// a separate outlet helps with performance
	@IBOutlet var drawImageView: UIImageView!
	
	@IBOutlet var redButton: UIButton!
	@IBOutlet var greenButton: UIButton!
	@IBOutlet var blueButton: UIButton!
	@IBOutlet var blackButton: UIButton!

	var lastPoint: CGPoint?
	var lines = [Line]()
	var currColour: CGColor?
	
	// actually the formula is (button frame height / 2)
	var corderRadius = CGFloat(15)

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.currColour = UIColor.red.cgColor
		
		self.redButton.layer.cornerRadius = self.corderRadius
		self.greenButton.layer.cornerRadius = self.corderRadius
		self.blueButton.layer.cornerRadius = self.corderRadius
		self.blackButton.layer.cornerRadius = self.corderRadius
    }
	
	@IBAction func takePicture() {
		let picker = UIImagePickerController()
		picker.allowsEditing = false
		picker.delegate = self
		picker.sourceType = .camera
		
		self.present(picker, animated: true, completion: nil)
	}
	
	@IBAction func getPictureFromLibrary() {
		let picker = UIImagePickerController()
		picker.allowsEditing = false
		picker.delegate = self
		picker.sourceType = .photoLibrary
		
		self.present(picker, animated: true, completion: nil)
	}
	
	@IBAction func savePicture() {
		if let image = self.imageView.image {
			UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
			print("Success")
		} else {
			print("Error")
		}
	}
	
	
	@IBAction func changeColour(_ button: UIButton) {
		// using accessibility identifier because checking for background colour does not work
		if button.accessibilityIdentifier == "red" {
			self.currColour = UIColor.red.cgColor
		} else if button.accessibilityIdentifier == "green" {
			self.currColour = UIColor.green.cgColor
		} else if button.accessibilityIdentifier == "blue" {
			self.currColour = UIColor.blue.cgColor
		} else if button.accessibilityIdentifier == "black" {
			self.currColour = UIColor.black.cgColor
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		let image = info[UIImagePickerControllerOriginalImage] as? UIImage
		self.imageView.image = image
		
		picker.dismiss(animated: true, completion: nil)
	}
	
	public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.lastPoint = touches.first?.location(in: self.drawImageView)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		let currPoint = touches.first?.location(in: self.drawImageView)
		self.lines.append(Line.init(startPoint: self.lastPoint!, endPoint: currPoint!))
		
		UIGraphicsBeginImageContextWithOptions(self.imageView.frame.size, false, 0)
		let context = UIGraphicsGetCurrentContext()

		context?.setStrokeColor(self.currColour!)
		context?.setLineCap(.round)
		context?.setLineWidth(5)
		
		for line in self.lines {
			context?.move(to: line.startPoint)
			context?.addLine(to: line.endPoint)
		}
		
		context?.strokePath()
		
		self.drawImageView?.image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		self.lastPoint = currPoint
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		UIGraphicsBeginImageContextWithOptions(self.imageView.frame.size, false, 0)
		self.imageView.image?.draw(in: self.imageView.frame)
		self.drawImageView?.image?.draw(in: self.imageView.frame)
		self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
	
		self.lines.removeAll()
	}
}
