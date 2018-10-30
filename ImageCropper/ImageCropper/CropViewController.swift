//
//  CropViewController.swift
//  ImageCropper
//
//  Created by Akash Bhardwaj on 30/10/18.
//  Copyright © 2018 Akash Bhardwaj. All rights reserved.
//

import UIKit

class CropViewController: UIViewController {
    var image: UIImage?
    var imageView: UIImageView!
    var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupImageView()
        // Do any additional setup after loading the view.
    }
    func setupScrollView() {
        self.scrollView = UIScrollView()
        self.view.addSubview(scrollView)
        self.scrollView?.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10.0).isActive = true
        scrollView?.trailingAnchor.constraint(equalToSystemSpacingAfter: self.view.trailingAnchor, multiplier: 10.0).isActive = true
        scrollView?.heightAnchor.constraint(equalToConstant: self.view.frame.height - 200).isActive = true
        scrollView?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0.0).isActive = true
        scrollView?.delegate = self
    }
    
    func setupImageView () {
        guard let selectedImage = self.image else {
            return
        }
        self.imageView = UIImageView()
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: selectedImage.size.width, height: selectedImage.size.height)
        self.imageView.image = self.image
        self.imageView.contentMode = .center
        self.imageView.isUserInteractionEnabled = true
        self.scrollView.addSubview(self.imageView)
        self.scrollView.contentSize = selectedImage.size
        
        let scrollVeiwFrame = self.scrollView.frame
        let scaleWidth = scrollVeiwFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollVeiwFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        
        self.scrollView.minimumZoomScale = minScale
        self.scrollView.maximumZoomScale = 1
        self.scrollView.zoomScale = minScale
        centerScrollViewContent()
    }
    
    
    func centerScrollViewContent () {
        let boundSize = self.scrollView.bounds.size
        var contentFrame = imageView.frame
        
        if contentFrame.size.width < boundSize.width {
            contentFrame.origin.x = boundSize.width - contentFrame.size.width / 2
        } else {
            contentFrame.origin.x = 0
        }
        if contentFrame.size.height < boundSize.height {
            contentFrame.origin.y = boundSize.height - contentFrame.size.height / 2
        } else {
            contentFrame.origin.y = 0

        }
        
        self.imageView.frame = contentFrame
        
    }
    
    
    func cropImage () {
        UIGraphicsBeginImageContextWithOptions(self.scrollView.bounds.size, true, UIScreen.main.scale)
        let offset = scrollView.contentOffset
        UIGraphicsGetCurrentContext()?.translateBy(x: -offset.x, y: -offset.y)
//        CGContext.translateBy(UIGraphicsGetCurrentContext(), -offset.x, -offset.y)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        print("done")
    }
}
extension CropViewController: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContent()
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

