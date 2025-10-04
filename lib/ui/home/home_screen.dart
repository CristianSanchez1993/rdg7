import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rdg7/ui/reservation/reservation_list_screen.dart';
import 'package:rdg7/ui/user/user_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Menú Principal')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildMenuButton(
          context,
          title: 'Ingresar Reservación',
          icon: Icons.calendar_month,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<ReservationListScreen>(
              builder: (_) => const ReservationListScreen(),
            ),
          ),
        ),
        const SizedBox(height: 15),

        _buildMenuButton(
          context,
          title: 'Ingresar Usuarios',
          icon: Icons.person,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<UserListScreen>(
              builder: (_) => const UserListScreen(),
            ),
          ),
        ),
        const SizedBox(height: 15),

        _buildMenuButton(
          context,
          title: 'Ingresar Cancha',
          icon: Icons.sports_soccer,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pantalla de Canchas pendiente')),
          ),
        ),
        const SizedBox(height: 15),
        _buildMenuButton(
          context,
          title: 'Soporte',
          icon: Icons.support_agent,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Soporte no implementado')),
          ),
        ),
        const SizedBox(height: 15),
        _buildMenuButton(
          context,
          title: 'Salir',
          icon: Icons.exit_to_app,
          color: Colors.red,
          onTap: () => SystemNavigator.pop(),
        ),
      ],
    ),
  );

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) => ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 60),
    ),
    icon: Icon(icon, size: 28),
    label: Text(title, style: const TextStyle(fontSize: 18)),
    onPressed: onTap,
  );
}
