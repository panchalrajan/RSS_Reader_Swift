import UIKit
import BackgroundTasks

class FeedsVC: UIViewController {
    var rssURL : String
    var activityIndicator : UIActivityIndicatorView!
    var firstLoad: Bool!;
    var feedModel : FeedsModel
    var bookmarkedArticles: NSMutableArray
    private var refreshTimer: Timer?
    var backgroundTask: UIBackgroundTaskIdentifier!


    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshFeedsUsingPullToRefresh), for: .valueChanged)
        return control
    }()

    let feedsTableView : UITableView = {
        let myTableView = UITableView()
        myTableView.translatesAutoresizingMaskIntoConstraints = false;
        return myTableView
    }()
    
    init(url: String) {
        self.rssURL = url
        self.feedModel = FeedsModel(url: rssURL)
        self.bookmarkedArticles = NSMutableArray()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupModel()
        self.setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            activityIndicator.startAnimating()
            await feedModel.fetchData()
            activityIndicator.stopAnimating()
            feedsTableView.reloadData()
        }
        startRefreshTimer()
        firstLoad = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRefreshTimer()
    }
    
    func setupModel() {
        feedModel.delegate = self
        firstLoad = true
    }
    
    func setupView() {
        self.view.addSubview(feedsTableView)
        self.view.backgroundColor = .white
        feedsTableView.delegate = self;
        feedsTableView.dataSource = self;
        feedsTableView.register(FeedsTableViewCell.self, forCellReuseIdentifier: "FeedsCellIdentifier")
        feedsTableView.rowHeight = UITableView.automaticDimension
        feedsTableView.estimatedRowHeight = 300;
        feedsTableView.refreshControl = refreshControl
        self.navigationItem.title = "Feeds"
        let homeButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(dismissView))
        self.navigationItem.leftBarButtonItem = homeButton;
        
        let bookmarkButton = UIBarButtonItem(image: UIImage(systemName: "bookmark"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(showBookmarkVC))
        self.navigationItem.rightBarButtonItem = bookmarkButton;

        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center;
        self.view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            feedsTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            feedsTableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            feedsTableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            feedsTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    
    func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.refreshFeedsUsingTimer()
        }
        RunLoop.current.add(refreshTimer!, forMode: .common)
        UIApplication.shared.setMinimumBackgroundFetchInterval(15)

    }
    
    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    func refreshFeedsUsingTimer() {
        print("Fetching Data at \(Date())")
        Task {
            self.activityIndicator.startAnimating()
            let newFeedModel = FeedsModel(url: self.rssURL)
            newFeedModel.delegate = self
            await newFeedModel.fetchData()
            DispatchQueue.main.async { [weak self] in
                self?.feedModel = newFeedModel
                self?.activityIndicator.stopAnimating()
                self?.feedsTableView.reloadData()
            }
        }
    }
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func showBookmarkVC() {
        let bookmarkVC = BookmarkVC(articles: bookmarkedArticles)
        bookmarkVC.delegate = self;
        bookmarkVC.modalPresentationStyle = .fullScreen;
        bookmarkVC.navigationItem.title = "Bookmarks";
        self.navigationController?.pushViewController(bookmarkVC, animated: true)
    }
    
    @objc func refreshFeedsUsingPullToRefresh() {
        Task {
            let newFeedModel = FeedsModel(url: rssURL)
            newFeedModel.delegate = self
            await newFeedModel.fetchData()
            
            DispatchQueue.main.async { [weak self] in
                self?.feedModel = newFeedModel
                self?.feedsTableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }
    }
}

extension FeedsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feedModel.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = feedsTableView.dequeueReusableCell(withIdentifier: "FeedsCellIdentifier", for: indexPath) as! FeedsTableViewCell
        
        let article = feedModel.articles.object(at: indexPath.row) as! Article
        if (article.readStatus == "YES") {
            cell.backgroundColor = .systemGray5;
        } else {
            cell.backgroundColor = .white;
        }
        
        cell.configure(article: feedModel.articles[indexPath.row] as! Article)
        return cell
    }
}

extension FeedsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = feedModel.articles.object(at: indexPath.row) as! Article
        let articleURL = article.feedURL
        article.readStatus = "YES"
        tableView.reloadData()
        
        let webpageVC = WebPageVC(url:articleURL)
        webpageVC.modalPresentationStyle = .fullScreen;
        webpageVC.navigationItem.title = article.feedTitle
        self.navigationController?.pushViewController(webpageVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let article = feedModel.articles.object(at: indexPath.row) as! Article
        var readAction : UIContextualAction
        if (article.readStatus == "YES") {
            readAction = UIContextualAction(style: .normal, title: "Mark as Unread") { action, sourceView, completionHandler in
                article.readStatus = "NO"
                tableView.reloadData()
                completionHandler(true);
            }
                readAction.image = UIImage(systemName: "rectangle.badge.xmark.fill")
        } else {
            readAction = UIContextualAction(style: .normal, title: "Mark as Read") { action, sourceView, completionHandler in
                article.readStatus = "YES"
                tableView.reloadData()
                completionHandler(true);
            }
                readAction.image = UIImage(systemName: "rectangle.badge.checkmark.fill")
        }
        readAction.backgroundColor = .systemGreen
        var bookmarkAction : UIContextualAction
        if (article.bookmarked == "NO") {
            bookmarkAction = UIContextualAction(style: .normal, title: "Add to Bookmark") { [self] action, sourceView, completionHandler in
                let bookmarkAlert = UIAlertController(title: "Bookmark",
                                                            message: "Article Added from BookMark",
                                                            preferredStyle: .alert)
                bookmarkAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(bookmarkAlert, animated: true, completion: nil)
                article.bookmarked = "YES"
                bookmarkedArticles.add(article)
                completionHandler(true);
            }
            bookmarkAction.image = UIImage(systemName: "bookmark.fill")
        } else {
            bookmarkAction = UIContextualAction(style: .normal, title: "Remove to Bookmark") { [self] action, sourceView, completionHandler in
                let bookmarkAlert = UIAlertController(title: "Bookmark",
                                                            message: "Article Removed from Bookmark",
                                                            preferredStyle: .alert)
                bookmarkAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(bookmarkAlert, animated: true, completion: nil)
                article.bookmarked = "NO"
                bookmarkedArticles.remove(article)
                completionHandler(true);
            }
            bookmarkAction.image = UIImage(systemName: "bookmark.slash.fill")
        }
        
        bookmarkAction.backgroundColor = .systemBlue
        
        let config = UISwipeActionsConfiguration(actions: [readAction, bookmarkAction])
        config.performsFirstActionWithFullSwipe=false;
        return config
    }
}

extension FeedsVC: FeedsModelDelegate {
    func inValidURL() {
        let emptyTextFieldAlert = UIAlertController(title: "Invalid URL",
                                                    message: "Please Sent RSS Link Only",
                                                    preferredStyle: .alert)
        emptyTextFieldAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            self.dismissView()
        }))
        self.present(emptyTextFieldAlert, animated: true, completion: nil)
    }
}

extension FeedsVC: BookmarkVCDelegate {
    func removeFromBookmark(article: Article) {
        let index = feedModel.articles.index(of: article)
        let readArticle = feedModel.articles.object(at: index) as! Article
        readArticle.bookmarked = "NO"
        self.bookmarkedArticles.remove(article)
    }
}
