import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'http_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'CRUD API', home: UserListScreen());
  }
}

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<User>> futureUsers;

  Future<void> refreshUsers() async {
    setState(() {
      futureUsers = HttpService.fetchUsers();
    });
  }

  @override
  void initState() {
    super.initState();
    futureUsers = HttpService.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Pengguna')),
      body: FutureBuilder<List<User>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<User> users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text('Umur: ${user.age}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      if (user.id != null) {
                        await HttpService.deleteUser(user.id!);
                        setState(() {
                          users.removeAt(index);
                        });
                      }
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateUserScreen(
                onUserCreated: () {
                  refreshUsers();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class CreateUserScreen extends StatefulWidget {
  final VoidCallback? onUserCreated;

  const CreateUserScreen({Key? key, this.onUserCreated}) : super(key: key);

  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Pengguna')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Umur'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text;
                final age = int.tryParse(_ageController.text) ?? 0;
                if (name.isNotEmpty && age > 0) {
                  await HttpService.createUser(name, age);
                  widget.onUserCreated?.call();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
