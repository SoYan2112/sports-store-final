import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static const String _dbName = 'sports_store_local.db';
  static const int _dbVersion = 1;

  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Hỗ trợ Desktop (Windows, macOS, Linux) và Test runner
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Bảng Users (Xác thực & Hồ sơ cá nhân)
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        fullname TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone_number TEXT,
        password TEXT NOT NULL,
        gender TEXT DEFAULT 'Nam',
        date_of_birth TEXT,
        avatar_url TEXT,
        created_at TEXT NOT NULL,
        status TEXT DEFAULT 'ACTIVE'
      );
    ''');

    // 2. Bảng Categories (Ngành hàng thể thao)
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        image_url TEXT,
        description TEXT,
        item_count INTEGER DEFAULT 0
      );
    ''');

    // 3. Bảng Products (Sản phẩm thể thao)
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        brand TEXT NOT NULL,
        price REAL NOT NULL,
        original_price REAL,
        image_url TEXT NOT NULL,
        badge TEXT,
        rating REAL DEFAULT 5.0,
        review_count INTEGER DEFAULT 0,
        description TEXT,
        images_json TEXT,
        category TEXT DEFAULT 'Giày thể thao',
        category_id TEXT,
        stock INTEGER DEFAULT 15,
        sizes_json TEXT,
        colors_json TEXT,
        created_at TEXT
      );
    ''');

    // 4. Bảng Product Ratings (Đánh giá & nhận xét sao)
    await db.execute('''
      CREATE TABLE product_ratings (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        user_name TEXT NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT,
        created_at TEXT NOT NULL
      );
    ''');

    // 5. Bảng Cart Items (Giỏ hàng)
    await db.execute('''
      CREATE TABLE cart_items (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        price REAL NOT NULL,
        image_url TEXT,
        brand TEXT,
        selected_size TEXT,
        selected_color INTEGER,
        quantity INTEGER NOT NULL DEFAULT 1,
        stock INTEGER DEFAULT 15
      );
    ''');

    // 6. Bảng Orders (Đơn hàng)
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        recipient_name TEXT,
        phone_number TEXT,
        province TEXT,
        district TEXT,
        ward TEXT,
        street_address TEXT,
        payment_method TEXT,
        shipping_method TEXT,
        subtotal REAL NOT NULL,
        shipping_fee REAL DEFAULT 30000,
        discount_amount REAL DEFAULT 0,
        total_amount REAL NOT NULL,
        note TEXT,
        status TEXT DEFAULT 'Chờ xác nhận',
        created_at TEXT NOT NULL
      );
    ''');

    // 7. Bảng Order Items (Chi tiết món hàng trong đơn)
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        name TEXT NOT NULL,
        brand TEXT,
        price REAL NOT NULL,
        image_url TEXT,
        selected_size TEXT,
        selected_color INTEGER,
        quantity INTEGER NOT NULL
      );
    ''');

    // 8. Bảng Vouchers (Mã giảm giá)
    await db.execute('''
      CREATE TABLE vouchers (
        id TEXT PRIMARY KEY,
        code TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        discount_value REAL NOT NULL,
        min_order_value REAL DEFAULT 0,
        max_discount_amount REAL,
        start_date TEXT,
        end_date TEXT,
        is_used INTEGER DEFAULT 0
      );
    ''');

    // 9. Bảng Shipping Addresses (Sổ địa chỉ giao hàng)
    await db.execute('''
      CREATE TABLE shipping_addresses (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        recipient_name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        province TEXT NOT NULL,
        district TEXT NOT NULL,
        ward TEXT NOT NULL,
        street_address TEXT NOT NULL,
        label TEXT DEFAULT 'home',
        is_default INTEGER DEFAULT 0
      );
    ''');

    // Nạp sẵn dữ liệu ban đầu (Seed Data)
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final batch = db.batch();

    // 1. Seed Users (2 tài khoản test ban đầu)
    batch.insert('users', {
      'id': '1',
      'fullname': 'Nguyễn Văn A',
      'email': 'a@gmail.com',
      'phone_number': '0901234567',
      'password': '123456',
      'gender': 'Nam',
      'date_of_birth': '1998-05-15',
      'avatar_url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500',
      'created_at': DateTime(2026, 1, 10).toIso8601String(),
      'status': 'ACTIVE',
    });

    batch.insert('users', {
      'id': '2',
      'fullname': 'Nguyễn Văn B',
      'email': 'b@gmail.com',
      'phone_number': '0912345678',
      'password': '123456',
      'gender': 'Nam',
      'date_of_birth': '2000-08-20',
      'avatar_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500',
      'created_at': DateTime(2026, 2, 5).toIso8601String(),
      'status': 'ACTIVE',
    });

    // 2. Seed Categories
    final categories = [
      {
        'id': 'cat_shoes',
        'name': 'Giày thể thao',
        'image_url': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=700&auto=format&fit=crop&q=80',
        'description': 'Giày chạy bộ, bóng rổ, training trợ lực đỉnh cao.',
        'item_count': 8,
      },
      {
        'id': 'cat_tops',
        'name': 'Áo thể thao',
        'image_url': 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=700&auto=format&fit=crop&q=80',
        'description': 'Áo thun thoáng khí, áo khoác gió, áo thi đấu chính hãng.',
        'item_count': 3,
      },
      {
        'id': 'cat_bottoms',
        'name': 'Quần thể thao',
        'image_url': 'https://images.unsplash.com/photo-1517438476312-10d79c077509?w=700&auto=format&fit=crop&q=80',
        'description': 'Quần shorts chạy bộ, quần jogger co giãn 4 chiều.',
        'item_count': 2,
      },
      {
        'id': 'cat_accessories',
        'name': 'Phụ kiện thể thao',
        'image_url': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=700&auto=format&fit=crop&q=80',
        'description': 'Balo chống nước, tất khử mùi, mũ lưỡi trai và bình nước.',
        'item_count': 2,
      },
      {
        'id': 'cat_gear',
        'name': 'Dụng cụ tập luyện',
        'image_url': 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=700&auto=format&fit=crop&q=80',
        'description': 'Thảm yoga bám sàn, dây kháng lực, tạ tay và băng quấn.',
        'item_count': 2,
      },
      {
        'id': 'cat_protection',
        'name': 'Đồ bảo hộ & Hỗ trợ',
        'image_url': 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=700&auto=format&fit=crop&q=80',
        'description': 'Băng bảo vệ khớp gối, cổ tay, mắt cá hạn chế chấn thương.',
        'item_count': 2,
      },
    ];
    for (final cat in categories) {
      batch.insert('categories', cat);
    }

    // 3. Seed Products (12 sản phẩm đa thương hiệu thể thao cao cấp)
    final products = [
      {
        'id': 'prod_01',
        'name': 'Nike Air Zoom Pegasus 40',
        'brand': 'Nike',
        'price': 3490000.0,
        'original_price': 3890000.0,
        'image_url': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&auto=format&fit=crop&q=80',
        'badge': 'Hot Deal',
        'rating': 4.9,
        'review_count': 128,
        'description': 'Đôi giày chạy bộ huyền thoại với công nghệ đệm khí Zoom Air kép ở gót và mũi, đế React bồng bềnh êm ái.',
        'images_json': jsonEncode([
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=800&auto=format&fit=crop&q=80',
        ]),
        'category': 'Giày thể thao',
        'category_id': 'cat_shoes',
        'stock': 25,
        'sizes_json': jsonEncode(['39', '40', '41', '42', '43']),
        'colors_json': jsonEncode([0xFFFF6B00, 0xFF1A1A1A, 0xFFFFFFFF]),
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'prod_02',
        'name': 'Adidas Ultraboost Light 23',
        'brand': 'Adidas',
        'price': 4200000.0,
        'original_price': 5200000.0,
        'image_url': 'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=800&auto=format&fit=crop&q=80',
        'badge': 'Best Seller',
        'rating': 4.8,
        'review_count': 94,
        'description': 'Thế hệ đệm Boost nhẹ hơn 30%, thân giày Primeknit+ ôm sát chuyển động bàn chân, đế ngoài cao su Continental siêu bám.',
        'images_json': jsonEncode([
          'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1556906781-9a412961c28c?w=800&auto=format&fit=crop&q=80',
        ]),
        'category': 'Giày thể thao',
        'category_id': 'cat_shoes',
        'stock': 18,
        'sizes_json': jsonEncode(['40', '41', '42', '42.5', '43']),
        'colors_json': jsonEncode([0xFFFFFFFF, 0xFF1A1A1A, 0xFFFF6B00]),
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'prod_03',
        'name': 'Puma Velocity Nitro 2',
        'brand': 'Puma',
        'price': 2790000.0,
        'original_price': 3190000.0,
        'image_url': 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=800&auto=format&fit=crop&q=80',
        'badge': 'Mới',
        'rating': 4.7,
        'review_count': 56,
        'description': 'Đệm khí NITRO Foam siêu nhạy giúp bứt tốc linh hoạt trên mọi cung đường đô thị, phản quang 360 độ.',
        'images_json': jsonEncode([
          'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=800&auto=format&fit=crop&q=80',
        ]),
        'category': 'Giày thể thao',
        'category_id': 'cat_shoes',
        'stock': 14,
        'sizes_json': jsonEncode(['39', '40', '41', '42', '43']),
        'colors_json': jsonEncode([0xFF1A1A1A, 0xFFFF6B00]),
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'prod_04',
        'name': 'Jordan Stay Loyal 2',
        'brand': 'Nike',
        'price': 3690000.0,
        'original_price': 4100000.0,
        'image_url': 'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=800&auto=format&fit=crop&q=80',
        'badge': 'Hot Deal',
        'rating': 4.9,
        'review_count': 82,
        'description': 'Thiết kế bóng rổ đậm chất đường phố Chicago huyền thoại với Air-Sole nhìn thấu độc đáo.',
        'images_json': jsonEncode([
          'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=800&auto=format&fit=crop&q=80',
        ]),
        'category': 'Giày thể thao',
        'category_id': 'cat_shoes',
        'stock': 10,
        'sizes_json': jsonEncode(['40', '41', '42', '43', '44']),
        'colors_json': jsonEncode([0xFF1A1A1A, 0xFFFF6B00, 0xFFFFFFFF]),
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'prod_05',
        'name': 'Áo thun Nike Dri-FIT Form Fit',
        'brand': 'Nike',
        'price': 850000.0,
        'original_price': 990000.0,
        'image_url': 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=800&auto=format&fit=crop&q=80',
        'badge': 'Best Seller',
        'rating': 4.8,
        'review_count': 115,
        'description': 'Chất vải sợi Dri-FIT thấm hút mồ hôi siêu tốc, giữ cơ thể luôn khô ráo và nhẹ nhàng trong từng buổi tập gym cường độ cao.',
        'images_json': jsonEncode([
          'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=800&auto=format&fit=crop&q=80',
        ]),
        'category': 'Áo thể thao',
        'category_id': 'cat_tops',
        'stock': 35,
        'sizes_json': jsonEncode(['S', 'M', 'L', 'XL', '2XL']),
        'colors_json': jsonEncode([0xFF1A1A1A, 0xFFFF6B00, 0xFF767677]),
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'prod_06',
        'name': 'Áo khoác gió Adidas Adicolor Classics',
        'brand': 'Adidas',
        'price': 1850000.0,
        'original_price': 2200000.0,
        'image_url': 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&auto=format&fit=crop&q=80',
        'badge': 'Mới',
        'rating': 4.7,
        'review_count': 42,
        'description': 'Phong cách 3 sọc thể thao nguyên bản, chống nước nhẹ, cản gió cực tốt khi chạy bộ buổi sáng sớm.',
        'images_json': jsonEncode([
          'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&auto=format&fit=crop&q=80',
        ]),
        'category': 'Áo thể thao',
        'category_id': 'cat_tops',
        'stock': 20,
        'sizes_json': jsonEncode(['M', 'L', 'XL']),
        'colors_json': jsonEncode([0xFF1A1A1A, 0xFFFFFFFF]),
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'prod_07',
        'name': 'Quần Shorts Puma Run Favorite 5"',
        'brand': 'Puma',
        'price': 690000.0,
        'original_price': 850000.0,
        'image_url': 'https://images.unsplash.com/photo-1517438476312-10d79c077509?w=800&auto=format&fit=crop&q=80',
        'badge': 'Hot Deal',
        'rating': 4.8,
        'review_count': 67,
        'description': 'Quần shorts cự ly 5 inch siêu nhẹ có lớp lót kháng khuẩn, túi sau lưng đựng chìa khóa và điện thoại tiện lợi.',
        'images_json': jsonEncode([
          'https://images.unsplash.com/photo-1517438476312-10d79c077509?w=800&auto=format&fit=crop&q=80',
        ]),
        'category': 'Quần thể thao',
        'category_id': 'cat_bottoms',
        'stock': 28,
        'sizes_json': jsonEncode(['M', 'L', 'XL']),
        'colors_json': jsonEncode([0xFF1A1A1A, 0xFFFF6B00]),
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'prod_08',
        'name': 'Balo thể thao Nike Brasilia 9.5 (30L)',
        'brand': 'Nike',
        'price': 1050000.0,
        'original_price': 1250000.0,
        'image_url': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800&auto=format&fit=crop&q=80',
        'badge': 'Best Seller',
        'rating': 4.9,
        'review_count': 210,
        'description': 'Ngăn chứa giày tách biệt bên dưới, chống thấm nước, nhiều ngăn phụ tiện ích đi tập hoặc đi du lịch.',
        'images_json': jsonEncode([
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800&auto=format&fit=crop&q=80',
        ]),
        'category': 'Phụ kiện thể thao',
        'category_id': 'cat_accessories',
        'stock': 40,
        'sizes_json': jsonEncode(['Free Size']),
        'colors_json': jsonEncode([0xFF1A1A1A, 0xFFFF6B00]),
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final prod in products) {
      batch.insert('products', prod);
    }

    // 4. Seed Product Ratings
    batch.insert('product_ratings', {
      'id': 'rate_01',
      'product_id': 'prod_01',
      'user_id': '1',
      'user_name': 'Nguyễn Văn A',
      'rating': 5,
      'comment': 'Giày đi rất êm và nhẹ chân, giao hàng đúng hẹn!',
      'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    });
    batch.insert('product_ratings', {
      'id': 'rate_02',
      'product_id': 'prod_01',
      'user_id': '2',
      'user_name': 'Nguyễn Văn B',
      'rating': 5,
      'comment': 'Màu cam rất đẹp, chuẩn thể thao tươi mới.',
      'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    });

    // 5. Seed Vouchers
    final vouchers = [
      {
        'id': 'vch_01',
        'code': 'FREESHIP',
        'title': 'Miễn phí vận chuyển toàn quốc',
        'description': 'Giảm 30.000 ₫ phí ship cho đơn từ 500.000 ₫',
        'type': 'freeshipping',
        'discount_value': 30000.0,
        'min_order_value': 500000.0,
        'max_discount_amount': 30000.0,
        'start_date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'end_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'is_used': 0,
      },
      {
        'id': 'vch_02',
        'code': 'SPORT20',
        'title': 'Giảm 20% cho đơn hàng thể thao',
        'description': 'Giảm 20% tối đa 150.000 ₫ cho toàn bộ đơn hàng',
        'type': 'percentage',
        'discount_value': 20.0,
        'min_order_value': 1000000.0,
        'max_discount_amount': 150000.0,
        'start_date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'end_date': DateTime.now().add(const Duration(days: 20)).toIso8601String(),
        'is_used': 0,
      },
      {
        'id': 'vch_03',
        'code': 'WELCOME50',
        'title': 'Chào bạn mới giảm ngay 50.000 ₫',
        'description': 'Dành riêng cho khách hàng đăng ký mới',
        'type': 'fixedamount',
        'discount_value': 50000.0,
        'min_order_value': 300000.0,
        'max_discount_amount': 50000.0,
        'start_date': DateTime.now().toIso8601String(),
        'end_date': DateTime.now().add(const Duration(days: 60)).toIso8601String(),
        'is_used': 0,
      },
    ];

    for (final vch in vouchers) {
      batch.insert('vouchers', vch);
    }

    // 6. Seed Shipping Address
    batch.insert('shipping_addresses', {
      'id': 'addr_01',
      'user_id': '1',
      'recipient_name': 'Nguyễn Văn A',
      'phone_number': '0901234567',
      'province': 'TP. Hồ Chí Minh',
      'district': 'Quận 1',
      'ward': 'Phường Bến Nghé',
      'street_address': '123 Đường Lê Lợi',
      'label': 'home',
      'is_default': 1,
    });

    await batch.commit(noResult: true);
  }
}
