import UIKit
import WebKit

typealias MessageHandler = (_ message: String) -> Void


class WebViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler, UIGestureRecognizerDelegate {
    private var tapOutsideRecognizer: UITapGestureRecognizer!
    public var webView: WKWebView!
    
    let url: String
    let isFullScreen: Bool
    let messageHandler: MessageHandler
    let theme: Theme
    let parentView: UIView
    
    let auth: String
    init(parentView: UIView, url: String, auth: String, isFullScreen: Bool, theme userTheme: Theme?, messageHandler: @escaping MessageHandler) {
        self.url = url
        self.isFullScreen = isFullScreen
        self.messageHandler = messageHandler
        self.theme = userTheme ?? Theme()
        self.auth = auth
        self.parentView = parentView
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
        webView = WKWebView(frame: self.isFullScreen ? CGRect( x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height) : CGRect( x: 0, y: 0, width: parentView.frame.width, height: parentView.frame.height), configuration: webConfiguration)
        webView.uiDelegate = self
        webView.scrollView.bounces = false
        webView.backgroundColor = .white
        self.view.addSubview(webView)
        
        self.view.frame = CGRect( x: 0, y: 0, width: parentView.frame.width, height: parentView.frame.height)
        let myURL = URL(string:self.url)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
        webView.evaluateJavaScript("""
              const root = document.documentElement;
              root.style.setProperty('--lean-color-primary', \(theme.color["primary"] ?? ""));
              root.style.setProperty('--lean-color-secondary', \(theme.color["primary"] ?? ""));
              root.style.setProperty('--lean-color-error', \(theme.color["secondary"] ?? ""));

              
              root.style.setProperty('--lean-color-text-primary', \(theme.color["textPrimary"] ?? ""));
              root.style.setProperty('--lean-color-text-secondary', \(theme.color["textSecondary"] ?? ""));
              root.style.setProperty('--lean-color-text-interactive', \(theme.color["textInteractive"] ?? ""));

              root.style.setProperty('--lean-font-family', \(theme.fontFamily));

              root.style.setProperty('--lean-font-weight-light', \(theme.fontWeight["light"] ?? ""));
              root.style.setProperty('--lean-font-weight-regular', \(theme.fontWeight["regular"] ?? ""));
              root.style.setProperty('--lean-font-weight-medium', \(theme.fontWeight["medium"] ?? ""));
              root.style.setProperty('--lean-font-weight-semibold', \(theme.fontWeight["semibold"] ?? ""));
              root.style.setProperty('--lean-font-weight-bold', \(theme.fontWeight["bold"] ?? ""));
        """)
        
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
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.targetFrame == nil {
                if let url = navigationAction.request.url {
                    let app = UIApplication.shared
                    if app.canOpenURL(url) {
                        app.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            decisionHandler(.allow)
        }
    
}
