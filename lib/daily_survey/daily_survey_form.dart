import 'package:carbon_tracker/daily_survey/daily_survey.dart';
import 'package:carbon_tracker/daily_survey/daily_survey_food_types.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../homepage.dart';

class DailySurveyPage extends StatelessWidget {
  const DailySurveyPage({Key? key, required this.date}) : super(key: key);
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${DateFormat.yMd().format(date)} Survey',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          title: Text('${DateFormat.yMd().format(date)} Survey'),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            ),
          ),
        ),
        body: Center(
            child: Padding(
                child: DailySurveyForm(date: date), padding: const EdgeInsets.all(32.0))),
      ),
    );
  }
}

class DailySurveyForm extends StatefulWidget {
  const DailySurveyForm({Key? key, required this.date}) : super(key: key);
  final DateTime date;

  @override
  State<StatefulWidget> createState() => _DailySurveyFormState(date);
}

class _DailySurveyFormState extends State<DailySurveyForm> {
  final _formKey = GlobalKey<FormState>();
  final _foods = <String, int>{};
  final DateTime date;

  _DailySurveyFormState(this.date);

  List<Widget> createFoodTypeWidgets() {
    List<Widget> list = [];
    for (var foodType in FoodType.foodTypes) {
      list.add(CounterFormField(
          title:
              "Servings of ${foodType.displayName} (${foodType.servingSize})",
          onSaved: (food) => _foods[foodType.displayName] = food!,
          validator: (value) {
            return (value! < 0) ? "Must be a positive value" : null;
          }));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = createFoodTypeWidgets();
    widgetList.add(ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          var daily = Hive.box('daily');
          daily.put(
              date.toIso8601String(),
              DailySurvey(
                _foods, calculateCarbonEmissions(_foods)
              ));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      },
      child: const Text('Submit'),
    ));

    return Form(
      key: _formKey,
      child: Column(
        children: widgetList,
      ),
    );
  }
}

class CounterFormField extends FormField<int> {
  CounterFormField(
      {Key? key,
      required String title,
      required FormFieldSetter<int> onSaved,
      required FormFieldValidator<int> validator,
      int initialValue = 0})
      : super(
            key: key,
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<int> state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(title),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          state.didChange(state.value! - 1);
                        },
                      ),
                      Text(state.value.toString()),
                      IconButton(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          state.didChange(state.value! + 1);
                        },
                      ),
                    ],
                  ),
                  state.hasError
                      ? Text(state.errorText!,
                          style: const TextStyle(color: Colors.red))
                      : Container()
                ],
              );
            });
}

double calculateCarbonEmissions(Map<String, int> foods) {
  double total = 0;
  for (var food in foods.entries) {
    total += FoodType.getFoodType(food.key).carbonPerServing * food.value;
  }
  return total;
}
