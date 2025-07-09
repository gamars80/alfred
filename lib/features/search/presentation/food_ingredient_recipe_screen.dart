import 'package:flutter/material.dart';
import '../../home/model/popular_recipe.dart';
import '../data/search_repository.dart';
import 'widget/recipe_sort_dropdown.dart';
import 'widget/recipe_card.dart';

class FoodIngredientRecipeScreen extends StatefulWidget {
  final String ingredient;

  const FoodIngredientRecipeScreen({
    super.key,
    required this.ingredient,
  });

  @override
  State<FoodIngredientRecipeScreen> createState() => _FoodIngredientRecipeScreenState();
}

class _FoodIngredientRecipeScreenState extends State<FoodIngredientRecipeScreen> {
  final _repo = SearchRepository();
  final _scrollController = ScrollController();
  int? _totalCount;

  final List<PopularRecipe> _recipes = [];
  String? _cursor;
  bool _isLoading = false;
  bool _hasMore = true;
  String _sortBy = 'createdAt';
  String _sortDir = 'desc';
  String? _searchKeyword;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchRecipes();
    }
  }

  Future<void> _fetchRecipes({bool refresh = false}) async {
    setState(() => _isLoading = true);

    if (refresh) {
      _recipes.clear();
      _cursor = null;
      _hasMore = true;
      _totalCount = null;
    }

    try {
      final result = await _repo.fetchAiRecipes(
        keyword: widget.ingredient,
        cursor: _cursor,
        sortBy: _sortBy,
        sortDir: _sortDir,
        limit: 20,
        searchKeyword: _searchKeyword,
      );

      setState(() {
        if (refresh) {
          _recipes.clear();
        }
        _recipes.addAll(result.items);
        _cursor = result.nextCursor;
        _hasMore = result.nextCursor != null;
        _totalCount = result.totalCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('레시피를 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  void _onSortChanged(String sortBy, String sortDir) {
    setState(() {
      _sortBy = sortBy;
      _sortDir = sortDir;
    });

    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    _fetchRecipes(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.ingredient,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Text(
              '관련 레시피',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          RecipeSortDropdown(onChanged: _onSortChanged),
          if (_totalCount != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '$_totalCount개의 레시피',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _recipes.isEmpty
                ? const Center(
                    child: Text(
                      '검색 결과가 없습니다.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      for (int i = 0; i < _recipes.length; i += 10) ...[
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.60,
                              mainAxisExtent: 240,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final recipeIndex = i + index;
                                if (recipeIndex >= _recipes.length || recipeIndex >= i + 10) return null;
                                return RecipeCard(recipe: _recipes[recipeIndex]);
                              },
                              childCount: (_recipes.length - i) >= 10 ? 10 : (_recipes.length - i),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
} 