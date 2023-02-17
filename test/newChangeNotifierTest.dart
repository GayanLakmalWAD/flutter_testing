import 'package:flutter_test/flutter_test.dart';
import 'package:flutterr_testing/article.dart';
import 'package:flutterr_testing/news_change_notifier.dart';
import 'package:flutterr_testing/news_service.dart';
import 'package:mocktail/mocktail.dart';

//unit testing
/* A unit test verifies that every individual unit of software (often a function) performs its intended task correctly.*/

class MockNewsService extends Mock implements NewsService {}

void main() {
  late NewsChangeNotifier sut; //system under test
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
    sut = NewsChangeNotifier(mockNewsService);
  });

  test("initial values are correct", () {
    expect(sut.articles, []);
    expect(sut.isLoading, false);
  });

  group("getArticles", () {
    final articlesFromService = [
      Article(title: "title 1 ", content: "content 1"),
      Article(title: "title 2 ", content: "content 2"),
      Article(title: "title 3 ", content: "content 3"),
    ];

    void arrangeNewsServiceReturnsArticles() {
      when(() => mockNewsService.getArticles()).thenAnswer(
        (invocation) async => articlesFromService,
      );
    }

    test("get articles using the NewsServices", () async {
      //aaaTest
      //arranging the mocks

      // when(() => mockNewsService.getArticles()).thenAnswer((invocation) async => []);
      arrangeNewsServiceReturnsArticles();

      //action/ act
      await sut.getArticles();
      //assert
      verify(() => mockNewsService.getArticles()).called(1);
    });

    test("""indicates loading of data,
     sets articles to the ones from the service""", () async {
      arrangeNewsServiceReturnsArticles();

      final future =  sut.getArticles();
      expect(sut.isLoading, true);
      await future;
      expect(sut.articles, articlesFromService);
      expect(sut.isLoading, false);
    });
  });

}
