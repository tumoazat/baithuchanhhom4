import 'dart:async';

import 'package:baibanhang/models/product.dart';
import 'package:baibanhang/providers/cart_provider.dart';
import 'package:baibanhang/screens/cart_screen.dart';
import 'package:baibanhang/screens/login_screen.dart';
import 'package:baibanhang/screens/order_history_screen.dart';
import 'package:baibanhang/screens/product_detail_screen.dart';
import 'package:baibanhang/services/auth_service.dart';
import 'package:baibanhang/services/product_service.dart';
import 'package:baibanhang/widgets/cart_badge.dart';
import 'package:baibanhang/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _limit = 10;
  int _skip = 0;
  bool _isAppBarSolid = false;
  String? _errorMessage;
  String _selectedCategory = 'Tat ca';
  String _searchQuery = '';

  static const List<String> _categories = [
    'Tat ca',
    'Quan ao',
    'Nha cua',
    'Gaming',
    'Dien tu',
    'Phu kien',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchProducts();
    _initializeCart();
  }

  // Khởi tạo giỏ hàng từ Firestore khi user đăng nhập
  Future<void> _initializeCart() async {
    try {
      final authService = AuthService();
      final userId = await authService.getCurrentUserId();
      
      if (userId != null) {
        final cartProvider = context.read<CartProvider>();
        await cartProvider.initializeWithUser(userId);
        print('✅ Giỏ hàng đã được khởi tạo cho user: $userId');
      }
    } catch (e) {
      print('❌ Lỗi khởi tạo giỏ hàng: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final shouldSolid = position.pixels > 18;
    if (shouldSolid != _isAppBarSolid) {
      setState(() {
        _isAppBarSolid = shouldSolid;
      });
    }

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
    return _productService.fetchProducts(limit: limit, skip: skip);
  }

  String _resolveCategory(Product product) {
    final text = '${product.name} ${product.description}'.toLowerCase();
    if (text.contains('ao') || text.contains('giay') || text.contains('thoi trang')) {
      return 'Quan ao';
    }
    if (text.contains('nha') || text.contains('bep') || text.contains('gia do')) {
      return 'Nha cua';
    }
    if (text.contains('gaming') || text.contains('chuot') || text.contains('ban phim')) {
      return 'Gaming';
    }
    if (text.contains('man hinh') || text.contains('dien tu') || text.contains('laptop')) {
      return 'Dien tu';
    }
    return 'Phu kien';
  }

  List<Product> get _visibleProducts {
    final query = _searchQuery.trim().toLowerCase();

    return _products.where((product) {
      final matchCategory =
          _selectedCategory == 'Tat ca' ||
          _resolveCategory(product) == _selectedCategory;

      if (!matchCategory) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final searchable =
          '${product.name} ${product.description}'.toLowerCase();
      return searchable.contains(query);
    })
        .toList(growable: false);
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
    final products = _visibleProducts;

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

    if (products.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            _searchQuery.trim().isEmpty
                ? 'Khong tim thay san pham phu hop bo loc.'
                : 'Khong tim thay ket qua cho "${_searchQuery.trim()}".',
          ),
        ),
      );
    }

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final crossAxisCount = width >= 1000
            ? 5
            : (width >= 760 ? 4 : (width >= 520 ? 3 : 2));

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    ProductDetailScreen.routeName,
                    arguments: product,
                  );
                },
              );
            }, childCount: products.length),
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
              searchController: _searchController,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onTapHistory: () {
                Navigator.pushNamed(context, OrderHistoryScreen.routeName);
              },
              onTapCart: () {
                Navigator.pushNamed(context, CartScreen.routeName);
              },
              onTapLogout: () async {
                await AuthService().signOut();
                
                // Xóa dữ liệu giỏ hàng
                if (mounted) {
                  final cartProvider = context.read<CartProvider>();
                  cartProvider.logout();
                }
                
                if (!mounted) {
                  return;
                }
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  LoginScreen.routeName,
                  (_) => false,
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            const SliverToBoxAdapter(child: _HomeBannerSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            const SliverToBoxAdapter(child: _FlashSaleSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _HomeCategorySection(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onSelected: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
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
    required this.searchController,
    required this.onSearchChanged,
    required this.onTapHistory,
    required this.onTapCart,
    required this.onTapLogout,
  });

  final bool isSolid;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onTapHistory;
  final VoidCallback onTapCart;
  final VoidCallback onTapLogout;

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
          onPressed: onTapLogout,
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Dang xuat',
        ),
        CartBadge(
          onPressed: onTapCart,
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
                'TH4 - Nhom 4 | Mall',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Tim kiem san pham, deal hot...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                            icon: const Icon(Icons.close_rounded, size: 18),
                          ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
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

class _HomeBannerSection extends StatefulWidget {
  const _HomeBannerSection();

  @override
  State<_HomeBannerSection> createState() => _HomeBannerSectionState();
}

class _HomeBannerSectionState extends State<_HomeBannerSection> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  int _currentIndex = 0;
  Timer? _timer;

  final List<_BannerItem> _banners = const <_BannerItem>[
    _BannerItem(
      title: 'Sieu sale 3.3',
      subtitle: 'Giam den 50% cho phu kien cong nghe',
      colors: [Color(0xFFF97316), Color(0xFFFB7185)],
    ),
    _BannerItem(
      title: 'Mien phi van chuyen',
      subtitle: 'Ap dung don tu 99K',
      colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
    ),
    _BannerItem(
      title: 'Hang moi ve',
      subtitle: 'Cap nhat san pham hot moi ngay',
      colors: [Color(0xFF16A34A), Color(0xFF4D7C0F)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients) {
        return;
      }
      final next = (_currentIndex + 1) % _banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Container(
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
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: _currentIndex == index ? 22 : 6,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? const Color(0xFFFF6A00)
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FlashSaleSection extends StatefulWidget {
  const _FlashSaleSection();

  @override
  State<_FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<_FlashSaleSection> {
  final PageController _controller = PageController(viewportFraction: 0.95);
  int _current = 0;
  Timer? _timer;

  final List<({String title, String subtitle, int percent})> _items = const [
    (title: 'Tai nghe gaming', subtitle: 'So luong co han', percent: 35),
    (title: 'Ban phim co mini', subtitle: 'Deal gia tot 12h', percent: 42),
    (title: 'Chuot khong day', subtitle: 'Giam them voucher', percent: 28),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_controller.hasClients) {
        return;
      }
      final next = (_current + 1) % _items.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: PageView.builder(
        controller: _controller,
        itemCount: _items.length,
        onPageChanged: (index) {
          setState(() {
            _current = index;
          });
        },
        itemBuilder: (context, index) {
          final item = _items[index];
          final isActive = _current == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 220),
              scale: isActive ? 1 : 0.98,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5A24), Color(0xFFFF8A00)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33FF5A24),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.flash_on,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'FLASH SALE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '-${item.percent}%',
                        style: const TextStyle(
                          color: Color(0xFFFF5A24),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeCategorySection extends StatelessWidget {
  const _HomeCategorySection({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final iconMap = <String, IconData>{
      'Tat ca': Icons.grid_view_rounded,
      'Quan ao': Icons.checkroom,
      'Nha cua': Icons.chair_alt_outlined,
      'Gaming': Icons.sports_esports_outlined,
      'Dien tu': Icons.devices_other_rounded,
      'Phu kien': Icons.watch_outlined,
    };

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
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.35,
            crossAxisSpacing: 8,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            final selected = category == selectedCategory;
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSelected(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFFE3D2)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFFF6A00)
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      iconMap[category] ?? Icons.category_outlined,
                      size: 18,
                      color: selected
                          ? const Color(0xFFFF6A00)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: selected
                              ? const Color(0xFFFF6A00)
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
