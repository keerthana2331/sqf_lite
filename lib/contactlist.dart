import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'db_helper.dart';
import 'contact.dart';
import 'contactpage.dart';

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> _contacts = [];
  final DBHelper _dbHelper = DBHelper();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // Gradient color control
  late List<Color> _colors;
  late List<Color> _secondColors;

  @override
  void initState() {
    super.initState();
    _loadContacts();

    _colors = [Colors.teal.shade300, Colors.blue.shade400]; // Initial colors
    _secondColors = [Colors.blue.shade400, Colors.purple.shade600]; // Second colors for animation
    _startGradientAnimation();
  }

  Future<void> _loadContacts() async {
    final contacts = await _dbHelper.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  void _navigateToAddEditPage({Contact? contact}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditContactPage(contact: contact),
      ),
    );

    if (result == true) {
      _loadContacts();
    }
  }

  Future<void> _confirmDelete(int id, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Contact'),
        content: Text('Are you sure you want to delete this contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbHelper.deleteContact(id);
      setState(() {
        _contacts.removeAt(index);
      });
    }
  }

  // Function to animate background gradient change
  void _startGradientAnimation() {
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _colors = _secondColors;
        _secondColors = _colors;
      });
      _startGradientAnimation(); // Loop the animation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contact Manager',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: AnimatedContainer(
        duration: Duration(seconds: 3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _contacts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: Duration(seconds: 1),
                      child: Icon(Icons.contacts, size: 100, color: Colors.white.withOpacity(0.7)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No Contacts Found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the "+" button to add a new contact!',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  ],
                ),
              )
            : AnimationLimiter(
                child: ListView.builder(
                  key: _listKey,
                  padding: EdgeInsets.all(8),
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.teal.shade300,
                                child: Text(
                                  contact.name[0].toUpperCase(),
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                              ),
                              title: Text(
                                contact.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                contact.phone,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Tooltip(
                                    message: 'Edit Contact',
                                    child: IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _navigateToAddEditPage(contact: contact),
                                    ),
                                  ),
                                  Tooltip(
                                    message: 'Delete Contact',
                                    child: IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmDelete(contact.id!, index),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditPage(),
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
