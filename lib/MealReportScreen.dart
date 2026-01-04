import 'package:flutter/material.dart';

import 'Data/Constants.dart';


class MealReportScreen extends StatelessWidget {
  const MealReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Báo ăn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            FilterCard(),
            SizedBox(height: 16),
            MealItem(
              status: MealStatus.pending,
              quantity: 45,
              meal: 'Trưa',
              note: 'Cần xác nhận lại số lượng',
            ),
            MealItem(
              status: MealStatus.approved,
              quantity: 32,
              meal: 'Sáng',
            ),
            MealItem(
              status: MealStatus.rejected,
              quantity: 32,
              meal: 'Sáng',
              note: 'Lý do từ chối: báo trễ giờ',
            ),
          ],
        ),
      ),
    );
  }
}

class FilterCard extends StatelessWidget {
  const FilterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.filter_alt_outlined),
              SizedBox(width: 8),
              Text(
                'Bộ lọc',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _input('Tìm theo thời gian (vd:)'),
              const SizedBox(width: 12),
              _input('Tên xí nghiệp'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _dropdown('Tất cả bữa'),
              const SizedBox(width: 12),
              _dropdown('Tất cả trạng thái'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _input(String hint) {
    return Expanded(
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          isDense: true,
        ),
      ),
    );
  }

  Widget _dropdown(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}

class MealItem extends StatelessWidget {
  final MealStatus status;
  final int quantity;
  final String meal;
  final String? note;

  const MealItem({
    super.key,
    required this.status,
    required this.quantity,
    required this.meal,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFEAF2FF),
                child: Icon(Icons.factory, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Xí nghiệp A',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text('Số lượng: $quantity • Bữa: $meal'),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('14/10/2025'),
                  const SizedBox(height: 6),
                  _statusBadge(),
                ],
              ),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 8),
            Text(
              note!,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge() {
    switch (status) {
      case MealStatus.pending:
        return _badge('Chờ duyệt', Colors.orange.shade100, Colors.orange);
      case MealStatus.approved:
        return _badge('Đã duyệt', Colors.green.shade100, Colors.green);
      case MealStatus.rejected:
        return _badge('Từ chối', Colors.red.shade100, Colors.red);
    }
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
