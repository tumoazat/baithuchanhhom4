import 'package:baibanhang/models/product.dart';
import 'package:baibanhang/providers/cart_provider.dart';
import 'package:baibanhang/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  static const routeName = '/product-detail';

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final PageController _pageController;
  late final List<String> _imageUrls;
  int _currentImage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _imageUrls = _buildImageUrls();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> _buildImageUrls() {
    final urls = <String>[];
    final primaryImage = widget.product.imageUrl?.trim();

    if (primaryImage != null && primaryImage.isNotEmpty) {
      urls.add(primaryImage);
    }

    urls.addAll([
      'https://picsum.photos/seed/${widget.product.id}-1/900/900',
      'https://picsum.photos/seed/${widget.product.id}-2/900/900',
      'https://picsum.photos/seed/${widget.product.id}-3/900/900',
    ]);

    return urls;
  }

  String _heroTag() => 'product-hero-${widget.product.id}';

  String _formatPrice(double value) {
    final digits = value.round().toString();
    final reversed = digits.split('').reversed.toList();
    final groups = <String>[];

    for (var i = 0; i < reversed.length; i += 3) {
      final chunk = reversed.skip(i).take(3).toList();
      groups.add(chunk.reversed.join());
    }

    return groups.reversed.join('.');
  }

  Future<void> _openVariantBottomSheet({required bool buyNow}) async {
    final result = await showModalBottomSheet<_VariantSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        var size = 'M';
        var color = 'Xanh';
        var quantity = 1;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                4,
                16,
                12 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _imageUrls.first,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chon Kich co',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['S', 'M', 'L']
                        .map((item) {
                          return ChoiceChip(
                            label: Text(item),
                            selected: size == item,
                            onSelected: (_) {
                              setModalState(() {
                                size = item;
                              });
                            },
                          );
                        })
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Chon Mau sac',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Xanh', 'Do']
                        .map((item) {
                          return ChoiceChip(
                            label: Text(item),
                            selected: color == item,
                            onSelected: (_) {
                              setModalState(() {
                                color = item;
                              });
                            },
                          );
                        })
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        'So luong',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            if (quantity > 1) {
                              quantity--;
                            }
                          });
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$quantity',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            quantity++;
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                          _VariantSelection(
                            size: size,
                            color: color,
                            quantity: quantity,
                          ),
                        );
                      },
                      child: const Text('Xac nhan'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    final cart = context.read<CartProvider>();
    for (var i = 0; i < result.quantity; i++) {
      cart.addProduct(widget.product);
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Them thanh cong')));

    if (buyNow) {
      Navigator.pushNamed(context, CartScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final salePrice = widget.product.price;
    final originalPrice = salePrice * 1.35;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiet san pham')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 320,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _imageUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final image = Image.network(
                        _imageUrls[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) {
                            return child;
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: Icon(Icons.image_not_supported_outlined),
                            ),
                          );
                        },
                      );

                      if (index == 0) {
                        return Hero(tag: _heroTag(), child: image);
                      }

                      return image;
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_imageUrls.length, (index) {
                        final active = _currentImage == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 18 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: active ? Colors.white : Colors.white70,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_formatPrice(salePrice)} VND',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${_formatPrice(originalPrice)} VND',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            InkWell(
              onTap: () => _openVariantBottomSheet(buyNow: false),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Chon Kich co, Mau sac',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mo ta chi tiet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ExpandableDescription(text: widget.product.description),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _DetailBottomBar(
        onTapCart: () {
          Navigator.pushNamed(context, CartScreen.routeName);
        },
        onTapChat: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Tinh nang chat se cap nhat sau.')),
            );
        },
        onAddToCart: () => _openVariantBottomSheet(buyNow: false),
        onBuyNow: () => _openVariantBottomSheet(buyNow: true),
      ),
    );
  }
}

class _DetailBottomBar extends StatelessWidget {
  const _DetailBottomBar({
    required this.onTapChat,
    required this.onTapCart,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  final VoidCallback onTapChat;
  final VoidCallback onTapCart;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _BottomBarIcon(
                    icon: Icons.chat_bubble_outline,
                    label: 'Chat',
                    onTap: onTapChat,
                  ),
                  Consumer<CartProvider>(
                    builder: (context, cart, _) {
                      return _BottomBarIcon(
                        icon: Icons.shopping_cart_outlined,
                        label: 'Gio hang',
                        onTap: onTapCart,
                        badgeCount: cart.itemCount,
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: onAddToCart,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEDD5),
                        foregroundColor: Colors.deepOrange,
                      ),
                      child: const Text('Them vao gio'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: onBuyNow,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Mua ngay'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBarIcon extends StatelessWidget {
  const _BottomBarIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 20),
                if (badgeCount > 0)
                  Positioned(
                    right: -9,
                    top: -7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          '$badgeCount',
                          key: ValueKey<int>(badgeCount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _ExpandableDescription extends StatefulWidget {
  const _ExpandableDescription({required this.text});

  final String text;

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: textStyle);
        final painter = TextPainter(
          text: span,
          maxLines: 5,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflow = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: span,
              maxLines: _expanded ? null : 5,
              overflow: TextOverflow.ellipsis,
            ),
            if (overflow)
              TextButton(
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                child: Text(_expanded ? 'Thu gon' : 'Xem them'),
              ),
          ],
        );
      },
    );
  }
}

class _VariantSelection {
  const _VariantSelection({
    required this.size,
    required this.color,
    required this.quantity,
  });

  final String size;
  final String color;
  final int quantity;
}
