//
//  GallleryViewController.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 10/31/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import UIKit

class GalleryCollectionViewController: UICollectionViewController {
    
    private let data = Art.getArt()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Gallery"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = .groupTableViewBackground
        self.collectionView.register(ArtCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnTap = false
    }
    
}

//Setup colllectionview delegate and datasource
extension GalleryCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ArtCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(name: data[indexPath.row].name, image: data[indexPath.row].image)
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width / 2 - 12, height: 250)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    internal override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let art = self.data[indexPath.row]
        let configuration = ARAugmentedRealityConfig(with: art.image, size: art.size)
        let controller = PreviewViewController()
        controller.initWith(config: configuration)
        self.show(controller, sender: nil)
    }
    
}
