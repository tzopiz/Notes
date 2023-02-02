//
//  Resources.swift
//  NOTES
//
//  Created by Дмитрий Корчагин on 01.02.2023.
//

import UIKit

enum res{
    enum colors{
        static let active = UIColor(hexString: "#437BFE")
        static let inactive = UIColor(hexString: "#929DA5")

        static let background = UIColor(hexString: "#F8F9F9")
        static let separator = UIColor(hexString: "#E8ECEF")
        static let secondary = UIColor(hexString: "#F0F3FF")

        static let titleGray = UIColor(hexString: "#545C77")
    }
    enum fonts{
        static func font(named name: String, _ size: CGFloat) -> UIFont? {
            switch name {
            case "thin": return UIFont(name: "AppleSDGothicNeo-Thin", size: size)
            case "light": return UIFont(name: "AppleSDGothicNeo-Light", size: size)
            case "regular": return UIFont(name: "AppleSDGothicNeo-Regular", size: size)
            case "bold": return UIFont(name: "AppleSDGothicNeo-Bold", size: size)
            default:
                return UIFont()
            }
        }
    }
    enum images{
        static func image(named name: String) -> UIImage? {
               switch name {
               case "options": return  UIImage(systemName: "square.and.pencil")
               case "copy": return UIImage(systemName: "doc.on.doc")
               case "rename": return UIImage(systemName: "pencil")
               case "duplicate": return UIImage(systemName: "plus.square.on.square")
               case "delete": return UIImage(systemName: "trash")
               case "share": return UIImage(systemName: "square.and.arrow.up")
               case "cell": return UIImage(systemName: "swift")
                   
               default: return UIImage()
               }
           }
    }
}
