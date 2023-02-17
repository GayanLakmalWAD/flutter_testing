import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterr_testing/article.dart';
import 'package:flutterr_testing/news_change_notifier.dart';
import 'package:flutterr_testing/news_page.dart';
import 'package:flutterr_testing/news_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

//Widget testing
/* Widget testing is unique to Flutter, where you can test each and every individual widget of your choice.
This step tests the screens (HomePage and FavoritesPage) individually. */

class MockNewsService extends Mock implements NewsService {}

void main() {
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
  });

  Widget createWidgetUnderTests(){
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: const NewsPage(),
      ),
    );
  }

  final articlesFromService = [
    Article(title: "title 1", content: "content 1"),
    Article(title: "title 2", content: "content 2"),
    Article(title: "title 3", content: "content 3"),
  ];

  void arrangeNewsServiceReturnsArticles() {
    when(() => mockNewsService.getArticles()).thenAnswer(
          (invocation) async => articlesFromService,
    );
  }

  void arrangeNewsServiceReturnsArticlesAfterTwoSecondsWait() {
    when(() => mockNewsService.getArticles()).thenAnswer(
          (invocation) async {
           await Future.delayed(const Duration(seconds: 2));
           return articlesFromService;
          }
    );
  }

  //static part - title
  testWidgets("title is displayed", (WidgetTester tester) async{
    arrangeNewsServiceReturnsArticles();
    await tester.pumpWidget(createWidgetUnderTests());
    expect(find.text("News"), findsOneWidget);
  });

  //loading
  testWidgets(
      "loading indicator is displayed while waiting for articles", (WidgetTester tester) async{
    arrangeNewsServiceReturnsArticlesAfterTwoSecondsWait();

    await tester.pumpWidget(createWidgetUnderTests());
    await tester.pump(const Duration(milliseconds: 500)); //forces to rebuild widget

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    //if you have more than circulaProgressIndicators use find.byKey (make sure to add the key in the progress)
    //expect(find.byKey("progress-key1"), findsOneWidget);
    await tester.pumpAndSettle();
  });

  //loading
  testWidgets(
      "articles are displayed", (WidgetTester tester) async{
    arrangeNewsServiceReturnsArticles();

    await tester.pumpWidget(createWidgetUnderTests());
    await tester.pump();

    for(final article in articlesFromService){
      expect(find.text(article.title), findsOneWidget);
      expect(find.text(article.content), findsOneWidget);
    }
  });
}
