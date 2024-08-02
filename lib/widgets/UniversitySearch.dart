import 'package:flutter/material.dart';


//위젯 임포트
import 'package:amtt/widgets/RoundedTextField.dart';


class UniversitySearch extends StatelessWidget {
  final TextEditingController controller;
  final List<String> filteredUnivNames;
  final Function(String) onUniversitySelected;

  const UniversitySearch({
    Key? key,
    required this.controller,
    required this.filteredUnivNames,
    required this.onUniversitySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 50,
          child: RoundedTextField(
            labelText: '대학 검색',
            controller: controller,
            obscureText: false,
          ),
        ),
        if (controller.text.isNotEmpty && filteredUnivNames.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8),
            constraints: BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredUnivNames.length > 5 ? 5 : filteredUnivNames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredUnivNames[index]),
                  onTap: () => onUniversitySelected(filteredUnivNames[index]),
                );
              },
            ),
          ),
      ],
    );
  }
}