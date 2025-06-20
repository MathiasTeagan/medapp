import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/journal.dart';

class RssService {
  static const String _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';

  static Future<List<Article>> fetchArticlesFromRss(String rssUrl) async {
    try {
      final response = await http.get(
        Uri.parse(rssUrl),
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        },
      );

      if (response.statusCode == 200) {
        return _parseRssXml(response.body);
      } else {
        throw Exception('RSS feed yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('RSS feed yüklenirken hata oluştu: $e');
    }
  }

  static List<Article> _parseRssXml(String xmlString) {
    try {
      final document = XmlDocument.parse(xmlString);
      final items = document.findAllElements('item');

      return items.map((item) {
        final title = item.findElements('title').firstOrNull?.text ?? '';
        final description =
            item.findElements('description').firstOrNull?.text ?? '';
        final link = item.findElements('link').firstOrNull?.text ?? '';
        final pubDate = item.findElements('pubDate').firstOrNull?.text;
        final author = item.findElements('author').firstOrNull?.text ?? '';

        return Article(
          title: title,
          description: description,
          link: link,
          pubDate: pubDate != null ? DateTime.tryParse(pubDate) : null,
          author: author,
        );
      }).toList();
    } catch (e) {
      throw Exception('RSS XML parse edilemedi: $e');
    }
  }

  // Örnek dergiler - gerçek uygulamada bu veriler API'den gelecek
  static List<Journal> getJournalsForBranch(String branch) {
    final journals = {
      'Üroloji': [
        Journal(
          name: 'Urology',
          rssUrl: 'https://www.goldjournal.net/current.rss',
          branch: 'Üroloji',
          description:
              'The Gold Journal - Official Journal of the American Urological Association',
        ),
        Journal(
          name: 'Nature Reviews Urology',
          rssUrl: 'https://www.nature.com/nrurol.rss',
          branch: 'Üroloji',
          description:
              'Nature Reviews Urology - Peer-reviewed journal for urologists and affiliated health-care professionals',
        ),
        Journal(
          name: 'European Urology',
          rssUrl: 'https://www.europeanurology.com/rss/current.xml',
          branch: 'Üroloji',
          description:
              'European Urology - Official journal of the European Association of Urology',
        ),
        Journal(
          name: 'The Journal of Urology',
          rssUrl: 'https://www.auajournals.org/rss/ju_current.xml',
          branch: 'Üroloji',
          description:
              'The Journal of Urology - Official journal of the American Urological Association',
        ),
        Journal(
          name: 'Neurourology and Urodynamics',
          rssUrl: 'https://onlinelibrary.wiley.com/feed/15206777/most-recent',
          branch: 'Üroloji',
          description:
              'Neurourology and Urodynamics - Wiley journal focusing on functional urology and neurourology',
        ),
      ],
      'Kardiyoloji': [
        Journal(
          name: 'Journal of the American College of Cardiology',
          rssUrl: 'https://www.jacc.org/rss/current.xml',
          branch: 'Kardiyoloji',
          description: 'JACC - Leading cardiovascular journal',
        ),
      ],
      'Nöroloji': [
        Journal(
          name: 'Neurology',
          rssUrl: 'https://n.neurology.org/rss/current.xml',
          branch: 'Nöroloji',
          description: 'Official journal of the American Academy of Neurology',
        ),
      ],
    };

    return journals[branch] ?? [];
  }
}
