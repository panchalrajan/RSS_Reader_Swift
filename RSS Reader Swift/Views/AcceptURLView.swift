import UIKit

protocol AcceptURLViewDelegate {
    func addURLToTable()
}

class AcceptURLView: UIView {
    
    var delegate:AcceptURLViewDelegate?
    
    private let enterURLLabel : UILabel = {
        let myLabel = UILabel()
        myLabel.text = "Please Enter the URL Below"
        myLabel.font = myLabel.font.withSize(24)
        myLabel.textAlignment = .center
        myLabel.translatesAutoresizingMaskIntoConstraints = false
        return myLabel
    }()
    
    let enterURLTextField : UITextField = {
        let myTextField = UITextField()
        myTextField.backgroundColor = .systemGray4
        myTextField.layer.cornerRadius = 15
        myTextField.textAlignment = .center
        myTextField.font = myTextField.font?.withSize(24)
        myTextField.translatesAutoresizingMaskIntoConstraints = false
        return myTextField
    }()
    
    private let fetchDataButton : UIButton = {
        let myBtn = UIButton()
        myBtn.setTitle("Add", for: .normal)
        myBtn.backgroundColor = .systemBlue
        myBtn.layer.cornerRadius = 15;
        myBtn.titleLabel?.font = .systemFont(ofSize: 20)
        myBtn.translatesAutoresizingMaskIntoConstraints = false;
        return myBtn
    }()

    private let recentlyAddedLabel : UILabel = {
        let myLabel = UILabel()
        myLabel.text = "Recently Added Feeds"
        myLabel.font = myLabel.font.withSize(24)
        myLabel.textAlignment = .center
        myLabel.translatesAutoresizingMaskIntoConstraints = false
        return myLabel
    }()
    
    let urlTableView : UITableView = {
        let myTableView = UITableView()
        myTableView.translatesAutoresizingMaskIntoConstraints = false;
        return myTableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(enterURLLabel)
        self.addSubview(enterURLTextField)
        self.addSubview(fetchDataButton)
        self.addSubview(recentlyAddedLabel)
        self.addSubview(urlTableView)
        
        NSLayoutConstraint.activate([
            enterURLLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            enterURLLabel.topAnchor.constraint(equalTo: self.topAnchor, constant:100),

            enterURLTextField.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            enterURLTextField.topAnchor.constraint(equalTo: enterURLLabel.bottomAnchor, constant:30),
            enterURLTextField.widthAnchor.constraint(equalToConstant: 300),
            enterURLTextField.heightAnchor.constraint(equalToConstant: 50),

            fetchDataButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            fetchDataButton.topAnchor.constraint(equalTo: enterURLTextField.bottomAnchor, constant:30),
            fetchDataButton.widthAnchor.constraint(equalToConstant: 150),
            fetchDataButton.heightAnchor.constraint(equalToConstant: 50),

            recentlyAddedLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            recentlyAddedLabel.topAnchor.constraint(equalTo: fetchDataButton.bottomAnchor, constant:50),

            urlTableView.topAnchor.constraint(equalTo: recentlyAddedLabel.bottomAnchor, constant:30),
            urlTableView.widthAnchor.constraint(equalTo: self.widthAnchor),
            urlTableView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ])
        fetchDataButton.addTarget(self,action: #selector(addButtonClicked),for: .touchUpInside);
    }
    
    @objc func addButtonClicked() {
        delegate?.addURLToTable()
    }
}
