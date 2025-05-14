import 'package:cii/models/company.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CompanyController {
  final Box<Company> companyBox;

  CompanyController(this.companyBox);

  void createCompany({
    required String name,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? logoPath,
    String? slogan,
  }) {
    final company = Company(
      companyName: name,
      companyAddress: address,
      companyPhone: phone,
      companyEmail: email,
      companyWebsite: website,
      companyLogoPath: logoPath,
      companySlogan: slogan,
    );
    companyBox.add(company);
  }

  // Get one company from the box
  Company? getCompany() {
    if (companyBox.isEmpty) return null;
    return companyBox.values.first;
  }

  String getName(Company c) => c.companyName;
  String getAddress(Company c) => c.companyAddress ?? '';
  String getPhone(Company c) => c.companyPhone ?? '';
  String getEmail(Company c) => c.companyEmail ?? '';
  String getWebsite(Company c) => c.companyWebsite ?? '';
  String getLogoPath(Company c) => c.companyLogoPath ?? '';
  String getSlogan(Company c) => c.companySlogan ?? '';

  void updateCompany(Company company) {
    company.save();
  }
  void deleteCompany(Company company) {
    company.delete();
  }
  void deleteAllCompanies() {
    companyBox.clear();
  }
  List<Company> getAllCompanies() {
    return companyBox.values.toList();
  }
  void addCompany(Company company) {
    companyBox.add(company);
  }
  void updateCompanyName(Company company, String name) {
    company.companyName = name;
    company.save();
  }
  void updateCompanyAddress(Company company, String address) {
    company.companyAddress = address;
    company.save();
  }
  void updateCompanyPhone(Company company, String phone) {
    company.companyPhone = phone;
    company.save();
  }
  void updateCompanyEmail(Company company, String email) {
    company.companyEmail = email;
    company.save();
  }
  void updateCompanyWebsite(Company company, String website) {
    company.companyWebsite = website;
    company.save();
  }
  void updateCompanyLogoPath(Company company, String logoPath) {
    company.companyLogoPath = logoPath;
    company.save();
  }
  void updateCompanySlogan(Company company, String slogan) {
    company.companySlogan = slogan;
    company.save();
  }
}