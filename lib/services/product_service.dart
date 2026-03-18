import 'dart:convert';

import 'package:baibanhang/models/product.dart';
import 'package:http/http.dart' as http;

class ProductService {
  static const String _openFoodFactsBase =
      'https://world.openfoodfacts.org/api/v2/search';

  Future<List<Product>> fetchProducts({
    required int limit,
    required int skip,
  }) async {
    final safeLimit = limit <= 0 ? 10 : limit;
    final page = (skip ~/ safeLimit) + 1;

    try {
      final uri = Uri.parse(_openFoodFactsBase).replace(
        queryParameters: {
          'fields':
              'code,product_name,generic_name,image_front_url,nutriments',
          'page_size': '$safeLimit',
          'page': '$page',
        },
      );

      final response = await http
          .get(uri, headers: const {'User-Agent': 'baibanhang-app/1.0'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final productsRaw = decoded['products'];
          if (productsRaw is List) {
            final products = productsRaw
                .whereType<Map<String, dynamic>>()
                .map(_mapOpenFoodFactsToProduct)
                .whereType<Product>()
                .toList(growable: false);

            if (products.isNotEmpty) {
              return products;
            }
          }
        }
      }
    } catch (_) {
      // Fallback to local data below when network/API fails.
    }

    final all = await getProducts();
    if (skip >= all.length) {
      return <Product>[];
    }

    final end = (skip + safeLimit) > all.length ? all.length : (skip + safeLimit);
    return all.sublist(skip, end);
  }

  Product? _mapOpenFoodFactsToProduct(Map<String, dynamic> json) {
    final id = (json['code'] ?? '').toString().trim();
    final productName = (json['product_name'] ?? '').toString().trim();
    final genericName = (json['generic_name'] ?? '').toString().trim();
    final imageUrl = (json['image_front_url'] ?? '').toString().trim();

    if (id.isEmpty || productName.isEmpty) {
      return null;
    }

    final nutriments = json['nutriments'];
    final energyKcal = nutriments is Map<String, dynamic>
        ? _toDouble(nutriments['energy-kcal_100g']) ??
              _toDouble(nutriments['energy_100g'])
        : null;

    return Product(
      id: id,
      name: productName,
      description: genericName.isNotEmpty
          ? genericName
          : 'San pham thuc pham tu OpenFoodFacts',
      price: _estimatePriceVnd(id: id, energyKcal: energyKcal),
      imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
    );
  }

  double _estimatePriceVnd({required String id, double? energyKcal}) {
    if (energyKcal != null && energyKcal > 0) {
      final computed = (energyKcal * 1200).clamp(12000, 399000);
      return computed.toDouble();
    }

    final hash = id.codeUnits.fold<int>(0, (sum, code) => sum + code);
    return (15000 + (hash % 240) * 1000).toDouble();
  }

  double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return const [
      Product(
        id: 'p1',
        name: 'Tai nghe Bluetooth',
        description:
            'Tai nghe Bluetooth phien ban Pro, thiet ke gon nhe va om tai.\n'
            'Driver 40mm cho am bass day, vocal ro va treble trong.\n'
            'Micro kep ket hop thuat toan loc tap am khi goi video.\n'
            'Ho tro ket noi da diem voi dien thoai va laptop cung luc.\n'
            'Hop sac USB-C, tong thoi gian su dung den 30 gio lien tuc.\n'
            'Che do game do tre thap, dong bo am thanh va hinh anh tot hon.',
        price: 890000,
      ),
      Product(
        id: 'p2',
        name: 'Ban phim co mini',
        description: 'Ban phim co 68 phim, switch linear, den RGB.',
        price: 1290000,
      ),
      Product(
        id: 'p3',
        name: 'Chuot gaming',
        description:
            'Chuot gaming cam bien 26000 DPI voi tracking chinh xac cao.\n'
            'Trong luong 58g giup lia nhanh va giam moi co tay khi choi lau.\n'
            'Switch click ben bi den 80 trieu lan bam, phan hoi nhanh.\n'
            'Ket noi 2.4GHz va Bluetooth, de dang chuyen doi thiet bi.\n'
            'Feet PTFE giam ma sat, di chuyen muot tren nhieu be mat.\n'
            'Phan mem ho tro macro, profile DPI va dong bo den RGB.',
        price: 990000,
      ),
      Product(
        id: 'p4',
        name: 'Man hinh 27 inch',
        description:
            'Man hinh 27 inch do phan giai 2K cho khong gian hien thi rong.\n'
            'Tan so quet 165Hz giup thao tac muot trong game va chuyen dong.\n'
            'Tam nen IPS hien thi mau sac trung thuc, goc nhin rong 178 do.\n'
            'Ho tro HDR co ban, do sang toi da 350 nits cho noi dung ro hon.\n'
            'Cong ket noi day du gom HDMI, DisplayPort va cong audio out.\n'
            'Chan de co the nang ha, nghieng va xoay de toi uu tu the ngoi.',
        price: 5490000,
      ),
      Product(
        id: 'p5',
        name: 'Gia do laptop',
        description: 'Hop kim nhom, tang thoang khi, giam moi co tay.',
        price: 390000,
      ),
      Product(
        id: 'p6',
        name: 'Ao thun oversize',
        description: 'Vai cotton mem, thoang khi, phu hop mac hang ngay.',
        price: 219000,
      ),
      Product(
        id: 'p7',
        name: 'Quan jogger nam',
        description: 'Chat lieu ni co gian nhe, bo ong gon dep.',
        price: 349000,
      ),
      Product(
        id: 'p8',
        name: 'Giay sneaker trang',
        description: 'De cao su em chan, thiet ke toi gian de phoi do.',
        price: 799000,
      ),
      Product(
        id: 'p9',
        name: 'Noi chien khong dau 6L',
        description: 'Cong suat 1700W, man hinh cam ung, de ve sinh.',
        price: 1790000,
      ),
      Product(
        id: 'p10',
        name: 'Bo hop bao quan thuc pham',
        description: 'Nhua an toan, kin mui, dung duoc trong lo vi song.',
        price: 259000,
      ),
      Product(
        id: 'p11',
        name: 'Den ban hoc chong can',
        description: '3 che do anh sang, dieu chinh do cao linh hoat.',
        price: 480000,
      ),
      Product(
        id: 'p12',
        name: 'Tay cam choi game wireless',
        description: 'Ho tro rung, ket noi bluetooth, pin dung lau.',
        price: 920000,
      ),
      Product(
        id: 'p13',
        name: 'Ban di chuot RGB',
        description: 'Kich thuoc lon, vien den RGB, be mat muot.',
        price: 290000,
      ),
      Product(
        id: 'p14',
        name: 'Laptop van phong 14 inch',
        description: 'Chip i5, RAM 16GB, SSD 512GB, man hinh Full HD.',
        price: 15490000,
      ),
      Product(
        id: 'p15',
        name: 'Tablet 10.9 inch',
        description: 'Pin lon, man hinh dep, phu hop hoc tap va giai tri.',
        price: 8990000,
      ),
      Product(
        id: 'p16',
        name: 'Dong ho thong minh',
        description: 'Theo doi suc khoe, thong bao cuoc goi, chong nuoc IP68.',
        price: 1290000,
      ),
      Product(
        id: 'p17',
        name: 'Loa bluetooth mini',
        description: 'Am thanh trong, bass tot, pin 12 gio.',
        price: 690000,
      ),
      Product(
        id: 'p18',
        name: 'Tu vai 3 ngan',
        description: 'Khung sat chac chan, de lap, phu hop phong nho.',
        price: 560000,
      ),
      Product(
        id: 'p19',
        name: 'Kem chong nang SPF50',
        description: 'Ket cau mong nhe, khong bet dinh, phu hop da dau.',
        price: 245000,
      ),
      Product(
        id: 'p20',
        name: 'Sua rua mat diu nhe',
        description: 'Lam sach sau, giu am, khong lam kho da.',
        price: 169000,
      ),
      Product(
        id: 'p21',
        name: 'Ba lo du lich 25L',
        description: 'Nhieu ngan, chong tham nhe, quai deo em vai.',
        price: 450000,
      ),
      Product(
        id: 'p22',
        name: 'Binh giu nhiet 700ml',
        description: 'Inox 304, giu nong lanh 12 gio.',
        price: 199000,
      ),
      Product(
        id: 'p23',
        name: 'USB-C Hub 7 in 1',
        description: 'Mo rong cong ket noi HDMI, USB, the nho SD.',
        price: 790000,
      ),
      Product(
        id: 'p24',
        name: 'Camera an ninh trong nha',
        description: 'Do phan giai 2K, quay quet 360 do, dam thoai 2 chieu.',
        price: 1190000,
      ),
    ];
  }
}
