import 'package:baibanhang/models/product.dart';

class ProductService {
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
    ];
  }
}
