import 'package:flutter/material.dart';

class ServicesEdit extends StatefulWidget {
  final ValueChanged<List<String>> onServiceSelected;
  const ServicesEdit({super.key, required this.onServiceSelected});

  @override
  State<ServicesEdit> createState() => _ServicesEditState();
}

class _ServicesEditState extends State<ServicesEdit> {
  final _services = [
    'Plumbing',
    'Electrical',
    'HVAC',
    'Roofing',
    'Painting',
    'Yardwork',
    'Pest',
    'Cleaning'
  ];

  List<String> _providerServices = [];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5.0,
      children: List<Widget>.generate(
        _services.length,
        (int index) {
          return ChoiceChip(
            label: Text('${_services[index]}'),
            selected: _providerServices.contains(_services[index]),
            selectedColor: Color.fromARGB(255, 212, 190, 169),
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  _providerServices.add(_services[index]);
                } else {
                  _providerServices.remove(_services[index]);
                }
                widget.onServiceSelected(_providerServices);
              });
            },
          );
        },
      ).toList(),
    );
  }
}
