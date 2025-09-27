import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({
    super.key,
    required this.coffeeId,
    required this.coffeeName,
  });

  final int coffeeId;
  final String coffeeName;

  Future<Map<String, dynamic>?> _fetchRecipe() async {
    final firestore = FirebaseFirestore.instance;
    final docId = coffeeId.toString();
    final coffeeDoc = await firestore.collection('coffees').doc(docId).get();
    if (coffeeDoc.exists) {
      final data = coffeeDoc.data() as Map<String, dynamic>;
      if (data.containsKey('recipe')) {
        final recipeString = data['recipe'] as String;
        return _parseRecipeString(recipeString);
      }
    }
    return null;
  }

  Map<String, dynamic> _parseRecipeString(String recipeString) {
    final lines = recipeString
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    final List<String> ingredients = [];
    final List<String> steps = [];
    final List<String> tips = [];

    bool inIngredients = false;
    bool inInstructions = false;

    for (String line in lines) {
      line = line.trim();

      if (line.toLowerCase().contains('ingredients')) {
        inIngredients = true;
        inInstructions = false;
        continue;
      }

      if (line.toLowerCase().contains('instructions')) {
        inIngredients = false;
        inInstructions = true;
        continue;
      }

      if (inIngredients && line.isNotEmpty) {
        // Remove bullet points, numbers, or other formatting
        final cleanLine = line.replaceAll(RegExp(r'^[\d\-•\s]+'), '').trim();
        if (cleanLine.isNotEmpty) {
          ingredients.add(cleanLine);
        }
      } else if (inInstructions && line.isNotEmpty) {
        // Check if this is a tip (contains "tip" or "☕")
        if (line.toLowerCase().contains('tip') || line.contains('☕')) {
          final cleanLine = line.replaceAll(RegExp(r'^[\d\-•\s]+'), '').trim();
          if (cleanLine.isNotEmpty) {
            tips.add(cleanLine);
          }
        } else {
          // Regular step
          final cleanLine = line.replaceAll(RegExp(r'^[\d\-•\s]+'), '').trim();
          if (cleanLine.isNotEmpty) {
            steps.add(cleanLine);
          }
        }
      }
    }

    return {'ingredients': ingredients, 'steps': steps, 'tips': tips};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$coffeeName Recipe',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF8B4513),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchRecipe(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B4513)),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                'No recipe found',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          final data = snapshot.data!;
          final List<dynamic> steps = (data['steps'] ?? []) as List<dynamic>;
          final List<dynamic> ingredients =
              (data['ingredients'] ?? []) as List<dynamic>;
          final List<dynamic> tips = (data['tips'] ?? []) as List<dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (ingredients.isNotEmpty) ...[
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B4513),
                  ),
                ),
                const SizedBox(height: 8),
                ...ingredients.map(
                  (e) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.check, color: Color(0xFF8B4513)),
                    title: Text('$e'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'Steps',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),
              const SizedBox(height: 8),
              if (steps.isEmpty)
                const Text(
                  'No steps provided',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ...List.generate(steps.length, (i) {
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF8B4513),
                        foregroundColor: Colors.white,
                        child: Text('${i + 1}'),
                      ),
                      title: Text('${steps[i]}'),
                    ),
                  );
                }),
              if (tips.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Tips',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B4513),
                  ),
                ),
                const SizedBox(height: 8),
                ...tips.map(
                  (tip) => Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Color(0xFF8B4513),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF8B4513),
                      ),
                      title: Text('$tip'),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
