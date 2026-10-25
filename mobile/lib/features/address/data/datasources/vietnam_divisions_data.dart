class ProvinceData {
  final String name;
  final List<DistrictData> districts;

  const ProvinceData({required this.name, required this.districts});
}

class DistrictData {
  final String name;
  final List<String> wards;

  const DistrictData({required this.name, required this.wards});
}

class VietnamAdministrativeData {
  VietnamAdministrativeData._();

  static const List<ProvinceData> provinces = [
    ProvinceData(
      name: 'TP. Hồ Chí Minh',
      districts: [
        DistrictData(
          name: 'Quận 1',
          wards: [
            'Phường Bến Nghé',
            'Phường Bến Thành',
            'Phường Cầu Kho',
            'Phường Cầu Ông Lãnh',
            'Phường Cô Giang',
            'Phường Đa Kao',
            'Phường Nguyễn Cư Trinh',
            'Phường Nguyễn Thái Bình',
            'Phường Phạm Ngũ Lão',
            'Phường Tân Định',
          ],
        ),
        DistrictData(
          name: 'Quận 3',
          wards: [
            'Phường 1',
            'Phường 2',
            'Phường 3',
            'Phường 4',
            'Phường 5',
            'Phường 9',
            'Phường 11',
            'Phường 12',
            'Phường 14',
            'Phường Võ Thị Sáu',
          ],
        ),
        DistrictData(
          name: 'Quận 7',
          wards: [
            'Phường Bình Thuận',
            'Phường Phú Mỹ',
            'Phường Phú Thuận',
            'Phường Tân Hưng',
            'Phường Tân Kiểng',
            'Phường Tân Phong',
            'Phường Tân Phú',
            'Phường Tân Quy',
            'Phường Tân Thuận Đông',
            'Phường Tân Thuận Tây',
          ],
        ),
        DistrictData(
          name: 'TP. Thủ Đức',
          wards: [
            'Phường An Khánh',
            'Phường An Lợi Đông',
            'Phường An Phú',
            'Phường Bình Chiểu',
            'Phường Bình Thọ',
            'Phường Hiệp Bình Chánh',
            'Phường Hiệp Bình Phước',
            'Phường Linh Chiểu',
            'Phường Linh Đông',
            'Phường Linh Trung',
            'Phường Linh Xuân',
            'Phường Tam Bình',
            'Phường Thảo Điền',
            'Phường Tăng Nhơn Phú A',
            'Phường Tăng Nhơn Phú B',
          ],
        ),
        DistrictData(
          name: 'Quận Bình Thạnh',
          wards: [
            'Phường 1',
            'Phường 2',
            'Phường 3',
            'Phường 5',
            'Phường 7',
            'Phường 11',
            'Phường 13',
            'Phường 15',
            'Phường 19',
            'Phường 22',
            'Phường 25',
            'Phường 26',
            'Phường 27',
          ],
        ),
        DistrictData(
          name: 'Quận Tân Bình',
          wards: [
            'Phường 1',
            'Phường 2',
            'Phường 3',
            'Phường 4',
            'Phường 5',
            'Phường 7',
            'Phường 8',
            'Phường 10',
            'Phường 12',
            'Phường 13',
            'Phường 14',
            'Phường 15',
          ],
        ),
      ],
    ),
    ProvinceData(
      name: 'Hà Nội',
      districts: [
        DistrictData(
          name: 'Quận Ba Đình',
          wards: [
            'Phường Cống Vị',
            'Phường Điện Biên',
            'Phường Đội Cấn',
            'Phường Giảng Võ',
            'Phường Kim Mã',
            'Phường Liễu Giai',
            'Phường Ngọc Hà',
            'Phường Quán Thánh',
            'Phường Thành Công',
            'Phường Trúc Bạch',
          ],
        ),
        DistrictData(
          name: 'Quận Hoàn Kiếm',
          wards: [
            'Phường Cửa Đông',
            'Phường Cửa Nam',
            'Phường Đồng Xuân',
            'Phường Hàng Bạc',
            'Phường Hàng Bài',
            'Phường Hàng Bồ',
            'Phường Hàng Bông',
            'Phường Hàng Buồm',
            'Phường Hàng Đào',
            'Phường Hàng Gai',
            'Phường Hàng Mã',
            'Phường Hàng Trống',
            'Phường Lý Thái Tổ',
            'Phường Phan Chu Trinh',
            'Phường Phúc Tân',
            'Phường Tràng Tiền',
          ],
        ),
        DistrictData(
          name: 'Quận Cầu Giấy',
          wards: [
            'Phường Dịch Vọng',
            'Phường Dịch Vọng Hậu',
            'Phường Mai Dịch',
            'Phường Nghĩa Đô',
            'Phường Nghĩa Tân',
            'Phường Quan Hoa',
            'Phường Trung Hòa',
            'Phường Yên Hòa',
          ],
        ),
        DistrictData(
          name: 'Quận Đống Đa',
          wards: [
            'Phường Cát Linh',
            'Phường Hàng Bột',
            'Phường Khâm Thiên',
            'Phường Khương Thượng',
            'Phường Kim Liên',
            'Phường Láng Hạ',
            'Phường Láng Thượng',
            'Phường Nam Đồng',
            'Phường Ô Chợ Dừa',
            'Phường Phương Mai',
            'Phường Quang Trung',
            'Phường Quốc Tử Giám',
            'Phường Thịnh Quang',
            'Phường Thổ Quan',
            'Phường Trung Liệt',
            'Phường Trung Phụng',
            'Phường Trung Tự',
            'Phường Văn Chương',
            'Phường Văn Miếu',
          ],
        ),
      ],
    ),
    ProvinceData(
      name: 'Đà Nẵng',
      districts: [
        DistrictData(
          name: 'Quận Hải Châu',
          wards: [
            'Phường Hải Châu I',
            'Phường Hải Châu II',
            'Phường Thạch Thang',
            'Phường Thanh Bình',
            'Phường Thuận Phước',
            'Phường Hòa Thuận Đông',
            'Phường Hòa Thuận Tây',
            'Phường Nam Dương',
            'Phường Phước Ninh',
            'Phường Bình Thuận',
            'Phường Bình Hiên',
            'Phường Hòa Cường Bắc',
            'Phường Hòa Cường Nam',
          ],
        ),
        DistrictData(
          name: 'Quận Sơn Trà',
          wards: [
            'Phường An Hải Bắc',
            'Phường An Hải Đông',
            'Phường An Hải Tây',
            'Phường Mân Thái',
            'Phường Nại Hiên Đông',
            'Phường Phước Mỹ',
            'Phường Thọ Quang',
          ],
        ),
        DistrictData(
          name: 'Quận Ngũ Hành Sơn',
          wards: [
            'Phường Mỹ An',
            'Phường Khuê Mỹ',
            'Phường Hòa Quý',
            'Phường Hòa Hải',
          ],
        ),
      ],
    ),
    ProvinceData(
      name: 'Cần Thơ',
      districts: [
        DistrictData(
          name: 'Quận Ninh Kiều',
          wards: [
            'Phường An Bình',
            'Phường An Cư',
            'Phường An Hòa',
            'Phường An Khánh',
            'Phường An Nghiệp',
            'Phường Cái Khế',
            'Phường Hưng Lợi',
            'Phường Tân An',
            'Phường Thới Bình',
            'Phường Xuân Khánh',
          ],
        ),
        DistrictData(
          name: 'Quận Cái Răng',
          wards: [
            'Phường Ba Láng',
            'Phường Hưng Phú',
            'Phường Hưng Thạnh',
            'Phường Lê Bình',
            'Phường Phú Thứ',
            'Phường Tân Phú',
            'Phường Yên Đỗ',
          ],
        ),
      ],
    ),
    ProvinceData(
      name: 'Hải Phòng',
      districts: [
        DistrictData(
          name: 'Quận Hồng Bàng',
          wards: [
            'Phường Hạ Lý',
            'Phường Hoàng Văn Thụ',
            'Phường Hùng Vương',
            'Phường Minh Khai',
            'Phường Phan Bội Châu',
            'Phường Quán Toan',
            'Phường Sở Dầu',
            'Phường Thượng Lý',
            'Phường Trại Chuối',
          ],
        ),
        DistrictData(
          name: 'Quận Ngô Quyền',
          wards: [
            'Phường Cầu Đất',
            'Phường Cầu Tre',
            'Phường Đằng Giang',
            'Phường Đông Khê',
            'Phường Đồng Quốc Bình',
            'Phường Gia Viên',
            'Phường Lạc Viên',
            'Phường Lạch Tray',
            'Phường Lê Lợi',
            'Phường Máy Chai',
            'Phường Máy Tơ',
            'Phường Vạn Mỹ',
          ],
        ),
      ],
    ),
    ProvinceData(
      name: 'Bình Dương',
      districts: [
        DistrictData(
          name: 'TP. Thủ Dầu Một',
          wards: [
            'Phường Chánh Mỹ',
            'Phường Chánh Nghĩa',
            'Phường Định Hòa',
            'Phường Hiệp An',
            'Phường Hiệp Thành',
            'Phường Hòa Phú',
            'Phường Phú Cường',
            'Phường Phú Hòa',
            'Phường Phú Lợi',
            'Phường Phú Mỹ',
            'Phường Phú Tân',
            'Phường Phú Thọ',
            'Phường Tân An',
            'Phường Tương Bình Hiệp',
          ],
        ),
        DistrictData(
          name: 'TP. Thuận An',
          wards: [
            'Phường An Phú',
            'Phường An Thạnh',
            'Phường Bình Chuẩn',
            'Phường Bình Hòa',
            'Phường Bình Nhâm',
            'Phường Hưng Định',
            'Phường Lái Thiêu',
            'Phường Thuận Giao',
            'Phường Vĩnh Phú',
            'Xã An Sơn',
          ],
        ),
      ],
    ),
  ];
}
