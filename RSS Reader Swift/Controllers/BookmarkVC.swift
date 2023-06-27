import UIKit

protocol BookmarkVCDelegate {
    func removeFromBookmark(article:Article)
}

class BookmarkVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var delegate:BookmarkVCDelegate?
    var articles : NSMutableArray
    
    init(articles: NSMutableArray) {
        self.articles = articles
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let bookmarkTableView : UITableView = {
        let myTableView = UITableView()
        myTableView.translatesAutoresizingMaskIntoConstraints = false;
        return myTableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(bookmarkTableView)
        bookmarkTableView.delegate = self
        bookmarkTableView.dataSource = self
        bookmarkTableView.register(FeedsTableViewCell.self, forCellReuseIdentifier: "BookmarkCellIdentifier")

        applyConstraints();
    }
    
    func applyConstraints() {
        var constraints = [NSLayoutConstraint]()
        constraints.append(bookmarkTableView.topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(bookmarkTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(bookmarkTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        constraints.append(bookmarkTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor))

        NSLayoutConstraint.activate(constraints)
    }

    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        if (articles.count != 0) {
            return articles.count
        } else {
            let noDataLabel = UILabel(frame:CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No Bookmark Feed Available"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        }
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = bookmarkTableView.dequeueReusableCell(withIdentifier: "BookmarkCellIdentifier", for: indexPath) as! FeedsTableViewCell
        cell.configure(article: articles[indexPath.row] as! Article)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articles.object(at: indexPath.row) as! Article
        let articleURL = article.feedURL
        
        let webpageVC = WebPageVC(url:articleURL)
        webpageVC.modalPresentationStyle = .fullScreen;
        webpageVC.navigationItem.title = article.feedTitle
        self.navigationController?.pushViewController(webpageVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let article = articles.object(at: indexPath.row) as! Article
        let bookmarkAction = UIContextualAction(style: .normal, title: "Remove to Bookmark") { [self] action, sourceView, completionHandler in
            let bookmarkAlert = UIAlertController(title: "Bookmark",
                                                        message: "Article Removed from Bookmark",
                                                        preferredStyle: .alert)
            bookmarkAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(bookmarkAlert, animated: true, completion: nil)
            self.delegate?.removeFromBookmark(article: article)
            tableView.reloadData()
            completionHandler(true);
        }
        bookmarkAction.image = UIImage(systemName: "bookmark.slash.fill")
        bookmarkAction.backgroundColor = .systemBlue
        
        let config = UISwipeActionsConfiguration(actions: [bookmarkAction])
        config.performsFirstActionWithFullSwipe=false;
        return config
    }

}
