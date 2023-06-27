import UIKit
import CoreData

class AcceptURLVC: UIViewController {
    
    private var acceptURLView = AcceptURLView()
    private var acceptURLModel = AcceptURLModel()
    private var urlData = [URLs]()

    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setModel()
        self.setView()
    }
    
    private func setModel() {
        urlData = self.loadCoreData()
    }
    
    private func setView() {
        acceptURLView.delegate = self;
        acceptURLView.urlTableView.delegate = self;
        acceptURLView.urlTableView.dataSource = self;
        acceptURLView.urlTableView.rowHeight = 50;
        acceptURLView.urlTableView.register(AcceptURLTableViewCell.self, forCellReuseIdentifier: "URLCellIdentifier")
        acceptURLView.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(acceptURLView)

        NSLayoutConstraint.activate([
            acceptURLView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            acceptURLView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            acceptURLView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            acceptURLView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])

    }
    
    private func saveToCoreData(_ urlString: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let userEntity = URLs(context:context)
        userEntity.url = urlString
        do {
            try context.save()
        } catch {
            print("Error Adding the URL to Core Data: \(error)")
        }
        urlData = self.loadCoreData()
        acceptURLView.urlTableView.reloadData()
    }
    
    private func loadCoreData() -> [URLs] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<URLs> = URLs.fetchRequest()
        do {
            urlData = try context.fetch(fetchRequest)
        } catch {
            print("Error fetching URLs from Core Data: \(error)")
        }
        if urlData.isEmpty {
            for urlString in acceptURLModel.listOfURL {
                let urlObject = URLs(context: context)
                urlObject.url = urlString
                urlData.append(urlObject)
            }
            do {
                try context.save()
                print("URLs added to Core Data.")
            } catch {
                print("Error saving URLs to Core Data: \(error)")
            }
        }
        return urlData
    }
    
    func deleteFromCoreData(_ url: URLs) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        context.delete(url)
        do {
            try context.save()
        } catch {
            print("Error deleting URL from Core Data: \(error)")
        }
    }
    
    private func showAlert(title:String, message : String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension AcceptURLVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urlData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rssURL = urlData[indexPath.row].url else {
            showAlert(title: "Error", message: "Error Passing URL from Core Data")
            return
        }
        let feedsVC = FeedsVC(url: rssURL)
        let navigationController = UINavigationController(rootViewController: feedsVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .crossDissolve;
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension AcceptURLVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = acceptURLView.urlTableView.dequeueReusableCell(withIdentifier: "URLCellIdentifier", for: indexPath) as! AcceptURLTableViewCell
        guard let cellText = urlData[indexPath.row].url else {
            showAlert(title: "Error", message: "Error Passing URL from Core Data")
            return UITableViewCell()
        }
        cell.configure(urlString: cellText)
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [self] action, sourceView, completionHandler in
            let url = urlData[indexPath.row]
            deleteFromCoreData(url)
            urlData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe=false;
        return config
    }
}

extension AcceptURLVC: AcceptURLViewDelegate {
    func addURLToTable() {
        guard let url = acceptURLView.enterURLTextField.text,
                !url.isEmpty else {
            showAlert(title: "Empty Field", message: "Text field is Empty")
            return
        }
        if (acceptURLModel.listOfURL.contains(url)) {
            showAlert(title: "Duplicate URL", message: "This URL Already Subscribed")
            acceptURLView.enterURLTextField.text = "";
            return
        }
        self.saveToCoreData(url)
        acceptURLView.urlTableView.reloadData()
        acceptURLView.enterURLTextField.text = "";
    }
}
