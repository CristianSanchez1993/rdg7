import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rdg7/bloc/support_bloc.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launchTel(BuildContext context, String phone) async {
    // Capturamos el messenger ANTES del primer await
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri(scheme: 'tel', path: phone);

    final ok = await canLaunchUrl(uri);
    if (ok) {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) return;
    }

    // Fallback para emuladores: copiar y avisar
    await Clipboard.setData(ClipboardData(text: phone));
    messenger.showSnackBar(
      const SnackBar(content: Text('No hay app de teléfono. Número copiado.')),
    );
  }

  Future<void> _launchMail(BuildContext context, String email) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri(queryParameters: const {'subject': 'Soporte - G7Match'}).query,
    );

    final ok = await canLaunchUrl(uri);
    if (ok) {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) return;
    }

    // Fallback para emuladores: copiar y avisar
    await Clipboard.setData(ClipboardData(text: email));
    messenger.showSnackBar(
      const SnackBar(content: Text('No hay app de correo. Correo copiado.')),
    );
  }

  // Botones responsivos: en pantallas angostas se apilan, en anchas van en fila.
  Widget _actionButtons(BuildContext context, String phone, String email) {
    final callBtn = FilledButton.icon(
      onPressed: () => _launchTel(context, phone),
      icon: const Icon(Icons.call),
      label: const Text('Llamar ahora'),
    );

    final mailBtn = OutlinedButton.icon(
      onPressed: () => _launchMail(context, email),
      icon: const Icon(Icons.email),
      label: const Text('Escribir correo'),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360; // umbral
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              callBtn,
              const SizedBox(height: 8),
              mailBtn,
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(child: callBtn),
              const SizedBox(width: 12),
              Expanded(child: mailBtn),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.watch<SupportBloc>();
    final phone = bloc.phone;
    final email = bloc.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Soporte'),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0EA5E9), Color(0xFF22C55E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 10,
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.support_agent, size: 64, color: Colors.blue),
                    const SizedBox(height: 12),
                    Text(
                      '¿Necesitas ayuda?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Comunícate con nuestro equipo de soporte.\n'
                      '¡Estamos listos para ayudarte!',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.06), // reemplazo de withOpacity
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.18)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Teléfono', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          SelectableText(phone),
                          const SizedBox(height: 10),
                          const Text('Correo', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          SelectableText(email),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _actionButtons(context, phone, email),
                    const SizedBox(height: 8),
                    Text(
                      'Respuesta en horario laboral.',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
