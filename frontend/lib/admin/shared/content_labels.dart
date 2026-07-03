// lib/admin/shared/content_labels.dart
//
// Từ điển dịch nhãn code (giá trị thô tiếng Anh trong data) → tiếng Việt, dùng
// để HIỂN THỊ ở bảng content + dropdown form. KHÔNG đổi data trong DB.
//
// 👉 Bạn chỉnh tay thoải mái: thêm/sửa cặp 'code': 'Tiếng Việt' bên dưới.
//    Key so khớp không phân biệt hoa thường. Giá trị không có trong map sẽ
//    được giữ nguyên (không dịch).

const Map<String, String> kContentLabels = {
  // ── Loại địa điểm (destinations/locations.type) ─────────────────────────────
  'attraction': 'Điểm tham quan',
  'nature': 'Thiên nhiên',
  'mountain': 'Núi / Đồi',
  'beach': 'Bãi biển',
  'museum': 'Bảo tàng',
  'temple': 'Đền / Chùa',
  'entertainment': 'Giải trí',
  'amusement_park': 'Công viên giải trí',
  'theme_park': 'Công viên chủ đề',
  'water_park': 'Công viên nước',
  'aquarium': 'Thủy cung',
  'zoo': 'Vườn thú',
  'kids_zone': 'Khu vui chơi trẻ em',
  'cultural_village': 'Làng văn hóa',
  'culture': 'Văn hóa',
  'heritage': 'Di sản',
  'border_crossing': 'Cửa khẩu',

  // ── Ẩm thực (foods.category → 'type') ───────────────────────────────────────
  'main_dish': 'Món chính',
  'dessert': 'Tráng miệng',
  'drink': 'Đồ uống',
  'beverage': 'Đồ uống',
  'snack': 'Ăn vặt',
  'specialty': 'Đặc sản',
  'seafood': 'Hải sản',
  'noodle': 'Món sợi (bún/phở/mì)',
  'soup': 'Món canh / súp',
  'beef': 'Món bò',
  'fruit': 'Trái cây',
  'condiment': 'Gia vị',

  // ── Nhà hàng (restaurants.type → 'cuisine_type') ────────────────────────────
  'cafe': 'Quán cà phê',
  'restaurant': 'Nhà hàng',
  'street_food': 'Ăn đường phố',
  'market_stall': 'Quầy chợ',

  // ── Mua sắm (shopping.type → 'goods_type') ──────────────────────────────────
  'mall': 'Trung tâm thương mại',
  'market': 'Chợ',
  'specialty_store': 'Cửa hàng đặc sản',
  'street': 'Phố mua sắm',
  'other': 'Khác',

  // ── Loại tour (tours group type) ────────────────────────────────────────────
  'couple': 'Cặp đôi',
  'family': 'Gia đình',
  'solo': 'Một mình',
  'group': 'Nhóm',

  // ── Phương tiện (transport_options.type → 'vehicle') ────────────────────────
  'airplane': 'Máy bay',
  'flight': 'Chuyến bay',
  'bicycle': 'Xe đạp',
  'boat': 'Thuyền',
  'boat_ferry': 'Phà / Thuyền',
  'ferry': 'Phà',
  'cruise_boat': 'Du thuyền',
  'bus': 'Xe buýt',
  'bus_combined': 'Xe buýt (kết hợp)',
  'bus_noi_dao': 'Xe buýt nội đảo',
  'car': 'Ô tô',
  'car_rental': 'Thuê ô tô',
  'private_car': 'Xe riêng',
  'electric_car': 'Xe điện',
  'motorbike': 'Xe máy',
  'motorbike_rental': 'Thuê xe máy',
  'motorbike_or_car': 'Xe máy / Ô tô',
  'grab': 'Grab',
  'taxi': 'Taxi',
  'taxi_grab': 'Taxi / Grab',
  'train': 'Tàu hỏa',
  'walking': 'Đi bộ',
  'xe_om': 'Xe ôm',
  'xe_dien_golf': 'Xe điện (sân golf)',
};

/// Dịch 1 giá trị code sang tiếng Việt để hiển thị. Không có trong từ điển →
/// giữ nguyên. Rỗng/null → '—'.
String vnLabel(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '—';
  return kContentLabels[raw.toLowerCase().trim()] ?? raw;
}
