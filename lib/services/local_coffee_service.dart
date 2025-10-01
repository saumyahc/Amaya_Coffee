import 'package:hive/hive.dart';
import '../models/coffee.dart';

class LocalCoffeeService {
  static const String boxName = 'coffeesBox';

  Future<Box<Coffee>> openBox() async {
    return await Hive.openBox<Coffee>(boxName);
  }

  Future<List<Coffee>> getAllCoffees() async {
    final box = await openBox();
    return box.values.toList();
  }

  Future<void> cacheCoffees(List<Coffee> coffees) async {
    final box = await openBox();
    await box.clear();
    for (var coffee in coffees) {
      await box.put(coffee.id, coffee);
    }
  }

  Stream<List<Coffee>> watchCoffees() async* {
    final box = await openBox();
    yield box.values.toList();
    await for (var _ in box.watch()) {
      yield box.values.toList();
    }
  }
}
