import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int rowCount = 20;
  static const int columnCount = 20;
  final List<Point<int>> snake = [const Point(10, 10)];
  Point<int> food = const Point(5, 5);
  String direction = 'right';
  bool isGameOver = false;

  // Timer for game loop
  late Timer _timer;
  int _gameSpeed = 300; // Initial speed (in milliseconds)

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  // Start the game loop
  void _startGame() {
    _timer = Timer.periodic(Duration(milliseconds: _gameSpeed), _gameLoop);
  }

  // The main game loop function
  void _gameLoop(Timer timer) {
    if (isGameOver) {
      return;
    }

    setState(() {
      _moveSnake();
      _checkCollisions();
      _checkFood();
    });
  }

  // Move the snake based on direction
  void _moveSnake() {
    Point<int> newHead;
    switch (direction) {
      case 'up':
        newHead = Point(snake.first.x, snake.first.y - 1);
        break;
      case 'down':
        newHead = Point(snake.first.x, snake.first.y + 1);
        break;
      case 'left':
        newHead = Point(snake.first.x - 1, snake.first.y);
        break;
      case 'right':
        newHead = Point(snake.first.x + 1, snake.first.y);
        break;
      default:
        return;
    }

    // Add the new head to the snake
    snake.insert(0, newHead);

    // Remove the tail if the snake hasn't eaten food
    if (newHead != food) {
      snake.removeLast();
    }
  }

  // Check if the snake collides with itself or the wall
  void _checkCollisions() {
    Point<int> head = snake.first;

    // Check if snake hits the wall
    if (head.x < 0 ||
        head.x >= columnCount ||
        head.y < 0 ||
        head.y >= rowCount) {
      _endGame();
    }

    // Check if snake collides with itself
    if (snake.skip(1).contains(head)) {
      _endGame();
    }
  }

  // Check if snake eats food
  void _checkFood() {
    if (snake.first == food) {
      _spawnFood();
      _increaseSpeed(); // Increase speed after eating food
    }
  }

  // Spawn food at a random location
  void _spawnFood() {
    Random rand = Random();
    food = Point(rand.nextInt(columnCount), rand.nextInt(rowCount));
  }

  // Increase speed after each food consumption
  void _increaseSpeed() {
    if (_gameSpeed > 100) {
      _gameSpeed -= 20; // Decrease speed (faster game)
      _timer.cancel(); // Cancel the previous timer
      _startGame(); // Restart the game with updated speed
    }
  }

  // End the game
  void _endGame() {
    setState(() {
      isGameOver = true;
    });
    _timer.cancel();
  }

  // Handle arrow key presses for controlling the snake
  void _onKeyPressed(RawKeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowUp && direction != 'down') {
      direction = 'up';
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
        direction != 'up') {
      direction = 'down';
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
        direction != 'right') {
      direction = 'left';
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
        direction != 'left') {
      direction = 'right';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnCount,
                  crossAxisSpacing: 1.0,
                  mainAxisSpacing: 1.0,
                ),
                itemCount: rowCount * columnCount,
                itemBuilder: (context, index) {
                  int x = index % columnCount;
                  int y = index ~/ columnCount;

                  bool isSnake = snake.contains(Point(x, y));
                  bool isFood = food == Point(x, y);

                  return Container(
                    color: isSnake
                        ? Colors.green
                        : isFood
                            ? Colors.red
                            : Colors.white,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (isGameOver)
            Column(
              children: [
                const Text(
                  'Game Over',
                  style: TextStyle(fontSize: 24, color: Colors.red),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {
                      snake.clear();
                      snake.add(const Point(10, 10));
                      food = const Point(5, 5);
                      isGameOver = false;
                      _gameSpeed = 300; // Reset speed to initial value
                      _startGame();
                    });
                  },
                ),
              ],
            )
          else
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: () {
                        if (direction != 'down') {
                          setState(() {
                            direction = 'up';
                          });
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        if (direction != 'right') {
                          setState(() {
                            direction = 'left';
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 40),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        if (direction != 'left') {
                          setState(() {
                            direction = 'right';
                          });
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () {
                        if (direction != 'up') {
                          setState(() {
                            direction = 'down';
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
