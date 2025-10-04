import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bloc/reservation_bloc.dart';
import '../../model/reservation_model.dart';
import '../../model/user_model.dart';
import '../../model/court_model.dart';
import '../../repository/user_repository.dart';

class ReservationFormScreen extends StatefulWidget {
  final ReservationModel? reservation;

  const ReservationFormScreen({super.key, this.reservation});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startAt;
  DateTime? _endAt;
  String _statusCode = 'PENDING';
  String? _notes;

  // Listas
  List<UserModel> _users = [];
  List<CourtModel> _courts = [];

  String? _selectedUserId;
  String? _selectedCourtId;

  @override
  void initState() {
    super.initState();

    if (widget.reservation != null) {
      final r = widget.reservation!;
      _selectedCourtId = r.courtId.toString();
      _selectedUserId = r.userId.toString();
      _startAt = r.startAt;
      _endAt = r.endAt;
      _statusCode = r.statusCode;
      _notes = r.notes;
    }

    _loadUsers();
    _loadCourts();
  }

  /// Usuarios desde la API
  Future<void> _loadUsers() async {
    final users = await UserRepository().getUsers();
    setState(() => _users = users);
  }

  /// Mock de canchas
  Future<void> _loadCourts() async {
    setState(() {
      _courts = [
        CourtModel(
          id: 1,
          name: 'Cancha Fútbol 5',
          location: 'Parque A',
          sportId: 1,
          pricePerHour: 50000,
          isActive: true,
        ),
        CourtModel(
          id: 2,
          name: 'Cancha Básquet',
          location: 'Coliseo B',
          sportId: 2,
          pricePerHour: 30000,
          isActive: true,
        ),
        CourtModel(
          id: 3,
          name: 'Cancha Tenis',
          location: 'Club C',
          sportId: 3,
          pricePerHour: 40000,
          isActive: false,
        ),
      ];
    });
  }

  /// Selector de fecha y hora
  Future<void> _pickDateTime(bool isStart) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startAt ?? DateTime.now())
          : (_endAt ?? DateTime.now()),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedTime != null) {
        final dt = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isStart) {
            _startAt = dt;
          } else {
            _endAt = dt;
          }
        });
      }
    }
  }

  /// Guardar
  void _saveReservation() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); //  Guardar el valor de notas
      final bloc = context.read<ReservationBloc>();
      final reservation = ReservationModel(
        id: widget.reservation?.id ?? 0,
        courtId: int.parse(_selectedCourtId!),
        userId: int.parse(_selectedUserId!),
        startAt: _startAt ?? DateTime.now(),
        endAt: _endAt ?? DateTime.now().add(const Duration(hours: 1)),
        statusCode: _statusCode,
        notes: _notes, //  Pasamos notas
      );

      if (widget.reservation == null) {
        bloc.createReservation(reservation);
      } else {
        bloc.updateReservation(reservation);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.reservation == null ? 'Nueva Reserva' : 'Editar Reserva',
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// Select cancha
              DropdownButtonFormField<String>(
                initialValue: _selectedCourtId,
                hint: const Text('Selecciona una cancha'),
                items: _courts
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id.toString(),
                        child: Text('${c.name} - ${c.location}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedCourtId = value),
                validator: (value) =>
                    value == null ? 'Selecciona una cancha' : null,
              ),

              const SizedBox(height: 16),

              /// Select usuario
              DropdownButtonFormField<String>(
                initialValue: _selectedUserId,
                hint: const Text('Selecciona un usuario'),
                items: _users
                    .map(
                      (u) => DropdownMenuItem(
                        value: u.id.toString(),
                        child: Text('${u.firstName} ${u.lastName}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedUserId = value),
                validator: (value) =>
                    value == null ? 'Selecciona un usuario' : null,
              ),

              const SizedBox(height: 16),

              /// Fecha inicio
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _startAt == null
                          ? 'Fecha inicio no seleccionada'
                          : 'Inicio: $_startAt',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pickDateTime(true),
                    child: const Text('Seleccionar inicio'),
                  ),
                ],
              ),

              /// Fecha fin
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _endAt == null
                          ? 'Fecha fin no seleccionada'
                          : 'Fin: $_endAt',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pickDateTime(false),
                    child: const Text('Seleccionar fin'),
                  ),
                ],
              ),

              /// Estado
              DropdownButtonFormField<String>(
                initialValue: _statusCode,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: const [
                  DropdownMenuItem(value: 'PENDING', child: Text('Pendiente')),
                  DropdownMenuItem(
                    value: 'CONFIRMED',
                    child: Text('Confirmada'),
                  ),
                  DropdownMenuItem(
                    value: 'CANCELLED',
                    child: Text('Cancelada'),
                  ),
                ],
                onChanged: (value) => setState(() => _statusCode = value!),
              ),

              const SizedBox(height: 16),

              /// Notas (campo largo)
              TextFormField(
                initialValue: _notes,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _notes = value,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveReservation,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
