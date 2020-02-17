//
//  ViewController.swift
//  CollectionVIew
//
//  Created by iim jobs on 14/02/20.
//  Copyright © 2020 iim jobs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textLabel: UILabel!
    
    private let reuseIdentifier = "FlickrCell"
    
    private let sectionInsets = UIEdgeInsets(top: 50.0,
    left: 20.0,
    bottom: 50.0,
    right: 20.0)
    
    private var searches: [FlickrSearchResults] = []
    private let flickr = Flickr()
    
    private let itemsPerRow: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

// MARK: - Text Field Delegate
extension ViewController : UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    textField.addSubview(activityIndicator)
    activityIndicator.frame = textField.bounds
    activityIndicator.startAnimating()
    
    flickr.searchFlickr(for: textField.text!) { searchResults in activityIndicator.removeFromSuperview()
      
      switch searchResults {
      case .error(let error) :
        print("Error Searching: \(error)")
      case .results(let results):
        print("Found \(results.searchResults.count) matching \(results.searchTerm)")
        if(results.searchResults.count > 0) {
            self.textLabel.isHidden = true
        } else {
            self.textLabel.isHidden = false
            self.textLabel.text = "Found \(results.searchResults.count) matching \(results.searchTerm)"
        }
        self.searches.removeAll()
        self.searches.insert(results, at: 0)
        self.collectionView?.reloadData()
      }
    }
    
    textField.text = nil
    textField.resignFirstResponder()
    return true
  }
}


private extension ViewController {
  func photo(for indexPath: IndexPath) -> FlickrPhoto {
    return searches[indexPath.section].searchResults[indexPath.row]
  }
}

extension ViewController: UICollectionViewDataSource{
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return searches.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    return searches[section].searchResults.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlickrPhotoCell

    let flickrPhoto = photo(for: indexPath)
    cell.backgroundColor = .white

    cell.imageView.image = flickrPhoto.thumbnail
      
    return cell
  }
}

// MARK: - Collection View Flow Layout Delegate
extension ViewController : UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow
    
    return CGSize(width: widthPerItem, height: widthPerItem)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
}
