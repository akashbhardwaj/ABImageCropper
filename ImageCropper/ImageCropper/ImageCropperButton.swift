//
//  ImageCropperButton.swift
//  ImageCropper
//
//  Created by Akash Bhardwaj on 30/10/18.
//  Copyright © 2018 Akash Bhardwaj. All rights reserved.
//

import Foundation
import UIKit
public enum ABPickerResult {
    case success(URL?) // Path to file in local file system
    case failure(ABPickerError)
}
public enum ABPickerError {
    case cameraNotFound
    case photoLibrary
    case pickerCanceled
    case imageNotPicked
}
public enum ABPickerType {
    case camera
    case photoLibrary
    case both
}
public typealias ABImageCropperButtonCallback = (ABPickerResult) -> ()

public class ABImageCropperButton: UIButton {
    
    
    var callback: ABImageCropperButtonCallback?
    private var pickerType: ABPickerType? = .both
    private var fileName: String = "abImagePicked"
    private var filePath: URL?
    private var imagePicker: UIImagePickerController? {
        didSet {
            imagePicker?.delegate = self
        }
    }
    
    private var rootViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    
    public override func awakeFromNib() {
        self.addTarget(self, action: #selector(ABImageCropperButton.buttonPressed(_:)), for: .allEvents)
    }
    
    @objc // buttonAction
    func buttonPressed(_ sender: ABImageCropperButton) {
        guard let pickerType = self.pickerType else { return }
        selectImage(withFileName: fileName, pickerType: pickerType)
    }
    
    @discardableResult
    func config(pickerType: ABPickerType, fileName: String = "#abImagePicked") -> ABImageCropperButton {
        self.pickerType = pickerType
        self.fileName = fileName
        return self
    }
    
    
    func selectImage(withFileName fileName: String, pickerType: ABPickerType) {
        self.filePath = pathToDirectory()
        self.filePath?.appendPathComponent(fileName)
        self.openPicker(withPickerType: pickerType)
    }
    
    func openPicker(withPickerType pickerType: ABPickerType) {
        guard let rootController = self.rootViewController else { return }
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        
        switch  pickerType {
        case .camera:
            addCamera(toActionSheet: actionSheet)
        case .photoLibrary:
            addPhotoLibrary(toActionSheet: actionSheet)
        default:
            addCamera(toActionSheet: actionSheet)
            addPhotoLibrary(toActionSheet: actionSheet)
            break
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            // cancel
        }
        actionSheet.addAction(cancelAction)
        rootController.present(actionSheet, animated: true, completion: nil)
        
    }

    func addCamera(toActionSheet actionSheet: UIAlertController) {
        self.imagePicker = UIImagePickerController()
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker?.sourceType = .camera
                guard let rootViewController = self.rootViewController, let imagePicker = self.imagePicker else { return }
                rootViewController.present(imagePicker, animated: true, completion: nil)
            } else {
                let error = ABPickerError.cameraNotFound
                let cameraNotFoundFailure = ABPickerResult.failure(error)
                self.callback?(cameraNotFoundFailure)
            }
        }
        actionSheet.addAction(cameraAction)
    }
    
    func addPhotoLibrary(toActionSheet actionSheet: UIAlertController) {
        self.imagePicker = UIImagePickerController()
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.imagePicker?.sourceType = .photoLibrary
                guard let rootViewController = self.rootViewController, let imagePicker = self.imagePicker else { return }
                rootViewController.present(imagePicker, animated: true, completion: nil)
            } else {
                let error = ABPickerError.photoLibrary
                let photoLibraryError = ABPickerResult.failure(error)
                self.callback?(photoLibraryError)
            }
        }
        actionSheet.addAction(photoLibraryAction)
    }
    
}
extension ABImageCropperButton: UINavigationControllerDelegate {
    
}
extension ABImageCropperButton: UIImagePickerControllerDelegate  {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let imagePicked = info[.originalImage] as? UIImage else {
            let error = ABPickerError.imageNotPicked
            let imageNotFoundFailure = ABPickerResult.failure(error)
            self.callback?(imageNotFoundFailure)
            picker.dismiss(animated: true, completion: nil)
            return
        }
        if let data = imagePicked.jpegData(compressionQuality: 0.4) {
            do {
                guard let filePathUrl = self.filePath else { fatalError("path not valid") }
                try data.write(to: filePathUrl, options: Data.WritingOptions.atomic)
            } catch (let error) {
                print(error)
            }
        }
        guard let callback = self.callback, let filePath = self.filePath else { return }
        let success = ABPickerResult.success(filePath)
        callback(success)
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        let error = ABPickerError.pickerCanceled
        let pickerCancelFailure = ABPickerResult.failure(error)
        self.callback?(pickerCancelFailure)
        picker.dismiss(animated: true, completion: nil)
    }
}
// Document Read And Write Functions
extension ABImageCropperButton {
    // path to pictures directory
    func pathToDirectory () -> URL {
        guard let documentDirectory = FileManager().urls(for: .documentDirectory, in: .allDomainsMask).first else {
            fatalError("document directory not found")
        }
        return documentDirectory
    }
}
