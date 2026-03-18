import 'package:baibanhang/providers/cart_provider.dart';
import 'package:baibanhang/services/product_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CartProvider', () {
    test('loads empty cart from empty storage', () async {
      final provider = CartProvider();
      await provider.loadCartFromStorage();

      expect(provider.itemCount, 0);
      expect(provider.items, isEmpty);
    });

    test('merges items with identical variants', () async {
      final provider = CartProvider();
      await provider.loadCartFromStorage();
      final product = ProductService.getProducts().first;

      provider.addToCart(product: product, size: 'M', color: 'Black');
      provider.addToCart(
        product: product,
        size: 'M',
        color: 'Black',
        quantity: 2,
      );

      expect(provider.items.length, 1);
      expect(provider.itemCount, 1);
      expect(provider.items.single.quantity, 3);
    });

    test('keeps separate entries for different variants', () async {
      final provider = CartProvider();
      await provider.loadCartFromStorage();
      final product = ProductService.getProducts().first;

      provider.addToCart(product: product, size: 'M', color: 'Black');
      provider.addToCart(product: product, size: 'L', color: 'Black');
      provider.addToCart(product: product, size: 'M', color: 'Red');

      expect(provider.itemCount, 3);
      expect(provider.items.map((e) => e.selectedSize).toSet().length, 2);
      expect(provider.items.map((e) => e.selectedColor).toSet().length, 2);
    });

    test('toggles selections and computes totals', () async {
      final provider = CartProvider();
      await provider.loadCartFromStorage();
      final product = ProductService.getProducts().first;

      provider.addToCart(
        product: product,
        size: 'L',
        color: 'Red',
        quantity: 2,
      );

      expect(provider.items.length, 1);
      final cartItem = provider.items.single;
      provider.toggleCheck(cartItem.id);

      expect(provider.totalSelectedQuantity, 2);
      expect(
        provider.totalSelectedPrice,
        product.price * 2,
      );

      provider.toggleCheckAll(false);
      expect(provider.totalSelectedQuantity, 0);
    });
  });
}
