import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterr_testing/article.dart';
import 'package:flutterr_testing/article_page.dart';
import 'package:flutterr_testing/news_change_notifier.dart';
import 'package:flutterr_testing/news_page.dart';
import 'package:flutterr_testing/news_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

//integration testing

class MockNewsService extends Mock implements NewsService {}

void main() {
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
  });

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

  Widget createWidgetUnderTests(){
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: const NewsPage(),
      ),
    );
  }

  //static part - title
  testWidgets("""Tapping on the first article excerpt opens the article page 
  where the full article content is displayed""", (WidgetTester tester) async{
    arrangeNewsServiceReturnsArticles();

    await tester.pumpWidget(createWidgetUnderTests());

    await tester.pump();

    await tester.tap(find.text('content 1'));

    await tester.pumpAndSettle();

    expect(find.byType(NewsPage), findsNothing);
    expect(find.byType(ArticlePage), findsOneWidget);

    expect(find.text('title 1'), findsOneWidget);
    expect(find.text('content 1'), findsOneWidget);
  });

}
