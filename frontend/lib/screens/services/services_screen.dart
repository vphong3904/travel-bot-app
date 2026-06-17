import 'package:flutter/material.dart';

import '../../models/service.dart';
import '../../services/service_repository.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/loading_state_widgets.dart';
import '../../widgets/service_card.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _searchCtrl = TextEditingController();

  List<Service> _allServices = [];
  List<Service> _filteredServices = [];
  bool _loading = true;
  String? _error;
  int _selectedType = 0;

  final serviceTypes = ['Tất cả', 'Khách sạn', 'Tour', 'Vé'];
  final serviceTypeValues = ['', 'hotel', 'tour', 'ticket'];

  @override
  void initState() {
    super.initState();
    _loadServices();
    _searchCtrl.addListener(() => _filterServices());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadServices({String? type}) async {
    setState(() => _loading = true);
    try {
      final services = await ServiceRepository.searchServices(type: type);
      if (!mounted) return;

      setState(() {
        _allServices = services;
        _filteredServices = services;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Lỗi khi tải dịch vụ: $e';
        _loading = false;
      });
    }
  }

  void _filterServices() {
    final query = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredServices = [..._allServices];
      } else {
        _filteredServices = _allServices.where((service) {
          final content = '${service.name} ${service.description} ${service.location}'.toLowerCase();
          return content.contains(query);
        }).toList();
      }
    });
  }

  void _selectType(int index) {
    setState(() => _selectedType = index);
    final type = serviceTypeValues[index];
    _loadServices(type: type.isEmpty ? null : type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Tra cứu dịch vụ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppSearchBar(
                controller: _searchCtrl,
                hint: 'Tìm khách sạn, tour, vé...',
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: serviceTypes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final selected = _selectedType == index;
                  return ChoiceChip(
                    label: Text(serviceTypes[index]),
                    selected: selected,
                    onSelected: (_) => _selectType(index),
                    selectedColor: AppColors.primary.withValues(alpha: 0.16),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.primary : AppColors.dark,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const LoadingScreen(message: 'Đang tải dịch vụ...')
                  : _error != null
                      ? ErrorScreen(
                          message: _error ?? 'Có lỗi xảy ra',
                          onRetry: () => _loadServices(),
                        )
                      : _filteredServices.isEmpty
                          ? EmptyScreen(
                              title: 'Không có dịch vụ',
                              message: 'Hãy thử tìm kiếm hoặc lọc khác',
                              icon: Icons.search_outlined,
                              onRetry: () => _loadServices(),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: _filteredServices.length,
                              itemBuilder: (context, index) {
                                final service = _filteredServices[index];
                                return ServiceCard(
                                  service: service,
                                  onTap: () {
                                    // Chi tiết dịch vụ - tính năng placeholder
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Chi tiết: ${service.name}')),
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

