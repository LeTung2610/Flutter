import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nhóm 5',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class Member {
  final String name;
  final String role;
  final String image;

  Member({required this.name, required this.role, required this.image});
}

class HomePage extends StatelessWidget {
  final List<Member> members = [
    Member(
      name: "Lý Ngọc Quân",
      role: "Trưởng nhóm",
      image: "assets/images/anhdaidien2.jpg",
    ),
    Member(
      name: "Lê Văn Tùng",
      role: "Thành Viên Nhóm",
      image: "assets/images/anhdaidien1.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trang chủ - Nhóm chúng tôi"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return Card(
            margin: EdgeInsets.all(10),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(member.image),
              ),
              title: Text(
                member.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(member.role),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      ),
    );
  }
}