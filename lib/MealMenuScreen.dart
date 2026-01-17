import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:nhakhach/Common/notification_center.dart';
import 'package:nhakhach/Data/DataManager.dart';
import 'package:nhakhach/Data/DataModel.dart';
import 'package:nhakhach/RequestMealScreen.dart';
import 'Common/OverlayLoadingProgress.dart';
import 'Data/APIManager.dart';
import 'Data/Constants.dart';
import 'Data/Functions.dart';


class MealMenuScreen extends StatefulWidget {

  @override
  State<MealMenuScreen> createState() => _MealMenuScreenState();
}

class _MealMenuScreenState extends State<MealMenuScreen> {
  List<MenuModel> listMenuMeal = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      OverlayLoadingProgress.start(context);
      loadData();
    });
  }

  void loadData() {
    APIManager().getAllMenus(context, DateFormat('yyyy-MM-dd').format(DateTime.now()), (data) {
      OverlayLoadingProgress.stop();
      if (countListObject(data) > 0) {
        setState(() {
          listMenuMeal = data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thực phẩm hàng ngày"),
        actions: [
          IconButton(onPressed: (){
            setState(() {
              listMenuMeal.clear();
            });
            OverlayLoadingProgress.start(context);
            loadData();
          }, icon: Icon(Icons.refresh))
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          itemCount: listMenuMeal.length,
          itemBuilder: (_, index) {
            MenuModel menu = listMenuMeal[index];
            return MenuInfoWidget(menu: menu);
        })
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

class MenuInfoWidget extends StatelessWidget {
  final MenuModel menu;

  const MenuInfoWidget({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 12),
            _summary(),
            const Divider(height: 24),
            _foodList(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          convertMeal(menu.meal),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          _formatDate(menu.menuDate),
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _summary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _infoItem('Tổng tiền', '${formatNumber(menu.totalCost)} VNĐ'),
        // _infoItem('Calories', '${menu.totalCalories.toStringAsFixed(0)} kcal'),
      ],
    );
  }

  Widget _infoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _foodList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh sách món ăn',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: menu.foods.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final food = menu.foods[index];
            return _foodItem(food);
          },
        ),
      ],
    );
  }

  Widget _foodItem(FoodModel food) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                food.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              // Text(
              //   '${food.quantity} ${food.unit} • ${food.calories.toStringAsFixed(0)} kcal',
              //   style: const TextStyle(color: Colors.grey),
              // ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${formatNumber(food.price)} VNĐ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            // Text(
            //   'P:${food.protein} C:${food.carbs} F:${food.fat}',
            //   style: const TextStyle(fontSize: 12, color: Colors.grey),
            // ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
