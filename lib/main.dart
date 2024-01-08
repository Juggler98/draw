import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyDrawingApp());
}

class MyDrawingApp extends StatelessWidget {
  const MyDrawingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyDrawingScreen(),
    );
  }
}

class MyDrawingScreen extends StatefulWidget {
  const MyDrawingScreen({super.key});

  @override
  State<MyDrawingScreen> createState() => _MyDrawingScreenState();
}

class _MyDrawingScreenState extends State<MyDrawingScreen> {
  List<String> words = [
    "Elephant",
    "Rainbow",
    "Pizza",
    "Castle",
    "Bicycle",
    "Starfish",
    "Lighthouse",
    "Unicorn",
    "Fireworks",
    "Dragon",
    "Ocean",
    "Moonlight",
    "Butterfly",
    "Cactus",
    "Giraffe",
    "Sunny",
    "Mermaid",
    "Robot",
    "Penguin",
    "Jungle",
    "Frog",
    "Cherry",
    "Guitar",
    "Parrot",
    "Mountains",
    "Bookshelf",
    "Hot Air Balloon",
    "Popcorn",
    "Volcano",
    "Sailboat",
    "Coffee",
    "Puzzle",
    "Tiger",
    "Waffle",
    "Snowman",
    "Palm Tree",
    "Helicopter",
    "Sunflower",
    "Jellyfish",
    "Raindrops",
    "Campfire",
    "Squirrel",
    "Telescope",
    "Sunset",
    "Waterfall",
    "Cheeseburger",
    "Owl",
    "Robot",
    "Cupcake",
    "Raincoat",
    "Tornado",
    "Candle",
    "Rocket",
    "Maple Leaf",
    "Whale",
    "Dolphin",
    "Vampire",
    "Wizard",
    "Flamingo",
    "Lion",
    "Kangaroo",
    "Igloo",
    "Spider",
    "Witch",
    "Pirate",
    "Saturn",
    "Muffin",
    "Snowflake",
    "Umbrella",
    "Rocket",
    "Caterpillar",
    "Dragonfly",
    "Globe",
    "Koala",
    "Donut",
    "Elephant",
    "Penguin",
    "Tiger",
    "Butterfly",
    "Cactus",
    "Fireworks",
    "Jellyfish",
    "Rainbow",
    "Unicorn",
    "Volcano",
    "Castle",
    "Robot",
    "Mermaid",
    "Lighthouse",
    "Bicycle",
    "Sailboat",
    "Dragon",
    "Sunflower",
    "Giraffe",
    "Moonlight",
    "Owl",
    "Squirrel",
    "Tiger",
    "Cupcake",
    "Penguin",
    "Rocket",
    "Snowman",
    "Waterfall",
    "Cheeseburger",
    "Popcorn",
    "Sunset",
    "Whale",
    "Wizard",
    "Flamingo",
    "Pirate",
    "Elephant",
    "Rainbow",
    "Pizza",
    "Castle",
    "Bicycle",
    "Starfish",
    "Lighthouse",
    "Unicorn",
    "Fireworks",
    "Dragon",
  ];

  List<Offset?> points = [];

  DocumentReference<Map<String, dynamic>>? doc;
  String? word;
  bool newGame = true;

  @override
  void initState() {
    initGame();
    super.initState();
  }

  OutlineInputBorder getBorder({double radius = 24}) => OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        borderSide: const BorderSide(color: Colors.grey),
      );

  List<dynamic> pointsFromDb = [];

  void _createGame() async {
    setState(() {
      points.clear();
      newGame = true;
      word = words[Random().nextInt(words.length)].toUpperCase();
    });
  }

  void initGame() async {
    final openDoc = await FirebaseFirestore.instance
        .collection('games')
        .where('open', isEqualTo: true)
        .get();
    if (openDoc.docs.isNotEmpty) {
      setState(() {
        newGame = false;
      });
      final doc = openDoc.docs.first;
      this.doc = doc.reference;

      word = doc.data()['word'];
      word = word?.toUpperCase();

      pointsFromDb = doc.data()['points'] ?? [];
      final list = pointsFromDb.map((e) {
        if (e['x'] != null || e['y'] != null) {
          return Offset(e['x'] as double, e['y'] as double);
        } else {
          return null;
        }
      }).toList();
      points = list;
    } else {
      _createGame();
    }
  }

  final _controller = TextEditingController();

  String guessWord = '';

  final form = GlobalKey<FormState>();

  Future<void> sendGuess() async {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          newGame ? null : () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(newGame ? 'Draw' : 'Guess'),
          actions: [
            if (newGame && points.isEmpty)
              IconButton(
                onPressed: () async {
                  _createGame();
                },
                icon: const Icon(
                  Icons.cached,
                  color: Colors.green,
                ),
                tooltip: 'Generate a new word',
              ),
            if (newGame && points.isNotEmpty)
              IconButton(
                onPressed: () async {
                  final maps = points.map((e) => {'x': e?.dx, 'y': e?.dy});

                  FirebaseFirestore.instance.collection('games').add({
                    'date': FieldValue.serverTimestamp(),
                    'word': word?.toLowerCase(),
                    'points': maps,
                    'open': true,
                  });

                  initGame();
                },
                icon: const Icon(
                  Icons.send,
                  color: Colors.green,
                ),
                tooltip: 'Send painting',
              ),
          ],
        ),
        body: newGame
            ? Column(
                children: [
                  Card(
                    color: Colors.blue[400],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        word?.toUpperCase() ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          if (points.length < 1500) {
                            points.add(details.localPosition);
                          }
                        });
                      },
                      onPanEnd: (details) {
                        points
                            .add(null); // Add a null point to separate strokes
                      },
                      child: CustomPaint(
                        painter: MyPainter(points),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Expanded(
                    child: CustomPaint(
                      painter: MyPainter(points),
                      size: Size.infinite,
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 6),
                      Expanded(
                        child: Form(
                          key: form,
                          child: TextFormField(
                            controller: _controller,
                            textCapitalization: TextCapitalization.characters,
                            cursorColor: Colors.purple,
                            autocorrect: false,
                            minLines: 1,
                            enableSuggestions: false,
                            maxLines: 1,
                            maxLength: word?.length,
                            validator: (value) {
                              value = value?.trim().toUpperCase();
                              if (value != word &&
                                  value?.length == word?.length) {
                                return 'WRONG';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: '',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              alignLabelWithHint: true,
                              fillColor: Colors.purple,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              enabledBorder: getBorder(),
                              disabledBorder: getBorder(),
                              border: getBorder(),
                              focusedBorder: getBorder(radius: 20),
                            ),
                            onChanged: (value) {
                              setState(() {
                                guessWord = value.trim().toUpperCase();
                              });
                              form.currentState?.validate();
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: IconButton(
                          color: Colors.green,
                          icon: const Icon(Icons.send),
                          onPressed: guessWord == word
                              ? () {
                                  final isValid = form.currentState?.validate();
                                  if (isValid == true) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    doc?.update({
                                      'open': false,
                                      'solved': FieldValue.serverTimestamp(),
                                    });
                                    setState(() {
                                      guessWord = '';
                                    });
                                    _controller.clear();

                                    _createGame();
                                  }
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        floatingActionButton: newGame
            ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    points.clear();
                  });
                },
                tooltip: 'Clear painting',
                child: const Icon(Icons.clear),
              )
            : null,
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<Offset?> points;

  MyPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 2.4;

    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        // Draw dots for touch points
        canvas.drawCircle(points[i]!, strokeWidth / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
