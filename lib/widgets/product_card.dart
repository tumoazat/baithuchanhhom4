import 'package:baibanhang/models/product.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  String _resolveImage() {
    final image = product.imageUrl?.trim();
    if (image != null && image.isNotEmpty) {
      return image;
    }
    return 'https://picsum.photos/seed/${product.id}/600/600';
  }

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

  int _fakeSoldCount() {
    final seed = product.id.codeUnits.fold<int>(0, (sum, code) => sum + code);
    return 120 + (seed * 17) % 9200;
  }

  String _heroTag() => 'product-hero-${product.id}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sold = _fakeSoldCount();

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.65),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: _heroTag(),
                    child: Image.network(
                      _resolveImage(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _TagPill(
                      label: 'Mall',
                      color: Colors.orange.shade700,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.88),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _TagPill(label: 'Yeu thich', color: Colors.pink.shade400),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatPrice(product.price)} VND',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Da ban $sold',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
