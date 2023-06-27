import UIKit

class AcceptURLModel: NSObject {

    var listOfURL: [String]
    
    override init() {
        self.listOfURL = [
            "http://lorem-rss.herokuapp.com/feed?unit=second",
            "https://abcnews.go.com/abcnews/usheadlines",
            "https://www.thehindu.com/news/national/?service=rss",
            "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml",
            "https://news.un.org/feed/subscribe/en/news/region/asia-pacific/feed/rss.xml"
        ]
        super.init()
    }
}
