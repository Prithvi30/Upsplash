//
//  DetailsViewController.swift
//  UnsplashDemo
//
//  Created by Prithvi Raj on 17/03/19.
//  Copyright © 2019 Prithvi Raj. All rights reserved.
//

import UIKit
import CoreML

import CoreVideo


class DetailsViewController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!
    
    let model = GoogLeNetPlaces()
    var selectImage: BaseModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let url = URL(string: selectImage.fullURL)
        let imageData = NSData(contentsOf: url!)
        
        detailImageView.image = UIImage(data: imageData! as Data)
        
        if let imageToAnalyze = detailImageView.image {
            
            if let data = sceneLabel(forImage: imageToAnalyze) {
             imageLabel.text = data
                
            }
        }
    }
    
    
    func sceneLabel(forImage image:UIImage) -> String? {
   
        if let pixel = ImageProcessor.pixelBuffer(forImage: image.cgImage!){
            
            guard let scene = try? model.prediction(sceneImage: pixel) else { fatalError("error")}
            return scene.sceneLabel
        }
        return nil
    }
}


