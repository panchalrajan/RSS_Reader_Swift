import UIKit

public class Article: NSObject {
    public var feedTitle : String
    public var feedDescription : String
    public var feedThumbnail : Data
    public var feedURL : String
    public var readStatus : String
    public var bookmarked : String
    
    init(feedTitle:String, feedDescription:String, feedThumbnail:Data, feedURL:String ) {
        self.feedTitle = feedTitle;
        self.feedDescription = feedDescription;
        self.feedThumbnail = feedThumbnail;
        self.feedURL = feedURL;
        self.readStatus = "NO"
        self.bookmarked = "NO";
        super.init()
    }
}
