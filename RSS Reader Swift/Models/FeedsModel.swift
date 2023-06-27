import UIKit

protocol FeedsModelDelegate {
    func inValidURL()
}

class FeedsModel: NSObject, XMLParserDelegate {
    var delegate:FeedsModelDelegate?
    var xmlURL : URL
    var element : String = ""
    var feedURL : String = ""
    var feedTitle : String = ""
    var feedDescription : String = ""
    var item : NSMutableDictionary = [:]
    var feeds : NSMutableArray
    var articles : NSMutableArray
    
    init(url:String) {
        var tempURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        tempURL = tempURL?.replacingOccurrences(of: "http:", with: "https:")
        xmlURL = URL(string: tempURL!)!
        feeds = NSMutableArray()
        articles = NSMutableArray()
        super.init()
    }
    
    @available(iOS 13.0.0, *)
    @objc func fetchData() async  {
        do {
            let (data, _) = try await URLSession.shared.data(from: xmlURL)
            let xmlParser = XMLParser(data: data)
            xmlParser.shouldResolveExternalEntities = false;
            xmlParser.delegate = self
            if (!(xmlParser.parse())) {
                delegate?.inValidURL()
            }
        } catch {
            delegate?.inValidURL()
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        element = elementName;
        if (elementName == "item") {
            feedURL = String()
            feedTitle = String()
            feedDescription = String()
            item = NSMutableDictionary()
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if (element == "title") {
            feedTitle.append(string)
        } else if (element == "description") {
            feedDescription.append(string)
        } else if (element == "link") {
            feedURL.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName == "item") {
            var trimmedURL = feedURL.replacingOccurrences(of: "\n", with: "")
            trimmedURL = trimmedURL.trimmingCharacters(in: NSCharacterSet.whitespaces)
            
            item.setObject(trimmedURL, forKey: "link" as NSCopying)
            item.setObject(feedTitle, forKey: "title" as NSCopying )
            item.setObject(feedDescription, forKey: "description" as NSCopying )
            feeds.add(item)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {

        
        var imageData : Data
        do {
            
            for feed in feeds {
                var imageLink = "https://picsum.photos/300/200";
                imageLink = imageLink.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
                imageData = try Data(contentsOf: URL(string: imageLink)!)
                guard let selectedArticle  = feed as? NSDictionary else {
                    print(feed)
                    return
                }
                let article = Article(feedTitle: selectedArticle["title"] as! String,
                                      feedDescription: selectedArticle["description"] as! String,
                                      feedThumbnail: imageData,
                                      feedURL: selectedArticle["link"] as! String)
                articles.add(article)
            }
        } catch {
            print(error)
        }
    }
}
