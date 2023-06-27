import UIKit
import WebKit

class WebPageVC: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var articleView : WKWebView!
    var articleURL : String
    var activityIndicator : UIActivityIndicatorView!
    
    init(url: String) {
        articleURL = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webConfiguration = WKWebViewConfiguration()
        articleView = WKWebView(frame: .zero, configuration: webConfiguration)
        articleView.uiDelegate = self
        articleView.navigationDelegate = self
        articleView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(articleView)
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center;
        self.view.addSubview(activityIndicator)
        
        applyConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let myURL = URL(string:articleURL)
        let myRequest = URLRequest(url: myURL!)
        articleView.load(myRequest)
    }

    func applyConstraints() {
        var constraints = [NSLayoutConstraint]()
        constraints.append(articleView.topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(articleView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(articleView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        constraints.append(articleView.bottomAnchor.constraint(equalTo: view.bottomAnchor))

        NSLayoutConstraint.activate(constraints)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
}
