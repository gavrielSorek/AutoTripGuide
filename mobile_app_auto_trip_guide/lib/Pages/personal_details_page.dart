import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Map/globals.dart';
import '../Map/types.dart';
import 'account_page.dart';

class PersonalDetailsPage extends StatelessWidget {
  PersonalDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserInfo userInfo =
        Globals.globalUserInfoObj ?? UserInfo("", "", "", "", "", [""]);

    return Scaffold(
      appBar: buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 15),
          ProfileWidget(
            imagePath:
                Globals.globalController.googleAccount.value?.photoUrl ?? "",
            onClicked: () async {},
          ),
          const SizedBox(height: 15),
          buildName(userInfo),
          const SizedBox(height: 15),
          TextFieldWidget(
            label: 'Full Name',
            text: userInfo.name ?? '',
            isEdit: true,
            onChanged: (name) {
              Globals.globalUserInfoObj?.name = name;
            },
          ),
          const SizedBox(height: 15),
          TextFieldWidget(
            label: 'Email',
            text: userInfo.emailAddr ?? '',
            isEdit: false,
            onChanged: (email) {},
          ),
          const SizedBox(height: 15),
          const Text(
            'Gender',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          DropDownWidget(const <String>['Men', 'Women', ' '], userInfo.gender,
              (String newVal) {
            Globals.globalUserInfoObj?.gender = newVal;
          }),
          const SizedBox(height: 15),
          TextFieldWidget(
            label: 'Age',
            text: userInfo.age ?? '',
            isEdit: true,
            onChanged: (age) {
              Globals.globalUserInfoObj?.age = age;
            },
          ),
          const SizedBox(height: 15),
          const Text(
            'Language',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          DropDownWidget(const <String>['English', ' '], userInfo.languages,
                  (String newVal) {
                Globals.globalUserInfoObj?.languages = newVal;
              }),
          Container(
            margin: const EdgeInsets.only(top: 20.0),
            child: buildApplyButton(context),
          )
        ],
      ),
    );
  }

  Widget buildName(UserInfo userInfo) => Column(
        children: [
          Text(
            userInfo.name ?? '',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            userInfo.emailAddr ?? '',
            style: const TextStyle(color: Colors.grey),
          )
        ],
      );
}

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    title: const Text('Personal Detail'),
    centerTitle: true,
    leading: const BackButton(),
    elevation: 0,
  );
}

ElevatedButton buildApplyButton(BuildContext context) {
  return ElevatedButton(
    child: const Text('Apply'),
    onPressed: () {
      Globals.globalServerCommunication.updateUserInfo();
      const snackBar = SnackBar(
        content: Text('Your Personal Detail Saved!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    },
    style: ElevatedButton.styleFrom(
        primary: const Color.fromRGBO(135, 88, 244, 1.0),
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 5,
            vertical: MediaQuery.of(context).size.height / 500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
  );
}

class TextFieldWidget extends StatefulWidget {
  final int maxLines;
  final String label;
  final String text;
  final bool isEdit;
  final ValueChanged<String> onChanged;

  const TextFieldWidget({
    Key? key,
    this.maxLines = 1,
    required this.label,
    required this.text,
    required this.isEdit,
    required this.onChanged,
  }) : super(key: key);

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: widget.onChanged,
            enabled: widget.isEdit,
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: widget.maxLines,
          ),
        ],
      );
}

class DropDownWidget extends StatefulWidget {
  final List<String> dropDownList;
  final String oldValue;
  final dynamic onUpdated;

  DropDownWidget(this.dropDownList, this.oldValue, this.onUpdated, {Key? key})
      : super(key: key);

  @override
  State<DropDownWidget> createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget> {
  String? dropdownValue;

  @override
  void initState() {
    dropdownValue = widget.oldValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      elevation: 30,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 4,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue ?? ' ';
        });
        widget.onUpdated(newValue);
      },
      items: widget.dropDownList.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
