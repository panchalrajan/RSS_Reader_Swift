import UIKit

class FeedsTableViewCell: UITableViewCell {

    private var imageHolder : UIImageView = {
        let myImageView = UIImageView()
        myImageView.contentMode = .scaleAspectFit;
        myImageView.translatesAutoresizingMaskIntoConstraints = false
        return myImageView
    }()
    
    private var feedTitle : UILabel = {
        let myLabel = UILabel()
        myLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 18)
        myLabel.sizeToFit()
        myLabel.numberOfLines = 2;
        myLabel.translatesAutoresizingMaskIntoConstraints = false
        return myLabel
    }()
    
    private var feedDescription : UILabel = {
        let myLabel = UILabel()
        myLabel.sizeToFit()
        myLabel.numberOfLines = 3;
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
        [imageHolder, feedTitle, feedDescription].forEach(self.contentView.addSubview(_:))
//        self.contentView.addSubview(imageHolder)
//        self.contentView.addSubview(feedTitle)
//        self.contentView.addSubview(feedDescription)
//
        NSLayoutConstraint.activate([
            imageHolder.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            imageHolder.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            imageHolder.trailingAnchor.constraint(equalTo: self.contentView.centerXAnchor, constant: -50),
            imageHolder.heightAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.widthAnchor, multiplier: 0.5),
            
            feedTitle.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
            feedTitle.leadingAnchor.constraint(equalTo: imageHolder.trailingAnchor, constant: 15),
            feedTitle.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),

            feedDescription.topAnchor.constraint(equalTo: feedTitle.bottomAnchor),
            feedDescription.leadingAnchor.constraint(equalTo: imageHolder.trailingAnchor, constant: 15),
            feedDescription.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
            feedDescription.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    func configure(article:Article) {
        feedTitle.text = article.feedTitle
        feedDescription.text = article.feedDescription
        imageHolder.image = UIImage(data: article.feedThumbnail)
    }
}
