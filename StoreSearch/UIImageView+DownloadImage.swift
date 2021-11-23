//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by Hayley Robinson on 11/23/21.
//

import UIKit
extension UIImageView{
    func loadImage(url: URL) -> URLSessionDownloadTask{
        let session = URLSession.shared
        // saves the downloaded file to a temporary location on disk instead of keeping it in memory
        let downloadTask = session.downloadTask(with: url) {
           [weak self] url, _, error in
            if error == nil, let url = url,
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data) // Because this is UI code you need to do this on the main thread
                {
                // check whether “self” still exists; if not, then there is no more UIImageView to set the image on.
                DispatchQueue.main.async
                {
                  if let weakSelf = self{
                    weakSelf.image = image
              }
            }
          }
        }
        downloadTask.resume()
        return downloadTask
    }
}
