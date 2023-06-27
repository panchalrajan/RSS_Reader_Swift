import UIKit

class AcceptURLTableViewCell: UITableViewCell {

    private var urlLabel : UILabel = {
        let myLabel = UILabel()
        myLabel.font = myLabel.font.withSize(24)
        myLabel.translatesAutoresizingMaskIntoConstraints = false
        return myLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.contentView.addSubview(urlLabel)
        NSLayoutConstraint.activate([
            urlLabel.topAnchor.constraint(equalTo: self.topAnchor),
            urlLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            urlLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            urlLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func configure(urlString: String) {
        urlLabel.text = urlString
    }
}
