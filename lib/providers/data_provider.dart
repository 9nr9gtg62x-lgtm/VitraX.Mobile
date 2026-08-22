import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/worker.dart';
import '../models/production_order.dart';
import '../models/production_task.dart';
import '../services/api_client.dart';

/// Holds every VitraX resource the app displays and talks to the API
/// (via ApiClient) to keep them in sync. Screens read from here instead
/// of calling the API directly, so all four tabs share one cache.
class DataProvider with ChangeNotifier {
  final _api = ApiClient.instance;

  List<Product> products = [];
  List<Worker> workers = [];
  List<ProductionOrder> orders = [];
  List<ProductionTask> tasks = [];

  bool isLoading = false;
  String? error;

  String productName(int id) =>
      products.firstWhere((p) => p.productId == id, orElse: () => Product(
            productId: id, productName: '#$id', description: '', thickness: 0, size: '', imagePath: '',
          )).productName;

  String workerName(int id) =>
      workers.firstWhere((w) => w.workerId == id, orElse: () => Worker(
            workerId: id, workerName: '#$id', role: '', phone: '', imagePath: '',
          )).workerName;

  Future<void> loadAll() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _api.getList('Products'),
        _api.getList('Workers'),
        _api.getList('ProductionOrders'),
        _api.getList('ProductionTasks'),
      ]);
      products = results[0].map((e) => Product.fromJson(e)).toList();
      workers = results[1].map((e) => Worker.fromJson(e)).toList();
      orders = results[2].map((e) => ProductionOrder.fromJson(e)).toList();
      tasks = results[3].map((e) => ProductionTask.fromJson(e)).toList();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOrder(Map<String, dynamic> data) async {
    await _api.create('ProductionOrders', data);
    await loadAll();
  }

  Future<void> deleteOrder(int id) async {
    await _api.delete('ProductionOrders', id);
    orders.removeWhere((o) => o.orderId == id);
    notifyListeners();
  }

  Future<void> addWorker(Map<String, dynamic> data) async {
    await _api.create('Workers', data);
    await loadAll();
  }

  Future<void> deleteWorker(int id) async {
    await _api.delete('Workers', id);
    workers.removeWhere((w) => w.workerId == id);
    notifyListeners();
  }

  Future<void> addTask(Map<String, dynamic> data) async {
    await _api.create('ProductionTasks', data);
    await loadAll();
  }

  Future<void> deleteTask(int id) async {
    await _api.delete('ProductionTasks', id);
    tasks.removeWhere((t) => t.taskId == id);
    notifyListeners();
  }

  void reset() {
    products = [];
    workers = [];
    orders = [];
    tasks = [];
  }
}
