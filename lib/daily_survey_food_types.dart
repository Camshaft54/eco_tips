class FoodType {
  final String displayName; // Must be unique to other food types
  final String servingSize; // Cannot change after app is first released otherwise old data will be wrong
  final double carbonPerServing;

  const FoodType(this.displayName, this.servingSize, this.carbonPerServing);

  @override
  toString() => "$displayName: $servingSize, $carbonPerServing";

  static const FoodType beef = FoodType("Beef", "4 oz", 3.0617487);
  static const FoodType lamb = FoodType("Lamb", "4 oz", 4.44520552);
  static const FoodType pork = FoodType("Pork", "4 oz", 1.37211701);
  static const FoodType chicken = FoodType("Chicken", "4 oz", 0.78244689);
  static const FoodType salmon = FoodType("Salmon", "4 oz", 1.34943739);
  static const FoodType fish = FoodType("Other Fish", "4 oz", 1.53087435);
  static const FoodType eggs = FoodType("Eggs", "4 oz", 0.54431088);
  static const FoodType milk = FoodType("Milk", "4 oz", 0.120428782);
  static const FoodType cheese = FoodType("Cheese", "4 oz", 1.53087435);
  static const List<FoodType> foodTypes = [
    beef,
    lamb,
    pork,
    chicken,
    salmon,
    fish,
    eggs,
    milk,
    cheese
  ];

  // TODO: It would be good to overhaul this so that the food type info is included in the database
  static FoodType getFoodType(String displayName) {
    for (FoodType food in foodTypes) {
      if (food.displayName == displayName) {
        return food;
      }
    }
    throw Exception("Could not find food type matching $displayName");
  }
}
