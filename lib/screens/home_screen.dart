import 'package:baibanhang/models/product.dart';
import 'package:baibanhang/screens/cart_screen.dart';
import 'package:baibanhang/screens/order_history_screen.dart';
import 'package:baibanhang/screens/product_detail_screen.dart';
import 'package:baibanhang/services/product_service.dart';
import 'package:baibanhang/widgets/product_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();

  List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  // _limit: so item moi lan tai, _skip: so item da bo qua.
  int _limit = 10;
  int _skip = 0;
  bool _isAppBarSolid = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Diem bat dau luong du lieu: Home tai danh sach Product de hien thi.
    _fetchProducts();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    // Doi nen AppBar khi cuon de tang do tuong phan.
    final position = _scrollController.position;
    final shouldSolid = position.pixels > 18;
    if (shouldSolid != _isAppBarSolid) {
      setState(() {
        _isAppBarSolid = shouldSolid;
      });
    }

    // Tai tiep truoc khi cham day 200px de cuon muot hon.
    if (position.pixels >= position.maxScrollExtent - 200 &&
        _hasMore &&
        !_isLoading) {
      _fetchProducts();
    }
  }

  Future<void> _fetchProducts({bool refresh = false}) async {
    if (_isLoading) {
      return;
    }
    if (!_hasMore && !refresh) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (refresh) {
        // Pull-to-refresh reset lai trang thai phan trang.
        _skip = 0;
        _hasMore = true;
        _products = [];
      }
    });

    try {
      final fetched = await _requestProducts(limit: _limit, skip: _skip);
      if (!mounted) {
        return;
      }

      setState(() {
        _products.addAll(fetched);
        _skip += fetched.length;
        // Neu tra ve it hon limit thi xem nhu het du lieu.
        _hasMore = fetched.length >= _limit;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Khong tai duoc san pham. Vui long thu lai.';
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Product>> _requestProducts({
    required int limit,
    required int skip,
  }) async {
    try {
      // Tuong thich nguoc: neu service co fetchProducts(limit, skip) thi dung.
      final dynamic dynamicService = _productService;
      final dynamic result = await dynamicService.fetchProducts(
        limit: limit,
        skip: skip,
      );
      if (result is List<Product>) {
        return result;
      }
      if (result is List) {
        return result.whereType<Product>().toList();
      }
    } on NoSuchMethodError {
      // TODO: Remove this fallback once ProductService exposes fetchProducts.
    }

    // Fallback: lay toan bo roi cat theo skip/limit de mo phong pagination.
    final all = await _productService.getProducts();
    if (skip >= all.length) {
      return <Product>[];
    }
    var end = skip + limit;
    if (end > all.length) {
      end = all.length;
    }
    return all.sublist(skip, end);
  }

  SliverToBoxAdapter _buildSectionHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: [
            Text(
              'De xuat cho ban',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            TextButton(onPressed: () {}, child: const Text('Xem tat ca')),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSliver() {
    if (_products.isEmpty && _isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_products.isEmpty && _errorMessage != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _fetchProducts(refresh: true),
                  child: const Text('Thu lai'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text('Chua co san pham nao.')),
      );
    }

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        // Tu dong doi so cot theo do rong man hinh (responsive grid).
        final crossAxisCount = width >= 1000
            ? 5
            : (width >= 760 ? 4 : (width >= 520 ? 3 : 2));

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = _products[index];
              return ProductCard(
                product: product,
                onTap: () {
                  // Chuyen Product duoc chon sang man Detail qua route arguments.
                  Navigator.pushNamed(
                    context,
                    ProductDetailScreen.routeName,
                    arguments: product,
                  );
                },
              );
            }, childCount: _products.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.64,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _fetchProducts(refresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _HomeSliverAppBar(
              isSolid: _isAppBarSolid,
              onTapHistory: () {
                // OrderHistory doc du lieu tu CartProvider.orders (duoc tao o Checkout).
                Navigator.pushNamed(context, OrderHistoryScreen.routeName);
              },
              onTapCart: () {
                // Cart doc gio hien tai tu cung mot CartProvider dung chung toan app.
                Navigator.pushNamed(context, CartScreen.routeName);
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            const SliverToBoxAdapter(child: _HomeBannerSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            const SliverToBoxAdapter(child: _HomeCategorySection()),
            _buildSectionHeader(context),
            _buildProductSliver(),
            if (_isLoading && _products.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
          ],
        ),
      ),
    );
  }
}

class _HomeSliverAppBar extends StatelessWidget {
  const _HomeSliverAppBar({
    required this.isSolid,
    required this.onTapHistory,
    required this.onTapCart,
  });

  final bool isSolid;
  final VoidCallback onTapHistory;
  final VoidCallback onTapCart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      pinned: true,
      expandedHeight: 150,
      centerTitle: false,
      elevation: isSolid ? 2 : 0,
      backgroundColor: isSolid ? theme.colorScheme.primary : Colors.transparent,
      actions: [
        IconButton(
          onPressed: onTapHistory,
          icon: const Icon(Icons.history),
          tooltip: 'Lich su don hang',
        ),
        IconButton(
          onPressed: onTapCart,
          icon: const Icon(Icons.shopping_cart_outlined),
          tooltip: 'Gio hang',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(16, 58, 16, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.9),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TH4 - Nhom 4',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tim kiem san pham...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeBannerSection extends StatelessWidget {
  const _HomeBannerSection();

  @override
  Widget build(BuildContext context) {
    final banners = <_BannerItem>[
      const _BannerItem(
        title: 'Sieu sale 3.3',
        subtitle: 'Giam den 50% cho phu kien cong nghe',
        colors: [Color(0xFFF97316), Color(0xFFFB7185)],
      ),
      const _BannerItem(
        title: 'Mien phi van chuyen',
        subtitle: 'Ap dung don tu 99K',
        colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
      ),
      const _BannerItem(
        title: 'Hang moi ve',
        subtitle: 'Cap nhat san pham hot moi ngay',
        colors: [Color(0xFF16A34A), Color(0xFF4D7C0F)],
      ),
    ];

    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: banners.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: banner.colors,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  banner.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Xem ngay >',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HomeCategorySection extends StatelessWidget {
  const _HomeCategorySection();

  @override
  Widget build(BuildContext context) {
    const items = <({IconData icon, String label})>[
      (icon: Icons.flash_on, label: 'Flash Sale'),
      (icon: Icons.phone_android, label: 'Dien thoai'),
      (icon: Icons.watch_outlined, label: 'Dong ho'),
      (icon: Icons.chair_alt_outlined, label: 'Nha cua'),
      (icon: Icons.sports_esports_outlined, label: 'Gaming'),
      (icon: Icons.camera_alt_outlined, label: 'May anh'),
      (icon: Icons.headphones, label: 'Am thanh'),
      (icon: Icons.local_grocery_store, label: 'Sieu thi'),
      (icon: Icons.checkroom, label: 'Thoi trang'),
      (icon: Icons.more_horiz, label: 'Them'),
    ];

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 0.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BannerItem {
  const _BannerItem({
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  final String title;
  final String subtitle;
  final List<Color> colors;
}
