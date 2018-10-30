//
//  ViewController.swift
//  ImageCropper
//
//  Created by Akash Bhardwaj on 30/10/18.
//  Copyright © 2018 Akash Bhardwaj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imagePicekr: ABImageCropperButton!
    override func viewDidLoad() {
        super.viewDidLoad()
//        imagePicekr.config(pickerType: .both)
        imagePicekr.callback = imagePickerResult
    }
    
    func imagePickerResult(result: ABPickerResult) {
        print(result)
    }

}

