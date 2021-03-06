//
//  DetailViewController.swift
//  NYTBestsellers
//
//  Created by Aaron Cabreja on 1/28/19.
//  Copyright © 2019 Pursuit. All rights reserved.
//

import UIKit
import SafariServices

class DetailViewController: UIViewController {
  
  let detailView = DetailView()
  var currentBook: BookResults!
  var book: Book?
  var bookIndex: Int?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(detailView)
    detailView.delegate = self
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Favorite", style: .plain, target: self, action: #selector(favorite))
    configureView()
  }
  
  private func configureView(){
    detailView.label.text = currentBook.bookDetails.first?.author
    
    APIClient.getGoogleImage(keyword: (currentBook.bookDetails.first?.primaryIsbn13)!) { (result) in
      switch result{
      case .failure(let error):
        DispatchQueue.main.async {
          print(error)
        }
      case .success(let data):
        DispatchQueue.main.async {
          self.detailView.textView.text = data?.description
          guard let imageData = data?.imageLinks.thumbnail else {
            return self.detailView.image.image = UIImage(named: "icons8-book")
          }
          self.detailView.image.getImage(with: imageData) { (result) in
            switch result{
            case .failure(let error):
              print(error)
            case .success(let image):
              DispatchQueue.main.async {
                self.detailView.image.image = image
              }
            }
          }
        }
      }
    }
  }
  
  @objc private func favorite(){
    let date = Date()
    let isoDateFormatter = ISO8601DateFormatter()
    isoDateFormatter.formatOptions = [.withFullDate,
                                      .withFullTime,
                                      .withInternetDateTime,
                                      .withTimeZone,
                                      .withDashSeparatorInDate]
    let timestamp = isoDateFormatter.string(from: date)
    if let image = detailView.image.image, let text = detailView.textView.text{
      if let imageData = image.jpegData(compressionQuality: 0.5){
        let bookFavorites = Book.init(weeks_on_list: currentBook!.weeksOnList, author: (currentBook.bookDetails.first?.author)!, imageData: imageData, description: text, createdAt: timestamp)
        if bookFavorites.description == BookModel.getBook().first?.description {
          alreadyFavorited(title: "You already Favorited this item!", message: "Will not duplicate!")
        } else {
          BookModel.addBook(book: bookFavorites)
          showAlert(title: "Succesfully Favorited Book", message: "")
        }
        
      }
    }
    dismiss(animated: true, completion: nil)
  }
  
  
}
extension DetailViewController: DetailViewDelegate {

  func amazonPressed() {
    guard let urlString = currentBook.amazonProductUrl else {return}
    guard let url = URL(string: urlString) else {return}
    print(url)
    let safariVC = SFSafariViewController(url: url)
    present(safariVC, animated: true, completion: nil)
    
  }
  
}
