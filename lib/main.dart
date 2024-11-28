import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'contact.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts Manager',
      home: ContactsPage(),
    );
  }
}

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final DBHelper _dbHelper = DBHelper();
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    final contacts = await _dbHelper.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  void _showContactDialog({Contact? contact}) {
    final TextEditingController nameController =
        TextEditingController(text: contact?.name ?? '');
    final TextEditingController phoneController =
        TextEditingController(text: contact?.phone ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(contact == null ? 'Add Contact' : 'Edit Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text;
              final phone = phoneController.text;

              if (name.isNotEmpty && phone.isNotEmpty) {
                if (contact == null) {
                  await _dbHelper.addContact(Contact(name: name, phone: phone));
                } else {
                  await _dbHelper.updateContact(
                    Contact(id: contact.id, name: name, phone: phone),
                  );
                }
                await _fetchContacts();
                Navigator.pop(context);
              }
            },
            child: Text(contact == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteContact(int id) async {
    await _dbHelper.deleteContact(id);
    await _fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contacts Manager')),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (_, index) {
          final contact = _contacts[index];
          return ListTile(
            title: Text(contact.name),
            subtitle: Text(contact.phone),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showContactDialog(contact: contact),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteContact(contact.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showContactDialog(),
      ),
    );
  }
}
