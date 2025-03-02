import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(ContactApp());
}

class ContactApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ContactListScreen(),
    );
  }
}

class ContactListScreen extends StatefulWidget {
  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  List<dynamic> contacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
    if (response.statusCode == 200) {
      setState(() {
        contacts = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Falha ao carregar contatos');
    }
  }

  void addContact(String name, String email) {
    setState(() {
      contacts.add({
        'name': name,
        'email': email,
        'phone': 'N/A',
        'address': {'street': 'N/A', 'city': 'N/A'}
      });
    });
  }

  void deleteContact(int index) {
    setState(() {
      contacts.removeAt(index);
      if (contacts.isEmpty || Navigator.canPop(context)) {
      Navigator.pop(context); 
    }
    });
  }

  void editContact(int index, String name, String email, String phone, String street, String city) {
    setState(() {
      contacts[index] = {
        'name': name,
        'email': email,
        'phone': phone,
        'address': {'street': street, 'city': city}
      };
    });
  }

  void showAddContactDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Contato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nome')),
              TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                addContact(nameController.text, emailController.text);
                Navigator.pop(context);
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void showEditContactDialog(int index) {
    TextEditingController nameController = TextEditingController(text: contacts[index]['name']);
    TextEditingController emailController = TextEditingController(text: contacts[index]['email']);
    TextEditingController phoneController = TextEditingController(text: contacts[index]['phone']);
    TextEditingController streetController = TextEditingController(text: contacts[index]['address']['street']);
    TextEditingController cityController = TextEditingController(text: contacts[index]['address']['city']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Contato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nome')),
              TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
              TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Telefone')),
              TextField(controller: streetController, decoration: InputDecoration(labelText: 'Rua')),
              TextField(controller: cityController, decoration: InputDecoration(labelText: 'Cidade')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                editContact(index, nameController.text, emailController.text, phoneController.text, streetController.text, cityController.text);
                Navigator.pop(context);
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text(
          'Contatos',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 112, 165, 255),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 3,
                  child: ListTile(
                    title: Text(contact['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(contact['email']),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactDetailScreen(
                          contact: contact,
                          onEdit: () => showEditContactDialog(index),
                          onDelete: () => deleteContact(index),
                        ),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => showEditContactDialog(index)),
                        IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => deleteContact(index)),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddContactDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

class ContactDetailScreen extends StatelessWidget {
  final dynamic contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  ContactDetailScreen({required this.contact, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], 
      appBar: AppBar(
        title: Text(
          contact['name'],
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 112, 165, 255),
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(16),
          elevation: 5, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nome: ${contact['name']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Email: ${contact['email']}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('Telefone: ${contact['phone']}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text(
                  'Endereço: ${contact['address']['street']}, ${contact['address']['city']}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(onPressed: onEdit, icon: Icon(Icons.edit), label: Text('Editar')),
                    ElevatedButton.icon(onPressed: onDelete, icon: Icon(Icons.delete, color: Colors.red), label: Text('Excluir', style: TextStyle(color: Colors.red)), style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 255, 255, 255))),

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
