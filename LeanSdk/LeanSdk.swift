import Foundation
import UIKit
import SwiftUI

enum CustomerStatus: String {
    case SIGNUP
    case SIGNUP_RETRY
    case PENDING_REVIEW
    case CLOSED
    case SUSPENDED
    case CONFIRMED
}

let webviewHosts = [
    "SANDBOX": "https://sdk-web.sandbox.withlean.com/",
    "PRODUCTION": "https://sdk-web.production.withlean.com/",
    "STAGING": "https://sdk-web.staging.withlean.com/"
]

public class Lean {
        
    var dashboardWebViewController: WebViewController! = nil
    var signupWebViewController: WebViewController! = nil
    var cardWebViewController: WebViewController! = nil
    var accountWebViewController: WebViewController! = nil
    var transactionsWebViewController: WebViewController! = nil
    var customerStatus: CustomerStatus
    var customerToken: String
    var webviewHost: String
    var parentView: UIView
    
    public init(parentView: UIView, userToken: String, theme: Theme?, options: [String: String]? = nil) {
        self.parentView = parentView
        let host = webviewHosts[options?["environment"] ?? "PRODUCTION"]
        webviewHost = host ?? webviewHosts["PRODUCTION"]!
        customerToken = userToken
        customerStatus = CustomerStatus(rawValue: String(describing: decode(jwtToken: userToken)["status"]!)) ?? CustomerStatus.SIGNUP
        var url = ""
        switch customerStatus {
            case CustomerStatus.CONFIRMED:
                url = "dashboard"
                break
            default:
                url = "signup"
        }
       
        let controller = WebViewController(parentView: parentView, url: webviewHost + "initial/" + url, auth: userToken, isFullScreen: false, theme: theme, messageHandler: self.messageHandler)
        self.dashboardWebViewController = controller
        
        let signupWebViewController = WebViewController(parentView: parentView, url: webviewHost + "onboarding/introduction", auth: userToken, isFullScreen: true, theme: theme, messageHandler: self.messageHandler)
        self.signupWebViewController = signupWebViewController
        
        let cardWebViewController = WebViewController(parentView: parentView, url: webviewHost + "card", auth: userToken, isFullScreen: true, theme: theme, messageHandler: self.messageHandler)
        self.cardWebViewController = cardWebViewController
        
        let accountWebViewController = WebViewController(parentView: parentView, url: webviewHost + "account", auth: userToken, isFullScreen: true, theme: theme, messageHandler: self.messageHandler)
        self.accountWebViewController = accountWebViewController
        
        let transactionsWebViewController = WebViewController(parentView: parentView, url: webviewHost + "transactions/ledger", auth: userToken, isFullScreen: true, theme: theme, messageHandler: self.messageHandler)
        self.transactionsWebViewController = transactionsWebViewController
        
        DispatchQueue.global(qos: .background).async {
            // Background Thread
            DispatchQueue.main.async {
                // Run UI Updates
                controller.view.setNeedsLayout()
                signupWebViewController.view.setNeedsLayout()
                accountWebViewController.view.setNeedsLayout()
                cardWebViewController.view.setNeedsLayout()
            }
        }
        self.showController()
    }
    
    func presentController(controller: UIViewController, animated: Bool) {
        var parentViewController: UIViewController? {
                // Starts from next (As we know self is not a UIViewController).
                var parentResponder: UIResponder? = parentView.next
                while parentResponder != nil {
                    if let viewController = parentResponder as? UIViewController {
                        return viewController
                    }
                    parentResponder = parentResponder?.next
                }
                return nil
            }
        if (parentViewController != nil) {
            parentViewController!.present(controller, animated: animated, completion: nil)
        }
    }
    
    private func messageHandler(data: String) {
        switch data {
        case "dismiss", "complete-onboarding":
            signupWebViewController.dismiss(animated: true, completion: nil)
            accountWebViewController.dismiss(animated: true, completion: nil)
            cardWebViewController.dismiss(animated: true, completion: nil)
            transactionsWebViewController.dismiss(animated: true, completion: nil)
            if (self.customerStatus != CustomerStatus.CONFIRMED && data == "complete-onboarding") {
                self.customerStatus = CustomerStatus.CONFIRMED
                let url = URL(string:self.webviewHost + "initial/dashboard")
                let request = URLRequest(url: url!)
                self.dashboardWebViewController.webView.load(request)
            }
            
            break
        case "navigate-signup":
            presentController(controller: signupWebViewController, animated: true)
            break
        case "navigate-account":
            presentController(controller: accountWebViewController, animated: true)
            break
        case "navigate-card":
            presentController(controller: cardWebViewController, animated: true)
            break
        case "navigate-transactions":
            presentController(controller: transactionsWebViewController, animated: true)
            break
        default:
            if (data.starts(with: "openUrl-")) {
                let messageParts = String(data).replacingOccurrences(of: "openUrl-", with: "")
                print(messageParts);
                if let url = URL(string: messageParts) {
                    UIApplication.shared.open(url)
                }
            }
            break
        }
    }

    public func showController() {
        parentView.addSubview(dashboardWebViewController.view)
    }
}
