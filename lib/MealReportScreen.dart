import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:nhakhach/Common/notification_center.dart';
import 'package:nhakhach/Data/DataModel.dart';
import 'package:nhakhach/RequestMealScreen.dart';

import 'Common/OverlayLoadingProgress.dart';
import 'Data/APIManager.dart';
import 'Data/Constants.dart';
import 'Data/Functions.dart';


class MealReportScreen extends StatefulWidget {

  @override
  State<MealReportScreen> createState() => _MealReportScreenState();
}

class _MealReportScreenState extends State<MealReportScreen> {
  List<MealReportModel> listMealReport = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NotificationCenter().subscribe("reloadListMeal", (data){
      OverlayLoadingProgress.start(context);
      loadData();
    });
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      OverlayLoadingProgress.start(context);
      loadData();
    });
  }

  void loadData() {
    APIManager().getMealReports(context, DateFormat('yyyy-MM-dd').format(DateTime.now()), (data) {
      OverlayLoadingProgress.stop();
      if (countListObject(data) > 0) {
        setState(() {
          listMealReport = data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RequestMealScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("Báo ăn"),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: ListView.separated(
            separatorBuilder: ( context, index){
              return Divider(thickness: 0.2,);
            },
            shrinkWrap: true,
            itemCount: listMealReport.length,
            itemBuilder: (_, index) {
              MealReportModel reportModel = listMealReport[index];
              return MealItem(reportModel: reportModel);
          }),
        )
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
  final MealReportModel reportModel;

  const MealItem({
    super.key,
    required this.reportModel,
  });

  String convertMeal () {
    if (reportModel.meal == kMealBreakfast) {
      return "Sáng";
    } else if (reportModel.meal == kMealLunch) {
      return "Trưa";
    } else {
      return "Tối";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RequestMealScreen(mealReportModel: reportModel,),
          ),
        );
      },
      child: Container(
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
                       Text(
                        reportModel.username,
                        style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text('Số lượng: ${reportModel.quantity} • Bữa: ${convertMeal()}'),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(DateFormat("dd/MM/yyyy").format(reportModel.reportedAt)),
                    const SizedBox(height: 6),
                    _statusBadge(),
                  ],
                ),
              ],
            ),
            if (!stringEmpty(reportModel.rejectReason)) ...[
              const SizedBox(height: 8),
              Text(
                reportModel.rejectReason,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            if (countListObject(reportModel.histories) > 0)...[
              const SizedBox(height: 8),
              Text(
                reportModel.histories.last.content,
                style: const TextStyle(color: Colors.grey),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _statusBadge() {
    switch (reportModel.status) {
      case kStatusPending:
        return _badge('Chờ duyệt', Colors.orange.shade100, Colors.orange);
      case kStatusAccepted:
        return _badge('Đã duyệt', Colors.green.shade100, Colors.green);
      default :
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
