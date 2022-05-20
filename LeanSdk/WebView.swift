import UIKit
import WebKit

typealias MessageHandler = (_ message: String) -> Void


class WebViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler, UIGestureRecognizerDelegate, WKNavigationDelegate {
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
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        webView.backgroundColor = .white
        self.view.addSubview(webView)
        
        self.view.frame = CGRect( x: 0, y: 0, width: parentView.frame.width, height: parentView.frame.height)
        let myURL = URL(string:self.url)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)

        super.viewDidLoad()
    }
    
    func webView(_ webView: WKWebView,
                              didFinish navigation: WKNavigation!) {
            let commands = [
                (theme.color["primary"] != "") ? "rootStyle.setProperty('--lean-color-primary', '\(theme.color["primary"]!)')" : "",
                (theme.color["secondary"] != "") ? "rootStyle.setProperty('--lean-color-secondary', '\(theme.color["secondary"]!)')" : "",
                (theme.color["error"] != "") ? "rootStyle.setProperty('--lean-color-error', '\(theme.color["error"]!)')" : "",
                
                (theme.color["textPrimary"] != "") ? "rootStyle.setProperty('--lean-color-text-primary', '\(theme.color["textPrimary"]!)')" : "",
                (theme.color["textSecondary"] != "") ? "rootStyle.setProperty('--lean-color-text-secondary', '\(theme.color["textSecondary"]!)')" : "",
                (theme.color["textInteractive"] != "") ? "rootStyle.setProperty('--lean-color-text-interactive', '\(theme.color["textInteractive"]!)')" : "",
                
                (theme.fontFamily != "") ? "rootStyle.setProperty('--lean-font-family', '\(theme.fontFamily)')" : "",
                
                (theme.fontWeight["light"] != "") ? "rootStyle.setProperty('--lean-font-weight-light', '\(theme.fontWeight["light"]!)')" : "",
                (theme.fontWeight["regular"] != "") ? "rootStyle.setProperty('--lean-font-weight-regular', '\(theme.fontWeight["regular"]!)')" : "",
                (theme.fontWeight["medium"] != "") ? "rootStyle.setProperty('--lean-font-weight-medium', '\(theme.fontWeight["medium"]!)')" : "",
                (theme.fontWeight["semibold"] != "") ? "rootStyle.setProperty('--lean-font-weight-semibold', '\(theme.fontWeight["semibold"]!)')" : "",
                (theme.fontWeight["bold"] != "") ? "rootStyle.setProperty('--lean-font-weight-bold', '\(theme.fontWeight["bold"]!)')" : "",
            ]
            let js = """
            const rootStyle = document.documentElement.style;
            
            \(commands.filter({ (value:String) -> Bool in
                return value != ""
            }).joined(separator: "; ")
            )
            """
            self.webView.evaluateJavaScript(js)
        }

    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.messageHandler(String(describing: message.body))
    }
    
    func close(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
