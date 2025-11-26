import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;

  const MealDetailScreen({Key? key, required this.mealId}) : super(key: key);

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  Meal? meal;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMealDetails();
  }

  Future<void> loadMealDetails() async {
    try {
      final data = await MealService.getMealDetails(widget.mealId);
      setState(() {
        meal = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> openYoutube() async {
    if (meal?.youtube != null) {
      final uri = Uri.parse(meal!.youtube!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (meal == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Рецептот не е пронајден')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                meal!.name,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                ),
              ),
              background: Image.network(
                meal!.thumbnail,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (meal!.category != null)
                        Chip(
                          label: Text(meal!.category!),
                          avatar: const Icon(Icons.category, size: 18),
                        ),
                      const SizedBox(width: 8),
                      if (meal!.area != null)
                        Chip(
                          label: Text(meal!.area!),
                          avatar: const Icon(Icons.public, size: 18),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (meal!.youtube != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: openYoutube,
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('Гледај на YouTube'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'Состојки',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (meal!.ingredients != null)
                    ...meal!.ingredients!.entries.map(
                          (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 20, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              '${entry.key} - ${entry.value}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'Инструкции',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    meal!.instructions ?? 'Нема достапни инструкции',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}