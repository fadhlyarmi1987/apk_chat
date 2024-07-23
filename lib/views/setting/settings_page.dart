import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final String currentName;
  final String email;

  SettingsPage({required this.currentName, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: const Color.fromARGB(255, 20, 131, 234),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Ganti Nama'),
              onTap: () {
                _showChangeNameDialog(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Ganti Password'),
              onTap: () {
                _showChangePasswordDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeNameDialog(BuildContext context) {
    final TextEditingController nameController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ganti Nama'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: "Masukkan nama baru"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Simpan'),
              onPressed: () {
                // Lakukan sesuatu untuk menyimpan nama baru
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ganti Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(hintText: "Password saat ini"),
              ),
              SizedBox(height: 8),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(hintText: "Password baru"),
              ),
              SizedBox(height: 8),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration:
                    InputDecoration(hintText: "Konfirmasi password baru"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Simpan'),
              onPressed: () {
                String currentPassword = currentPasswordController.text;
                String newPassword = newPasswordController.text;
                String confirmPassword = confirmPasswordController.text;

                if (currentPassword.isEmpty ||
                    newPassword.isEmpty ||
                    confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Semua field harus diisi'),
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Validasi password baru dan konfirmasi
                if (newPassword != confirmPassword) {
                  // Tampilkan pesan error jika password baru dan konfirmasi tidak cocok
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password baru dan konfirmasi tidak cocok'),
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Lakukan sesuatu untuk menyimpan password baru
                // Misalnya, panggil fungsi untuk mengubah password di Firebase Authentication
                // Di sini, kita hanya menutup dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
