import 'package:flutter/material.dart';

class PaymentChoice extends StatefulWidget {
  final ValueChanged<String> onPaymentSelected;
  const PaymentChoice({super.key, required this.onPaymentSelected});

  @override
  State<PaymentChoice> createState() => _PaymentChoiceState();
}

class _PaymentChoiceState extends State<PaymentChoice> {
  String _choosenPayment = 'Credit Card';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Color.fromARGB(255, 72, 71, 76),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            value: _choosenPayment,
            icon: Icon(Icons.keyboard_arrow_down),
            onChanged: (String? newValue) {
              setState(() {
                _choosenPayment = newValue!;
                widget.onPaymentSelected(_choosenPayment);
              });
            },
            dropdownColor: Colors.white,
            items: [
              DropdownMenuItem<String>(
                  value: 'Credit Card', child: Text('Credit Card')),
              DropdownMenuItem<String>(value: 'Visa', child: Text('Visa')),
              DropdownMenuItem<String>(value: 'QRIS', child: Text('QRIS')),
              DropdownMenuItem<String>(value: 'E-Money', child: Text('E-Money')),
            ],
          ),
        ),
      ),
    );
  }
}
