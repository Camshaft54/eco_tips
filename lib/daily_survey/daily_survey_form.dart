import 'package:carbon_tracker/daily_survey/daily_survey.dart';
import 'package:carbon_tracker/daily_survey/daily_survey_food_types.dart';
import 'package:carbon_tracker/settings/transport_type.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../homepage.dart';

class DailySurveyPage extends StatelessWidget {
  const DailySurveyPage({Key? key, required this.date}) : super(key: key);
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('${DateFormat.yMd().format(date)} Survey'),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)
          ),
          actions: [
            buildHelpButton(
                context: context,
                alertTitle: "Daily Survey",
                description:
                    "Food Options: Select how many servings of each entry on the list you consumed that day. If an item is not listed, select the choice that best matches your item. You do not need to include items like fruits and vegetables, since they usually have lower carbon emissions.\n\n"
                    "Transportation: Select whether or not you commuted that day. This will use data from your transportation settings. If you travelled outside of your commute using the commute option from your transportation settings, enter how many additional miles you travelled.")
          ]),
      body: Center(
          child: Padding(
              child: DailySurveyForm(date: date),
              padding: const EdgeInsets.symmetric(
                  vertical: 16.0, horizontal: 10.0))),
    );
  }
}

class DailySurveyForm extends StatefulWidget {
  const DailySurveyForm({Key? key, required this.date}) : super(key: key);
  final DateTime date;

  @override
  State<StatefulWidget> createState() => _DailySurveyFormState();
}

class _DailySurveyFormState extends State<DailySurveyForm> {
  final _formKey = GlobalKey<FormState>();
  final _foods = <String, int>{};
  final commuteButtonSelections = [false, true];
  final additionalTravelController = TextEditingController();

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
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          ...createFoodTypeWidgets(),
          const Text(
              "Did you commute today? (uses transportation settings data)"),
          ToggleButtons(
              children: const [Text("Yes"), Text("No")],
              isSelected: commuteButtonSelections,
              onPressed: (index) {
                setState(() {
                  commuteButtonSelections[index] = true;
                  commuteButtonSelections[(index + 1) % 2] = false;
                });
              }),
          TextFormField(
              controller: additionalTravelController,
              decoration: const InputDecoration(
                  labelText: "Additional miles travelled (optional)"),
              validator: (text) {
                if (text != null &&
                    text.isNotEmpty &&
                    double.tryParse(text) == null) {
                  return "Must be a number or left blank";
                }
              }),
          buildSurveyButton(
            "Submit",
            includePadding: false,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                var transportBox = Hive.box("transport");
                TransportType transportType = transportBox.getAt(0);
                double commuteDistance = (commuteButtonSelections[0])
                    ? transportType.emissionsPerMile *
                        transportType.commuteDistance
                    : 0;
                double? additionalTravelDistance =
                    double.tryParse(additionalTravelController.text);
                double additionalTravelEmissions = (additionalTravelDistance !=
                        null)
                    ? additionalTravelDistance * transportType.emissionsPerMile
                    : 0;

                var dailySurvey = DailySurvey(
                    _foods, commuteDistance, additionalTravelEmissions);
                dailySurvey.totalEmissions = calculateCarbonEmissions(
                    dailySurvey, transportType.emissionsPerMile);

                var daily = Hive.box('daily');
                daily.put(widget.date.toIso8601String(), dailySurvey);

                Navigator.pop(context);
              }
            },
          )
        ],
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

double calculateCarbonEmissions(DailySurvey survey, double emissionsPerMile) {
  var foods = survey.foodTypes;
  double total = 0;
  for (var food in foods.entries) {
    total += FoodType.getFoodType(food.key).carbonPerServing * food.value;
  }
  total += survey.commuteDistance * emissionsPerMile;
  total += survey.emissionsFromAdditionalTravel;
  return total;
}
