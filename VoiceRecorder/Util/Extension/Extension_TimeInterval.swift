
import Foundation

extension TimeInterval{
    
    func getStringTimeInterval() -> String {
        
        let seconds = self
        let hour = Int(seconds) / (60 * 60)
        let min = Int(seconds) / 60
        let sec = Int(seconds) % 60
        let cen = Int(seconds * 100) % 100
        
        if hour == 0{
            let formatString = "%0.2d:%0.2d:%0.2d"
            return String(format: formatString, min, sec, cen)
        }else{
            let formatString = "%0.2d:%0.2d:%0.2d"
            return String(format: formatString, hour, min, sec)
        }
        
    }
}
