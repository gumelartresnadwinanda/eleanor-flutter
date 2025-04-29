import 'package:eleanor/features/groceries/providers/ingredients_provider.dart';
import 'package:flutter/material.dart';
import 'package:eleanor/core/widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:eleanor/features/groceries/models/ingredient.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eleanor/core/services/permission_service.dart';
import 'package:eleanor/core/services/upload_service.dart';
import 'dart:io';

class GroceriesIngredientsScreen extends StatefulWidget {
  const GroceriesIngredientsScreen({super.key});

  @override
  State<GroceriesIngredientsScreen> createState() =>
      _GroceriesIngredientsScreenState();
}

class _GroceriesIngredientsScreenState
    extends State<GroceriesIngredientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IngredientsProvider>().fetchIngredients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterIngredients(List<dynamic> ingredients) {
    if (_searchQuery.isEmpty) return ingredients;
    return ingredients
        .where(
          (ingredient) => ingredient.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  Future<String?> _pickImage() async {
    try {
      final hasPermission = await PermissionService.requestImagePermission(
        onPermissionDenied: (message) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        },
        onPermissionPermanentlyDenied: (message) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        },
      );
      if (!hasPermission) return null;

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print("Image path: ${image.path}");
        return image.path;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
    return null;
  }

  Future<void> _showIngredientDialog([Ingredient? ingredient]) async {
    final nameController = TextEditingController(text: ingredient?.name ?? '');
    final unitController = TextEditingController(text: ingredient?.unit ?? '');
    final unitPurchaseController = TextEditingController(
      text: ingredient?.unitPurchase ?? '',
    );
    final minimumPurchaseController = TextEditingController(
      text: '${ingredient?.minimumPurchase ?? 1}',
    );
    final comparisonScaleController = TextEditingController(
      text: '${ingredient?.comparisonScale ?? 1}',
    );
    String? imagePath;
    String? imageUrl = ingredient?.imageUrl;
    final uploadService = UploadService();

    final result = await showDialog<Ingredient>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    ingredient == null ? 'Add Ingredient' : 'Edit Ingredient',
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (imageUrl != null || imagePath != null)
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child:
                                    imagePath != null
                                        ? Image.file(
                                          File(imagePath!),
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        )
                                        : CachedNetworkImage(
                                          imageUrl: imageUrl ?? '',
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                          placeholder:
                                              (context, url) => Container(
                                                height: 100,
                                                width: 100,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.image,
                                                  size: 50,
                                                ),
                                              ),
                                          errorWidget:
                                              (context, url, error) =>
                                                  Container(
                                                    height: 100,
                                                    width: 100,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.error_outline,
                                                      size: 50,
                                                    ),
                                                  ),
                                        ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      imageUrl = null;
                                      imagePath = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: unitController,
                          decoration: InputDecoration(
                            labelText: 'Satuan Masak',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: unitPurchaseController,
                          decoration: InputDecoration(
                            labelText: 'Satuan Pembelian',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: minimumPurchaseController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Minimum Pembelian',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: comparisonScaleController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Perbandingan Satuan',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (!mounted) return;
                            final path = await _pickImage();
                            if (path != null && mounted) {
                              setState(() {
                                imagePath = path;
                                imageUrl = null;
                              });
                            }
                          },
                          icon: const Icon(Icons.image),
                          label: const Text('Pick Image'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        String? uploadedImageUrl;
                        if (imagePath != null) {
                          try {
                            uploadedImageUrl = await uploadService.uploadImage(
                              imagePath!,
                            );
                          } catch (e) {
                            if (!mounted) return;
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error uploading image: ${e.toString()}',
                                ),
                              ),
                            );
                            return;
                          }
                        }

                        if (!mounted) return;
                        final newIngredient = Ingredient(
                          id: ingredient?.id ?? 1,
                          name: nameController.text,
                          unit: unitController.text,
                          unitPurchase: unitPurchaseController.text,
                          comparisonScale:
                              double.tryParse(comparisonScaleController.text) ??
                              1,
                          minimumPurchase:
                              double.tryParse(comparisonScaleController.text) ??
                              1,
                          imageUrl: uploadedImageUrl ?? imageUrl,
                        );
                        navigator.pop(newIngredient);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );

    if (result != null && mounted) {
      if (ingredient == null) {
        await context.read<IngredientsProvider>().createIngredient(result);
      } else {
        await context.read<IngredientsProvider>().updateIngredient(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<IngredientsProvider>(context);
    final filteredIngredients = _filterIngredients(provider.ingredients);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ingredients...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
              ? Center(child: Text(provider.error!))
              : ListView.builder(
                itemCount: filteredIngredients.length,
                itemBuilder: (context, index) {
                  final ingredient = filteredIngredients[index];
                  return ListTile(
                    leading:
                        ingredient.imageUrl != null
                            ? CachedNetworkImage(
                              imageUrl: ingredient.imageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image, size: 25),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.error_outline,
                                      size: 25,
                                    ),
                                  ),
                            )
                            : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 25,
                              ),
                            ),
                    title: Text(ingredient.name),
                    subtitle: Text(ingredient.unit),
                    onTap: () => _showIngredientDialog(ingredient),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showIngredientDialog(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
    );
  }
}
