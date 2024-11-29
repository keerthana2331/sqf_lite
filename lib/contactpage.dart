import 'package:flutter/material.dart';
import 'dart:async'; // For periodic updates.

import 'db_helper.dart';
import 'contact.dart';

class AddEditContactPage extends StatefulWidget {
  final Contact? contact;

  const AddEditContactPage({Key? key, this.contact}) : super(key: key);

  @override
  AddEditContactPageState createState() => AddEditContactPageState();
}

class AddEditContactPageState extends State<AddEditContactPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final DBHelper dbHelper = DBHelper();

  List<List<Color>> gradientColors = [
    [Colors.teal, Colors.blue],
    [Colors.purple, Colors.pink],
    [Colors.orange, Colors.red],
  ];
  int currentGradientIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      nameController.text = widget.contact!.name;
      phoneController.text = widget.contact!.phone;
    }
    startGradientAnimation();
  }

  void startGradientAnimation() {
    Timer.periodic(Duration(seconds: 4), (timer) {
      setState(() {
        currentGradientIndex = (currentGradientIndex + 1) % gradientColors.length;
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void saveContact() async {
    if (formKey.currentState!.validate()) {
      final contact = Contact(
        id: widget.contact?.id,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );

      if (widget.contact == null) {
        await dbHelper.addContact(contact);
      } else {
        await dbHelper.updateContact(contact);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(seconds: 4),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors[currentGradientIndex],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              AppBar(
                title: Text(
                  widget.contact == null ? 'Add Contact' : 'Edit Contact',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.contact == null
                          ? 'Create New Contact'
                          : 'Update Contact Details',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(color: Colors.white70, fontSize: 16),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70, width: 2.0),
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.white),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a name' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(color: Colors.white70, fontSize: 16),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70, width: 2.0),
                        ),
                        prefixIcon: Icon(Icons.phone, color: Colors.white),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter a phone number';
                        if (value.length != 10) return 'Phone number must be 10 digits';
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: saveContact,
                            icon: Icon(
                              widget.contact == null ? Icons.add : Icons.update,
                              size: 20,
                            ),
                            label: Text(
                              widget.contact == null
                                  ? 'Save Contact'
                                  : 'Update Contact',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.teal,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        if (widget.contact != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.cancel, color: Colors.white, size: 20),
                              label: Text(
                                'Cancel',
                                style: TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (widget.contact != null)
                      Align(
                        alignment: Alignment.center,
                        child: TextButton.icon(
                          onPressed: () => Navigator.pop(context, 'delete'),
                          icon: Icon(Icons.delete, color: Colors.red),
                          label: Text(
                            'Delete Contact',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
