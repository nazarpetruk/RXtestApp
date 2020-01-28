//
//  ViewController.swift
//  RXtestApp
//
//  Created by Nazar Petruk on 28/01/2020.
//  Copyright © 2020 Nazar Petruk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MainViewController: UIViewController {
    
    
//MARK: IBOutlets
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var itemAdd: UIBarButtonItem!
    
    //MARK: Variables
    private let disposeBag = DisposeBag()
    private let images = Variable<[UIImage]>([])
    
    
    override func viewDidLoad() {
      super.viewDidLoad()
        images.asObservable().subscribe(onNext: {
            [weak self] photos in
            guard let preview = self?.imagePreview else {return}
            preview.image = UIImage.collage(images: photos, size: preview.frame.size)
            })
            .disposed(by: disposeBag)
        
        images.asObservable().subscribe(onNext:{
            [weak self] photos in self?.updateUI(photos: photos)
        })
            .disposed(by: disposeBag)
    }
    
    @IBAction func actionClear() {
        images.value = []
    }

    @IBAction func actionSave() {
        
        guard let image = imagePreview.image else {return}
        
        PhotoWriter.save(image).subscribe(onError: {
            [weak self] error in
            self?.showMessage("Error", description: error.localizedDescription)
            }, onCompleted: {
                [weak self] in
                self?.showMessage("Saved")
                self?.actionClear()
            }).disposed(by: disposeBag)
    }

    @IBAction func actionAdd() {
        //images.value.append(UIImage(named: "IMG_1907.jpg")!)
        let photosViewController = storyboard!.instantiateViewController(identifier: "PhotosVC") as! PhotosVC
        navigationController?.pushViewController(photosViewController, animated: true)
        photosViewController.selectedPhotos.subscribe(onNext: {
            [weak self] newImage in
            guard let images = self?.images else {return}
            images.value.append(newImage)
            },onDisposed: {
                print("Completed Photo selection")
        }).disposed(by: photosViewController.disposeBag2)
    }

    func showMessage(_ title: String, description: String? = nil) {
      let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in self?.dismiss(animated: true, completion: nil)}))
      present(alert, animated: true, completion: nil)
    }
    
    private func updateUI(photos: [UIImage]) {
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = photos.count > 0
        itemAdd.isEnabled = photos.count < 6
        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }
}

