import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/global_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GlobalState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CounterScreen(),
    );
  }
}

class CounterScreen extends StatefulWidget {
  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<GlobalState>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter List')),
      body: AnimatedList(
        key: _listKey,
        initialItemCount: globalState.counters.length,
        itemBuilder: (context, index, animation) {
          final counter = globalState.counters[index];
          return SlideTransition(
            position: animation.drive(
              Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: Card(
              color: counter.color,
              child: ListTile(
                title: Text(counter.label),
                subtitle: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Text(
                    'Value: ${counter.value}',
                    key: ValueKey(counter.value),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        globalState.decrementCounter(index);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        globalState.incrementCounter(index);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _listKey.currentState!.removeItem(
                          index,
                          (context, animation) => SlideTransition(
                            position: animation.drive(
                              Tween<Offset>(begin: Offset(0, 0), end: Offset(1, 0)),
                            ),
                            child: SizedBox(),
                          ),
                        );
                        globalState.removeCounter(index);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          globalState.addCounter();
          _listKey.currentState!.insertItem(globalState.counters.length - 1);
        },
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: Icon(Icons.add, key: ValueKey(globalState.counters.length)),
        ),
      ),
    );
  }
}
