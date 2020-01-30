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
    private var imageCache = [Int]()
    
    
    override func viewDidLoad() {
      super.viewDidLoad()
        let newImages = images.asObservable().share()
        newImages
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
            [weak self] photos in
            guard let preview = self?.imagePreview else {return}
            preview.image = UIImage.collage(images: photos, size: preview.frame.size)
            })
            .disposed(by: disposeBag)
        
        newImages.subscribe(onNext:{
            [weak self] photos in self?.updateUI(photos: photos)
        })
            .disposed(by: disposeBag)
    }
    
    @IBAction func actionClear() {
        images.value = []
        imageCache = []
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
        let photosViewController = storyboard!.instantiateViewController(identifier: "PhotosVC") as! PhotosVC
        navigationController?.pushViewController(photosViewController, animated: true)
        
        let newPhotos = photosViewController.selectedPhotos.share()
        newPhotos
        .takeWhile {
            [weak self] image in
            return (self?.images.value.count ?? 0) < 6
        }
        .filter {
                newImage in
                return newImage.size.width > newImage.size.height
        }
        .filter {
            [weak self] newImage in
            let len = UIImage.pngData(newImage)()?.count ?? 0
            guard self?.imageCache.contains(len) == false else {
                return false
            }
            self?.imageCache.append(len)
            return true
        }
        .subscribe(onNext: {
            [weak self] newImage in
            guard let images = self?.images else {return}
            images.value.append(newImage)
            },onDisposed: { print("Completed Photo selection")
        })
        .disposed(by: photosViewController.disposeBag2)
        
        
        
        
        newPhotos.ignoreElements().subscribe(onCompleted: {
            [weak self] in
            self?.updateNavigationIcon()
        })
            .disposed(by: disposeBag)
    }
    
    func showMessage(_ title: String, description: String? = nil) {
        alert(title: title, text: description).subscribe(onNext: {
            [weak self] in
            self?.dismiss(animated: true, completion: nil)
        })
            .disposed(by: disposeBag)
    }
    
    private func updateUI(photos: [UIImage]) {
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = photos.count > 0
        itemAdd.isEnabled = photos.count < 6
        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }
    
    private func updateNavigationIcon() {
        let icon = imagePreview.image?.scaled(CGSize(width: 22, height: 22)).withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon, style: .done, target: nil,action: nil)
    }
}

