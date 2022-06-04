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
          SizedBox(height: MediaQuery.of(context).size.height / 50),
          buildBackButton(context),
          SizedBox(height: MediaQuery.of(context).size.height / 50),
          ProfileWidget(
            imagePath:
                Globals.globalController.googleAccount.value?.photoUrl ?? "",
            onClicked: () async {},
          ),
          buildName(userInfo),
          SizedBox(height: MediaQuery.of(context).size.height / 60),
          TextFieldWidget(
            label: 'Full Name',
            text: userInfo.name ?? '',
            isEdit: true,
            onChanged: (name) {
              Globals.globalUserInfoObj?.name = name;
            },
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 60),
          TextFieldWidget(
            label: 'Email',
            text: userInfo.emailAddr ?? '',
            isEdit: false,
            onChanged: (email) {},
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 60),
          const Text(
            'Gender',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          DropDownWidget(const <String>['Men', 'Women', ' '], userInfo.gender,
              (String newVal) {
            Globals.globalUserInfoObj?.gender = newVal;
          }),
          SizedBox(height: MediaQuery.of(context).size.height / 60),
          TextFieldWidget(
            label: 'Age',
            text: userInfo.age ?? '',
            isEdit: true,
            onChanged: (age) {
              Globals.globalUserInfoObj?.age = age;
            },
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 60),
          const Text(
            'Language',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          DropDownWidget(const <String>['English', ' '], userInfo.languages,
                  (String newVal) {
                Globals.globalUserInfoObj?.languages = newVal;
              }),
          Container(
            margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
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
              fontWeight: FontWeight.bold, fontSize: 26, color: Colors.black87,),
          ),
          const SizedBox(height: 4),
          Text(
            userInfo.emailAddr ?? '',
            style: const TextStyle(color: Colors.black54),
          )
        ],
      );
}

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    toolbarHeight: 0.0,
    title: const Text('Personal Details'),
    centerTitle: true,
    leading: const BackButton(),
    elevation: 0,
  );
}

Container buildBackButton(BuildContext context) {
  return Container(
      height: MediaQuery.of(context).size.height / 22,
      color: Colors.transparent,
      child:
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width / 30),
            width: MediaQuery.of(context).size.width / 10,
            child: FloatingActionButton(
              backgroundColor: Globals.globalColor,
              heroTag: null,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 50),
        ],));
}

ElevatedButton buildApplyButton(BuildContext context) {
  return ElevatedButton(
    child: const Text('Apply'),
    onPressed: () {
      Globals.globalServerCommunication.updateUserInfo();
      const snackBar = SnackBar(
        content: Text('Your Personal Details Saved!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    },
    style: ElevatedButton.styleFrom(
        primary: Globals.globalColor,
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
      style: const TextStyle(color: Colors.black),
      underline: Container(
        height: 4,
        color: Globals.globalColor,
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
