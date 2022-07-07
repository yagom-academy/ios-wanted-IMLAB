

import Foundation
import UIKit

extension UIImage {
    func aspectFitImage(inRect rect: CGRect) -> UIImage? {
        let width = self.size.width
        let height = self.size.height
        let scaleFactor = rect.size.height / height

        UIGraphicsBeginImageContext(CGSize(width: width * scaleFactor, height: height * scaleFactor))
        self.draw(in: CGRect(x: 0.0, y: 0.0, width: width * scaleFactor, height: height * scaleFactor))

        defer {
            UIGraphicsEndImageContext()
        }

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIImageView{
    func load(url : URL , completion : @escaping ()->Void){
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url){
                if let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        let resizedImage = image.aspectFitImage(inRect: self?.bounds ?? CGRect(x: 0, y: 0, width: 10, height: 10))
                        self?.image = resizedImage
                        completion()
                    }
                }
            }
        }
    }
}
