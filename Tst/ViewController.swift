//
//  ViewController.swift
//  Tst
//
//  Created by Atil Samancioglu on 21/06/2017.
//  Copyright © 2017 Atil Samancioglu. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var answerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func chooseButtonClicked(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        guard let ciImage = CIImage(image: imageView.image!) else {
            fatalError("couldn't convert UIImage to CIImage")
        }
        
        detectScene(image: ciImage)
        
    }
    
    func detectScene(image: CIImage) {
        answerLabel.text = "detecting scene..."
        
        // Load the ML model through its generated class
        if let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) {
            
            let reques = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                
                if let results = request.results as? [VNClassificationObservation] {
                    let topResult = results.first
                    
                    DispatchQueue.main.async {
                        
                        let conf = (topResult?.confidence)! * 100
                        
                        let rounded = Int (conf * 100 ) / 100
                        
                        self.answerLabel.text = "\(rounded)% it's \(String(describing: topResult!.identifier))"
                    }
                }
            })
            
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([reques])
                } catch {
                    print(error)
                }
            }
            
            
        }
    }
    
}

