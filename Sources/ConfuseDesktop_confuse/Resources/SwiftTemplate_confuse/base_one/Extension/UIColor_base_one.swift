import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexstring_Base_one: String, alpha_Base_one: CGFloat = 1.0) {
        
        var cgString_Base_one = hexstring_Base_one.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
        if cgString_Base_one.hasPrefix("#") {
            cgString_Base_one = String(cgString_Base_one.dropFirst())
        }
        
        
        guard cgString_Base_one.count == 6 else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue_Base_one: UInt64 = 0
        Scanner(string: cgString_Base_one).scanHexInt64(&rgbValue_Base_one)
        
        let r_Base_one = CGFloat((rgbValue_Base_one & 0xFF0000) >> 16) / 255.0
        let g_Base_one = CGFloat((rgbValue_Base_one & 0x00FF00) >> 8) / 255.0
        let b_Base_one = CGFloat(rgbValue_Base_one & 0x0000FF) / 255.0
        
        self.init(red: r_Base_one, green: g_Base_one, blue: b_Base_one, alpha: alpha_Base_one)
    }
}
