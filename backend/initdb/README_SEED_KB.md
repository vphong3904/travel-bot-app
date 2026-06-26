# Seed Files — Knowledge Base Import

## Thứ tự chạy (sau schema files 00–06)

| File | Nội dung | Records |
|------|----------|---------|
| `10_seed_auth.sql` | Users mẫu | — |
| `11_seed_categories_destinations.sql` | Cũ (đã comment out) | — |
| `20_seed_destinations_full.sql` | **35 destinations + 85 sub-locations + categories** | 35 dest |
| `21_seed_hotels_full.sql` | Khách sạn / resort | 61 |
| `22_seed_tours_tickets_full.sql` | Tour du lịch | 42 |
| `23_seed_foods_restaurants_full.sql` | Món ăn (77) + Nhà hàng (47) | 124 |
| `24_seed_transport_full.sql` | Phương tiện di chuyển | 117 |
| `25_seed_events_shopping_full.sql` | Lễ hội (44) + Mua sắm (45) | 89 |
| `26_seed_knowledge_entries_full.sql` | **RAG knowledge entries** | **255** |

## Nguồn dữ liệu
- `knowledge-base/*/city.json` → destinations
- `knowledge-base/*/destinations.json` → locations
- `knowledge-base/*/hotels.json` → hotels
- `knowledge-base/*/tours.json` → tours
- `knowledge-base/*/foods.json` + `restaurants.json` → foods/restaurants
- `knowledge-base/*/transport.json` → transport_options
- `knowledge-base/*/events.json` + `shopping.json` → events/shopping
- `knowledge-base/*/experiences.md` + `faq.md` → knowledge_entries (RAG)

## Lưu ý
- File 26 tự động queue embedding_jobs cho tất cả entries với `source='kb_import'`
- Các file dùng `ON CONFLICT ... DO UPDATE` nên có thể chạy lại an toàn (idempotent)
- Mapping tỉnh cũ → mới: `app/data/city_slug_alias.json` (63 city slugs, 34 tỉnh mới)
- `city_slug_display_name.json` map slug → tên tỉnh mới hiển thị cho user
