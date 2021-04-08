//
//  ViewController.swift
//  FoodDetection
//  Created by Anmol's Mac on 11/29/20.
//
import UIKit
import CoreML
import Vision
import AVFoundation


class ViewController: UIViewController, FrameFetcherDelegate {
  
    var frameExtracter: FrameFetcher!
    
    @IBOutlet weak var ImagePreview: UIImageView!
    @IBOutlet weak var iDetect: UILabel!
    
    var setImage = false
    
    var presentImage: CIImage?{
        didSet{
            if let image = presentImage{
                self.detectScene(image: image)
            }
        }
    }
    
    override func viewDidLoad() {
       super.viewDidLoad()
       frameExtracter = FrameFetcher()
       frameExtracter.delegate = self
     }
    
    func captured(image: UIImage){
        
        self.ImagePreview.image = image
        if let cgImage = image.cgImage, !setImage {
              setImage = true
              DispatchQueue.global(qos: .userInteractive).async {[unowned self] in
                self.presentImage = CIImage(cgImage: cgImage)
    }
    }
  }

func Emoji(id: String) -> String {
    switch id {
    case "pizza":
      return "🍕"
    case "hot dog":
      return "🌭"
    case "chicken wings":
      return "🍗"
    case "french fries":
      return "🍟"
    case "sushi":
      return "🍣"
    case "chocolate cake":
      return "🍫🍰"
    case "donut":
      return "🍩"
    case "spaghetti bolognese":
      return "🍝"
    case "caesar salad":
      return "🥗"
    case "macaroni and cheese":
      return "🧀"
    default:
      return ""
    }
  }


func detectScene(image: CIImage) {
    
    let config = MLModelConfiguration()
    guard let model = try? VNCoreMLModel(for: food(configuration: config).model) else {
    fatalError()
    }
    
   // Create a Vision request with completion handler
    
        let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
        guard let results = request.results as? [VNClassificationObservation],
        let _ = results.first else {
            self?.setImage = false
         return
     
        }
     //Update UI on main Queue
            
     DispatchQueue.main.async { [unowned self] in
       if let first = results.first {
          if Int(first.confidence * 100) > 1 {
            self?.iDetect.text = "I see \(first.identifier) \(self!.Emoji(id: first.identifier))"
            self?.setImage = false
            
         }
       }
     }
   })
        
   let handler = VNImageRequestHandler (ciImage: image)
   DispatchQueue.global(qos: .userInteractive).async {
     do {
       try handler.perform([request])
     } catch {
       print(error)
        
      }
    }
  }
}

