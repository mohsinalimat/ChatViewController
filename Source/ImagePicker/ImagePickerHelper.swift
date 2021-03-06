//
//  ImagePickerHelper.swift
//  ChatViewController
//
//  Created by Hoangtaiki on 6/11/18.
//  Copyright © 2018 toprating. All rights reserved.
//

import UIKit

/// Protocol use to specify standard for ImagePickerHelper
public protocol ImagePickerHelperable {
    // We new a variable to store parent view controller to present ImagePickerController
    var parentViewController: UIViewController? { get set }
    // Open camera
    func accessCamera()
    // Open photo library
    func accessLibrary()
}

/// Image picker result
public protocol ImagePickerHelperResultDelegate {
    func didFinishPickingMediaWithInfo(_ image: UIImage?, _ imagePath: URL?, _ error: Error?)
}

public class ImagePickerHelper: NSObject, ImagePickerHelperable, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public weak var parentViewController: UIViewController?
    public var delegate: ImagePickerHelperResultDelegate?

    public func accessPhoto(from sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType

        parentViewController?.present(imagePicker, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true, completion: nil)
        }

        DispatchQueue.global(qos: .userInitiated).async {
            guard let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                return
            }

            originalImage.storeToTemporaryDirectory(completion: { [weak self] (imagePath, error) in
                if error != nil {
                    self?.delegate?.didFinishPickingMediaWithInfo(nil, nil, error!)
                    return
                }
                self?.delegate?.didFinishPickingMediaWithInfo(originalImage, imagePath!, nil)
            })
        }
    }
    
    public func accessCamera() {
        accessPhoto(from: .camera)
    }
    
    public func accessLibrary() {
        accessPhoto(from: .photoLibrary)
    }
}
