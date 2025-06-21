import 'dart:io';

import 'package:cii/view/utils/image.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:cii/controllers/company_controller.dart';
import 'package:cii/models/company.dart';
import 'package:hive/hive.dart';

class CompanySettings extends StatefulWidget {
  const CompanySettings({super.key});

  @override
  State<CompanySettings> createState() => _CompanySettingsState();
}

class _CompanySettingsState extends State<CompanySettings> {
  late CompanyController companyController;
  Company? company;

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();
  final sloganController = TextEditingController();

  bool isEditable = false;

  @override
  void initState() {
    super.initState();
    // You need to provide the companyController, e.g. via Provider or get_it
    companyController = CompanyController(Hive.box<Company>('companies'));
    company = companyController.getCompany();

    if (company != null) {
      nameController.text = company!.companyName;
      addressController.text = company!.companyAddress ?? '';
      phoneController.text = company!.companyPhone ?? '';
      emailController.text = company!.companyEmail ?? '';
      websiteController.text = company!.companyWebsite ?? '';
      sloganController.text = company!.companySlogan ?? '';
    }
  }

  void saveChanges() {
    if (company == null) return;
    setState(() {
      companyController.updateCompanyName(company!, nameController.text);
      companyController.updateCompanyAddress(company!, addressController.text);
      companyController.updateCompanyPhone(company!, phoneController.text);
      companyController.updateCompanyEmail(company!, emailController.text);
      companyController.updateCompanyWebsite(company!, websiteController.text);
      companyController.updateCompanySlogan(company!, sloganController.text);
      isEditable = false;
    });
  }

  Widget onDeleteLogo(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Logo'),
      content: const Text('Are you sure you want to delete this logo?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel')
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            companyController.updateCompanyLogoPath(company!, '');
            setState(() {});
          },
          child: const Text('Delete')
          )
      ]
    );
  }

  Widget companyDetailsEditable() {

    const double gap = 16;
    final String companyName = company?.companyName.isNotEmpty == true ? company!.companyName : 'XYZ Company';
    final String companyAddress = company?.companyAddress?.isNotEmpty == true ? company!.companyAddress! : 'Unit 123, London';
    final String companyPhone = company?.companyPhone?.isNotEmpty == true ? company!.companyPhone! : '+44 207 654 2198';
    final String companyEmail = company?.companyEmail?.isNotEmpty == true ? company!.companyEmail! : 'mycompany@company.com';
    final String companyWebsite = company?.companyWebsite?.isNotEmpty == true ? company!.companyWebsite! : 'www.company.com';
    final String companySlogan = company?.companySlogan?.isNotEmpty == true ? company!.companySlogan! : 'Company Slogan';
    final String logoPath = companyController.getLogoPath(company!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        if (logoPath != '' && File(logoPath).existsSync()) ... [
          buildThumbnailImageShowcase(context, logoPath, onDelete: onDeleteLogo),
          const SizedBox(height: 24)
        ] else ... [
          buildImageInput_V2(context, (v) => setState(() { companyController.updateCompanyLogoPath(company!, v); })),
          const SizedBox(height: 24)
        ],

        buildTextInput("Company", companyName, nameController),
        const SizedBox(height: gap),
        buildTextInput("Address", companyAddress, addressController),
        const SizedBox(height: gap),
        buildTextInput("Phone", companyPhone, phoneController),
        const SizedBox(height: gap),
        buildTextInput("Email", companyEmail, emailController),
        const SizedBox(height: gap),
        buildTextInput("Website", companyWebsite, websiteController),
        const SizedBox(height: gap),
        buildTextInput("Slogan", companySlogan, sloganController),
        const SizedBox(height: gap),
      ],
    );
  }

  Widget companyDetails() {

    const double gap = 16;
    final String companyName = company?.companyName.isNotEmpty == true ? company!.companyName : 'No Name';
    final String companyAddress = company?.companyAddress?.isNotEmpty == true ? company!.companyAddress! : 'No Address';
    final String companyPhone = company?.companyPhone?.isNotEmpty == true ? company!.companyPhone! : 'No Phone Number';
    final String companyEmail = company?.companyEmail?.isNotEmpty == true ? company!.companyEmail! : 'No Email';
    final String companyWebsite = company?.companyWebsite?.isNotEmpty == true ? company!.companyWebsite! : 'No Website';
    final String companySlogan = company?.companySlogan?.isNotEmpty == true ? company!.companySlogan! : 'No Slogan';
    final String logoPath = companyController.getLogoPath(company!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        if (logoPath != '' && File(logoPath).existsSync()) ... [
          buildThumbnailImageShowcase(context, logoPath, onDelete: onDeleteLogo),
          const SizedBox(height: 24)
        ],

        buildTextDetail("Company ", companyName),
        const SizedBox(height: gap),
        buildTextDetail("Address ", companyAddress),
        const SizedBox(height: gap),
        buildTextDetail("Phone ", companyPhone),
        const SizedBox(height: gap),
        buildTextDetail("Email ", companyEmail),
        const SizedBox(height: gap),
        buildTextDetail("Website ", companyWebsite),
        const SizedBox(height: gap),
        buildTextDetail("Slogan ", companySlogan),
        const SizedBox(height: gap),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    if (company == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Company Details')),
        body: const Center(child: Text('No company found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Details'),
        actions: [
          IconButton(
            icon: Icon(isEditable ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditable) {
                saveChanges();
              } else {
                setState(() {
                  isEditable = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEditable) ... [
              companyDetailsEditable()
            ] else ... [
              companyDetails(),
            ]
          ],
        ),
      ),
    );
  }
}