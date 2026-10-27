import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'service_provider.dart';

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({super.key, required this.provider});

  final ServiceProvider provider;

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  DateTime? get _scheduledAt {
    if (_selectedDate == null || _selectedTime == null) {
      return null;
    }

    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  Future<void> _chooseDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'Choose service date',
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _chooseTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      helpText: 'Choose service time',
    );

    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitBooking() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please sign in before booking.');
      return;
    }

    final scheduledAt = _scheduledAt;

    if (scheduledAt == null) {
      _showMessage('Please choose a date and time.');
      return;
    }

    if (!scheduledAt.isAfter(DateTime.now())) {
      _showMessage('Please choose a future date and time.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final bookingRef = FirebaseFirestore.instance
          .collection('bookings')
          .doc();

      await bookingRef.set({
        'customerId': user.uid,
        'customerName': user.displayName ?? '',
        'customerEmail': user.email ?? '',
        'providerId': widget.provider.id,
        'providerName': widget.provider.name,
        'service': widget.provider.service,
        'price': widget.provider.price,
        'address': _addressController.text.trim(),
        'notes': _notesController.text.trim(),
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            bookingId: bookingRef.id,
            providerName: widget.provider.name,
            serviceName: widget.provider.service,
            scheduledAt: scheduledAt,
          ),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      _showMessage(
        error.code == 'permission-denied'
            ? 'Booking was blocked by Firestore security rules. Please check your rules.'
            : 'Could not save your booking. Please try again.',
      );
    } catch (_) {
      if (mounted) {
        _showMessage('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Book a Service')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Your booking',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        child: const Icon(Icons.home_repair_service),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(provider.service),
                          ],
                        ),
                      ),
                      Text(
                        '₹${provider.price}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'When do you need the service?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _chooseDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  _selectedDate == null
                      ? 'Select date'
                      : DateFormat('EEE, d MMM yyyy').format(_selectedDate!),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _chooseTime,
                icon: const Icon(Icons.access_time),
                label: Text(
                  _selectedTime == null
                      ? 'Select time'
                      : _selectedTime!.format(context),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Service address',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'House / flat, street, area, city, PIN code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 10) {
                    return 'Enter a complete service address.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Additional instructions (optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 3,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Describe the issue or any special requirements',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estimated service price'),
                    const SizedBox(height: 6),
                    Text(
                      '₹${provider.price}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Final charges may change depending on the work required. '
                      'The booking request does not mean the provider has accepted it.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submitBooking,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm Booking Request'),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your details will be shared with the selected service provider '
                'to process this request.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.bookingId,
    required this.providerName,
    required this.serviceName,
    required this.scheduledAt,
  });

  final String bookingId;
  final String providerName;
  final String serviceName;
  final DateTime scheduledAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Booking Request'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 84,
                ),
                const SizedBox(height: 20),
                Text(
                  'Request submitted!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your booking request has been saved. It is awaiting provider confirmation.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailRow(label: 'Service', value: serviceName),
                        _DetailRow(label: 'Provider', value: providerName),
                        _DetailRow(
                          label: 'Date',
                          value: DateFormat('d MMM yyyy').format(scheduledAt),
                        ),
                        _DetailRow(
                          label: 'Time',
                          value: DateFormat('h:mm a').format(scheduledAt),
                        ),
                        _DetailRow(label: 'Status', value: 'Pending'),
                        const SizedBox(height: 8),
                        const Text(
                          'Booking reference',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(bookingId),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
