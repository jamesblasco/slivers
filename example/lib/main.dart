import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:slivers/slivers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: Scaffold(
        body: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
Text()
ScrollView(
  slivers: [
    SliverAppBar(title: Text('Hello')),
    Container(color: Colors.grey[400], height: 100),
    Gap(20),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(
          title: Text('Item $index'),
        ),
        childCount: 4,
      ),
    ),
    Divider(),
    Align(
      alignment: Alignment.center,
      child: Text('This is a text'),
    ),
    Divider(),
    SliverContainer(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => ListTile(
            title: Text('Item ${index + 4}'),
          ),
          childCount: 4,
        ),
      ),
    ),
  ],
);

    //   SliverList(
    //       delegate: SliverChildBuilderDelegate(
    //     (context, index) => ListTile(title: Text('Item ${index + 8}')),
    //     childCount: 4,
    //   )),
    // DecoratedSliver(
    //   sliver: SliverGroup(
    //     slivers: [
    //       for (int i in List.generate(100, (i) => i))
    //         SliverToBoxAdapter(
    //           child: Container(
    //             color: Colors.blue,
    //             width: double.infinity,
    //             child: ListTile(title: Text('$i')),
    //           ),
    //         )
    //     ],
    //   ),
    //   decoration: BoxDecoration(color: Colors.blue),
    // ),
    // ),
    //     for (int j in List.generate(10, (i) => i))
    //       SliverGroup(
    //         slivers: [
    //           for (int i in List.generate(2, (i) => i))
    //             SliverToBoxAdapter(
    //               child: Container(
    //                 width: double.infinity,
    //                 child: ListTile(title: Text('$i')),
    //               ),
    //             )
    //         ],
    //       )
    //   ],
    // );
  }
}
