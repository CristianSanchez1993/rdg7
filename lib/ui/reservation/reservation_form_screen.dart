import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bloc/reservation_bloc.dart';
import '../../model/reservation_model.dart';
import '../../model/user_model.dart';
import '../../model/court_model.dart';
import '../../repository/user_repository.dart';
import '../../repository/court_repository.dart';

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

  // Listas cargadas desde backend
  List<UserModel> _users = [];
  List<CourtModel> _courts = [];

  // Valores seleccionados
  String? _selectedUserId;
  String? _selectedCourtId;

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    // Si estamos editando una reserva
    if (widget.reservation != null) {
      final r = widget.reservation!;
      _selectedCourtId = r.courtId.toString();
      _selectedUserId = r.userId.toString();
      _startAt = r.startAt;
      _endAt = r.endAt;
      _statusCode = r.statusCode;
      _notes = r.notes;
    }

    _initializeForm();
  }

  Future<void> _initializeForm() async {
    await Future.wait([_loadUsers(), _loadCourts()]);
    setState(() => _loading = false);
  }

  Future<void> _loadUsers() async {
    final users = await UserRepository().getUsers();
    setState(() => _users = users);
  }

  Future<void> _loadCourts() async {
    final courts = await CourtRepository().getCourts();
    setState(() => _courts = courts);
  }

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

  void _saveReservation() {
    if (!_formKey.currentState!.validate()) return;

    if (_endAt != null && _startAt != null && _endAt!.isBefore(_startAt!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de fin debe ser posterior al inicio'),
        ),
      );
      return;
    }

    _formKey.currentState!.save();

    final bloc = context.read<ReservationBloc>();
    final reservation = ReservationModel(
      id: widget.reservation?.id ?? 0,
      courtId: int.parse(_selectedCourtId!),
      userId: int.parse(_selectedUserId!),
      startAt: _startAt ?? DateTime.now(),
      endAt: _endAt ?? DateTime.now().add(const Duration(hours: 1)),
      statusCode: _statusCode,
      notes: _notes,
    );

    if (widget.reservation == null) {
      bloc.createReservation(reservation);
    } else {
      bloc.updateReservation(reservation);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
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
                /// === SELECCIONAR CANCHA ===
                DropdownButtonFormField<String>(
                  value: _courts.any((c) => c.id.toString() == _selectedCourtId)
                      ? _selectedCourtId
                      : null,
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

                /// === SELECCIONAR USUARIO ===
                DropdownButtonFormField<String>(
                  value: _users.any((u) => u.id.toString() == _selectedUserId)
                      ? _selectedUserId
                      : null,
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

                /// === FECHA INICIO ===
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

                /// === FECHA FIN ===
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

                const SizedBox(height: 16),

                /// === ESTADO ===
                DropdownButtonFormField<String>(
                  value: _statusCode,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: const [
                    DropdownMenuItem(value: 'PENDING', child: Text('Pendiente')),
                    DropdownMenuItem(
                        value: 'CONFIRMED', child: Text('Confirmada')),
                    DropdownMenuItem(
                        value: 'CANCELLED', child: Text('Cancelada')),
                  ],
                  onChanged: (value) => setState(() => _statusCode = value!),
                ),

                const SizedBox(height: 16),

                /// === NOTAS ===
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
}
