class Journal {
  final String name;
  final String rssUrl;
  final String branch;
  final String? description;
  final String? imageUrl;

  Journal({
    required this.name,
    required this.rssUrl,
    required this.branch,
    this.description,
    this.imageUrl,
  });
}

class Article {
  final String title;
  final String? description;
  final String? link;
  final DateTime? pubDate;
  final String? author;
  final String? journalName;
  final String? doi;

  Article({
    required this.title,
    this.description,
    this.link,
    this.pubDate,
    this.author,
    this.journalName,
    this.doi,
  });

  factory Article.fromRss(Map<String, dynamic> rssItem) {
    return Article(
      title: rssItem['title'] ?? '',
      description: rssItem['description'] ?? rssItem['summary'] ?? '',
      link: rssItem['link'] ?? '',
      pubDate: rssItem['pubDate'] != null
          ? DateTime.tryParse(rssItem['pubDate'])
          : null,
      author: rssItem['author'] ?? '',
      journalName: rssItem['journal'] ?? '',
      doi: rssItem['doi'] ?? '',
    );
  }
}
