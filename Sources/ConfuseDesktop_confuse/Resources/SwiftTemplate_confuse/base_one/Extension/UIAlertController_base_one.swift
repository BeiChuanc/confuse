import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Base_one(completion_Base_one: @escaping() -> Void) {
        let alert_Base_one = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Base_one = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Base_one()
        })
        let cancel_Base_one = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Base_one.addAction(confirm_Base_one)
        alert_Base_one.addAction(cancel_Base_one)
        UIViewController.currentViewController_Base_one()?.present(alert_Base_one, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Base_one(completion_Base_one: @escaping() -> Void) {
        let alert_Base_one = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Base_one = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Base_one()
        })
        let cancel_Base_one = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Base_one.addAction(confirm_Base_one)
        alert_Base_one.addAction(cancel_Base_one)
        UIViewController.currentViewController_Base_one()?.present(alert_Base_one, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Base_one(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Base_one: UIAlertController!
        reportAlter_Base_one = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Base_one = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Base_one = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Base_one = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Base_one = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Base_one = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Base_one.addAction(report1_Base_one)
        reportAlter_Base_one.addAction(report2_Base_one)
        reportAlter_Base_one.addAction(report3_Base_one)
        reportAlter_Base_one.addAction(report4_Base_one)
        reportAlter_Base_one.addAction(cancel_Base_one)
        reportAlter_Base_one.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Base_one()?.present(reportAlter_Base_one, animated: true, completion: nil)
    }
}
