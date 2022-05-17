//
//  WebView.swift
//  LeanSdk
//
//  Created by Fede Ruiz on 09/05/2022.
//

import UIKit
import WebKit

typealias MessageHandler = (_ message: String) -> Void

class WebViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler, UIGestureRecognizerDelegate {
    private var tapOutsideRecognizer: UITapGestureRecognizer!
    public var webView: WKWebView!
    var url: String
    var isFullScreen: Bool
    var messageHandler: MessageHandler
    var auth: String
    init(url: String, auth: String, isFullScreen: Bool, messageHandler: @escaping MessageHandler) {
        self.url = url
        self.isFullScreen = isFullScreen
        self.messageHandler = messageHandler
        self.auth = auth
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = self.isFullScreen ? .fullScreen : .overCurrentContext
        self.modalTransitionStyle = self.isFullScreen ? .coverVertical : .crossDissolve
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
    }
    override func viewDidLoad() {
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = WKUserContentController()
        webConfiguration.userContentController.add(self, name: "uiControls")
        let cookie = HTTPCookie(properties: [
            .domain: url.replacingOccurrences(of: "https://", with: "").split(separator: "/")[0],
            .path: "/",
            .name: "auth",
            .value: auth,
            .secure: "TRUE",
            .expires: NSDate(timeIntervalSinceNow: 31556926)
        ])!
        webConfiguration.websiteDataStore.httpCookieStore.setCookie(cookie)
        webView = WKWebView(frame: self.isFullScreen ? CGRect( x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height) : CGRect( x: 0, y: self.view.frame.height / 2, width: self.view.frame.width, height: 274 ), configuration: webConfiguration)
        webView.uiDelegate = self
        webView.scrollView.bounces = false
        self.view.addSubview(webView)
        
        let myURL = URL(string:self.url)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, animations: {
            self.view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            
        }) { (success) in
            self.view.layoutIfNeeded() // add this
        }
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.messageHandler(String(describing: message.body))
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if (self.tapOutsideRecognizer == nil) {
            self.tapOutsideRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapBehind))
            self.tapOutsideRecognizer.numberOfTapsRequired = 1
            self.tapOutsideRecognizer.cancelsTouchesInView = false
            self.tapOutsideRecognizer.delegate = self
            self.view.window?.addGestureRecognizer(self.tapOutsideRecognizer)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if(self.tapOutsideRecognizer != nil) {
            self.view.window?.removeGestureRecognizer(self.tapOutsideRecognizer)
            self.tapOutsideRecognizer = nil
        }
    }

    func close(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Gesture methods to dismiss this with tap outside
    @objc func handleTapBehind(sender: UITapGestureRecognizer) {
        if (sender.state == UIGestureRecognizer.State.ended) {
            let location: CGPoint = sender.location(in: self.webView)
            if (!self.webView.point(inside: location, with: nil)) {
                self.view.window?.removeGestureRecognizer(sender)
                self.close(sender: sender)
            }
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}