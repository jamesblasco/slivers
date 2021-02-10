import 'package:flutter/material.dart';
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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: CustomScrollView(
        slivers: [
          SliverContainer(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.green),
            sliver: DecoratedSliver(
              sliver: SliverGroup(
                slivers: [
                  for (int i in List.generate(100, (i) => i))
                    SliverToBoxAdapter(
                      child: Container(
                        color: Colors.blue,
                        width: double.infinity,
                        child: ListTile(title: Text('$i')),
                      ),
                    )
                ],
              ),
              decoration: BoxDecoration(color: Colors.blue),
            ),
          ),
          for (int j in List.generate(10, (i) => i))
            SliverGroup(
              slivers: [
                for (int i in List.generate(2, (i) => i))
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      child: ListTile(title: Text('$i')),
                    ),
                  )
              ],
            )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
