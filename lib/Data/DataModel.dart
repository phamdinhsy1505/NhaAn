class UserModel {
  final int id;
  final String username;
  final String name;
  final String email;
  final String phone;
  final String role;
  final int enterpriseID;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.enterpriseID,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// FROM JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      enterpriseID: json['enterpriseID'] as int,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// TO JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'enterpriseID': enterpriseID,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class FoodModel {
  final int id;
  final String name;
  final String unit;
  final double price;
  final double protein;
  final double carbs;
  final double fat;
  final double calories;
  final double quantity;

  FoodModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
    required this.quantity,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] as int,
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      price: (json['price'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'price': price,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'calories': calories,
      'quantity': quantity,
    };
  }
}

class MenuModel {
  final int id;
  final String meal;
  final DateTime menuDate;
  final double totalCost;
  final double totalCalories;
  final DateTime createdAt;
  final List<FoodModel> foods;

  MenuModel({
    required this.id,
    required this.meal,
    required this.menuDate,
    required this.totalCost,
    required this.totalCalories,
    required this.createdAt,
    required this.foods,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] as int,
      meal: json['meal'] ?? '',
      menuDate: DateTime.parse(json['menuDate']),
      totalCost: (json['totalCost'] as num).toDouble(),
      totalCalories: (json['totalCalories'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      foods: (json['foods'] as List<dynamic>? ?? [])
          .map((e) => FoodModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal': meal,
      'menuDate': menuDate.toIso8601String(),
      'totalCost': totalCost,
      'totalCalories': totalCalories,
      'createdAt': createdAt.toIso8601String(),
      'foods': foods.map((e) => e.toJson()).toList(),
    };
  }
}

class MealReportHistoryModel {
  final int id;
  final int mealReportID;
  final int userID;
  final String content;
  final DateTime createdAt;

  MealReportHistoryModel({
    required this.id,
    required this.mealReportID,
    required this.userID,
    required this.content,
    required this.createdAt,
  });

  factory MealReportHistoryModel.fromJson(Map<String, dynamic> json) {
    return MealReportHistoryModel(
      id: json['id'] as int,
      mealReportID: json['mealReportID'] as int,
      userID: json['userID'] as int,
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealReportID': mealReportID,
      'userID': userID,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class MealReportModel {
  final int id;
  final String meal;
  final int userID;
  final String username;
  final DateTime reportDate;
  final int quantity;
  final String status;
  final String rejectReason;
  final DateTime reportedAt;
  final List<MealReportHistoryModel> histories;

  MealReportModel({
    required this.id,
    required this.username,
    required this.meal,
    required this.userID,
    required this.reportDate,
    required this.quantity,
    required this.status,
    required this.rejectReason,
    required this.reportedAt,
    required this.histories,
  });

  factory MealReportModel.fromJson(Map<String, dynamic> json) {
    return MealReportModel(
      id: json['id'] as int,
      username: json['username'] ?? "",
      meal: json['meal'] ?? '',
      userID: json['userID'] as int,
      reportDate: DateTime.parse(json['reportDate']),
      quantity: json['quantity'] as int,
      status: json['status'] ?? '',
      rejectReason: json['rejectReason'] ?? '',
      reportedAt: DateTime.parse(json['reportedAt']),
      histories: (json['histories'] as List<dynamic>? ?? [])
          .map((e) => MealReportHistoryModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal': meal,
      'userID': userID,
      'username': username,
      'reportDate': reportDate.toIso8601String(),
      'quantity': quantity,
      'status': status,
      'rejectReason': rejectReason,
      'reportedAt': reportedAt.toIso8601String(),
      'histories': histories.map((e) => e.toJson()).toList(),
    };
  }
}
