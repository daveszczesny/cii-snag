import 'package:cii/controllers/company_controller.dart';
import 'package:cii/models/company.dart';
import 'package:cii/view/utils/image.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CompanyCreate extends StatefulWidget {
  final VoidCallback onChange;
  const CompanyCreate({super.key, required this.onChange});

  @override
  State<CompanyCreate> createState() => _CompanyCreateState();
}

class _CompanyCreateState extends State<CompanyCreate> {
  late CompanyController companyController;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressControler = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController sloganController = TextEditingController();

  String logoPath = '';

  @override
  void initState() {
    super.initState();
    companyController = CompanyController(Hive.box<Company>('companies'));
  }

  void createCompany() {
    final String name = nameController.text;
    final String address = addressControler.text;
    final String phone = phoneController.text;
    final String email = emailController.text;
    final String website = websiteController.text;
    final String slogan = sloganController.text;
    final String logo = logoPath;

    companyController.createCompany(
      name: name,
      address: address,
      phone: phone,
      email: email,
      website: website,
      logoPath: logo,
      slogan: slogan,
    );
  }

  void onChange() {
    setState((){});
  }

  void onClick() {
    if (nameController.text.isEmpty) {
      // show an alert that the user must add a name
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Missing information'),
            content: const Text('Please fill out all required fields'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
            ],
          );
        }
      );
    }
    createCompany();
    widget.onChange();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Company'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextInput('Company Name', 'Ex. Emico', nameController, optional: false),
              const SizedBox(height: 28),
              buildLongTextInput('Company Address', 'Ex. Unit 123, London', addressControler),
              const SizedBox(height: 28),
              buildTextInput('Company Phone', 'Ex. +1 300 555 232', phoneController),
              const SizedBox(height: 28),
              buildTextInput('Company Email', 'Ex. mycompany@company.com', emailController),
              const SizedBox(height: 28),
              buildTextInput('Company Website', 'Ex. www.company.com', websiteController),
              const SizedBox(height: 28),
              buildLongTextInput('Slogan', 'Ex. Just do it', sloganController),
              const SizedBox(height: 28),
              buildImageInputForSingleImage('Upload Company Logo', context, logoPath, onChange),
              const SizedBox(height: 28),
              buildTextButton('Create Company', onClick)
            ],
          )
          
        )
      )
    );
  }
}