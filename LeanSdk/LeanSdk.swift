//
//  LeanSdk.swift
//  LeanSdk
//
//  Created by Fede Ruiz on 09/05/2022.
//

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

let WEBVIEW_HOST = "https://sdk-web.staging.withlean.com/"

public class LeanSdkController {
        
    var dashboardWebViewController: WebViewController! = nil
    var signupWebViewController: WebViewController! = nil
    var cardWebViewController: WebViewController! = nil
    var accountWebViewController: WebViewController! = nil
    var transactionsWebViewController: WebViewController! = nil
    var customerStatus: CustomerStatus
    var customerToken: String
    var parentController: UIViewController! = nil
    
    public init(parentController: UIViewController, userToken: String, theme: Theme?) {
        self.parentController = parentController
        customerToken = userToken
        customerStatus = CustomerStatus(rawValue: String(describing: decode(jwtToken: userToken)["status"]!)) ?? CustomerStatus.SIGNUP
        var url = ""
        print(customerStatus)
        switch customerStatus {
            case CustomerStatus.CONFIRMED:
                url = "dashboard"
                break
            default:
                url = "signup"
        }
        
        let controller = WebViewController(url: WEBVIEW_HOST + "initial/" + url, auth: userToken, isFullScreen: false, theme: theme, messageHandler: self.messageHandler)
        self.dashboardWebViewController = controller
        
        let signupWebViewController = WebViewController(url: WEBVIEW_HOST + "onboarding/introduction", auth: userToken, isFullScreen: true, theme: theme, messageHandler: self.messageHandler)
        self.signupWebViewController = signupWebViewController
        
        let cardWebViewController = WebViewController(url: WEBVIEW_HOST + "card", auth: userToken, isFullScreen: true, theme: theme, messageHandler: self.messageHandler)
        self.cardWebViewController = cardWebViewController
        
        let accountWebViewController = WebViewController(url: WEBVIEW_HOST + "account", auth: userToken, isFullScreen: true, theme: theme,  messageHandler: self.messageHandler)
        self.accountWebViewController = accountWebViewController
        
        let transactionsWebViewController = WebViewController(url: WEBVIEW_HOST + "transactions/ledger", auth: userToken, isFullScreen: true, theme: nil,  messageHandler: self.messageHandler)
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
    }
    
    func presentController(controller: UIViewController, animated: Bool) {
        parentController.present(controller, animated: animated, completion: nil)
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
                let url = URL(string:WEBVIEW_HOST + "initial/dashboard")
                let request = URLRequest(url: url!)
                self.dashboardWebViewController.webView.load(request)
            }
            presentController(controller: dashboardWebViewController, animated: false)
            break
        case "navigate-signup":
            self.dashboardWebViewController.dismiss(animated: false, completion: nil)
            presentController(controller: signupWebViewController, animated: true)
            break
        case "navigate-account":
            self.dashboardWebViewController.dismiss(animated: false, completion: nil)
            presentController(controller: accountWebViewController, animated: true)
            break
        case "navigate-card":
            self.dashboardWebViewController.dismiss(animated: false, completion: nil)
            presentController(controller: cardWebViewController, animated: true)
            break
        case "navigate-transactions":
            self.dashboardWebViewController.dismiss(animated: false, completion: nil)
            presentController(controller: transactionsWebViewController, animated: true)
            break
        default:
            break
        }
    }

    public func showController() {
        presentController(controller: dashboardWebViewController, animated: true)
    }
}
