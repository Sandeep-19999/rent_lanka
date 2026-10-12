import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../services/payment_service.dart';
import '../../utils/date_utils.dart';
import '../../widgets/booking_widgets.dart';
import '../../widgets/rental_date_picker.dart';
import '../../widgets/payment_method_form.dart';

/// Edit Booking: change the rental dates and/or payment method of a
/// Cash on Pickup booking that the provider has not responded to yet.
class EditBookingScreen extends StatefulWidget {
  final Booking booking;

  const EditBookingScreen({super.key, required this.booking});

  @override
  State<EditBookingScreen> createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  final _service = BookingService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  BookingEditOptions? _options;
  bool _loading = true;
  String? _loadError;
  bool _saving = false;

  late DateTime _start;
  late DateTime _end;
  late PaymentMethod _method;
  String? _bank;

  Booking get _booking => widget.booking;

  @override
  void initState() {
    super.initState();
    _start = AppDates.parseKey(_booking.startDate) ?? AppDates.dateOnly(DateTime.now());
    _end = AppDates.parseKey(_booking.endDate) ?? _start;
    _method = _booking.paymentMethod;
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final options = await _service.loadEditOptions(_booking);
      if (!mounted) return;
      setState(() {
        _options = options;
        _loading = false;
      });
    } on BookingException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Could not check availability. Please try again.';
        _loading = false;
      });
    }
  }

  bool get _datesChanged =>
      AppDates.key(_start) != _booking.startDate ||
      AppDates.key(_end) != _booking.endDate;

  bool get _hasChanges => _datesChanged || _method != _booking.paymentMethod;

  PriceBreakdown? get _newPrice {
    final options = _options;
    if (options == null) return null;
    return BookingDraft(
      equipment: options.equipment,
      startDate: _start,
      endDate: _end,
      pickupMethod: _booking.pickupMethod,
      deliveryAddress: _booking.deliveryAddress,
      note: _booking.note,
    ).price;
  }

  Future<void> _pickDates() async {
    final unavailable = _options?.unavailable ?? const <String>{};
    final today = AppDates.dateOnly(DateTime.now());
    final lastDate = today.add(const Duration(days: BookingService.bookingWindowDays));
    // An old pending booking may start in the past; don't preselect it.
    final initial = !_start.isBefore(today) && !_end.isAfter(lastDate)
        ? DateTimeRange(start: _start, end: _end)
        : null;

    final picked = await showRentalDatePicker(
      context: context,
      firstDate: today,
      lastDate: lastDate,
      initialRange: initial,
      unavailable: unavailable,
      maxDays: BookingService.maxRentalDays,
      pricePerDay: _options?.equipment.pricePerDay,
      title: 'Move your game days',
    );
    if (picked == null || !mounted) return;

    final error = BookingService.validateDates(
      start: picked.start,
      end: picked.end,
      unavailable: unavailable,
    );
    if (error != null) {
      showMessage(context, error, error: true);
      return;
    }

    setState(() {
      _start = AppDates.dateOnly(picked.start);
      _end = AppDates.dateOnly(picked.end);
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_hasChanges) {
      showMessage(context, 'You have not changed anything.', error: true);
      return;
    }
    final dateError = BookingService.validateDates(
      start: _start,
      end: _end,
      unavailable: _options?.unavailable ?? const <String>{},
    );
    if (dateError != null) {
      showMessage(context, dateError, error: true);
      return;
    }
    if (_method == PaymentMethod.card && !_formKey.currentState!.validate()) {
      return;
    }
    if (_method == PaymentMethod.onlineBanking && _bank == null) {
      showMessage(context, 'Please select your bank.', error: true);
      return;
    }

    setState(() => _saving = true);
    try {
      await _service.updateBooking(
        booking: _booking,
        startDate: _start,
        endDate: _end,
        paymentMethod: _method,
        bank: _bank,
        card: _method == PaymentMethod.card
            ? CardDetails(
                holderName: _nameController.text,
                number: _numberController.text,
                expiry: _expiryController.text,
                cvv: _cvvController.text,
              )
            : null,
      );
      if (!mounted) return;
      showMessage(
        context,
        _method == PaymentMethod.cashOnPickup
            ? 'Booking updated. The provider has been notified.'
            : 'Payment successful. Booking updated.',
      );
      Navigator.pop(context, true);
    } on BookingException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showMessage(context, error.message, error: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showMessage(
        context,
        'Could not update the booking. Your booking has not been changed.',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = _newPrice;
    final paying = _method != PaymentMethod.cashOnPickup;

    return PopScope(
      canPop: !_saving,
      child: BookingPage(
        title: 'Edit Booking',
        bottom: _options == null
            ? null
            : PrimaryButton(
                label: paying && price != null
                    ? 'Pay ${formatLkr(price.totalPayable)} & Save'
                    : 'Save Changes',
                icon: paying ? Icons.lock : Icons.check,
                loading: _saving,
                onPressed: _hasChanges ? _save : null,
              ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: primaryRed))
            : _loadError != null
                ? _ErrorView(message: _loadError!, onRetry: _load)
                : AbsorbPointer(
                    absorbing: _saving,
                    child: _form(price!),
                  ),
      ),
    );
  }

  Widget _form(PriceBreakdown price) {
    final unavailable = _options!.unavailable;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionCard(
            child: Row(
              children: [
                EquipmentThumb(category: _booking.equipmentCategory),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _booking.equipmentName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _booking.bookingReference,
                        style: const TextStyle(
                          color: textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                BookingStatusChip(status: _booking.status),
              ],
            ),
          ),

          const SizedBox(height: 14),
          SectionCard(
            title: 'Current booking',
            child: Column(
              children: [
                InfoRow(
                  label: 'Dates',
                  value: AppDates.prettyRange(_booking.startDate, _booking.endDate),
                ),
                InfoRow(label: 'Payment', value: _booking.paymentMethod.label),
                InfoRow(label: 'Total', value: formatLkr(_booking.totalPayable)),
              ],
            ),
          ),

          const SizedBox(height: 22),
          const Text(
            'New rental period',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DateTile(label: 'Start date', date: _start, onTap: _pickDates),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DateTile(label: 'End date', date: _end, onTap: _pickDates),
              ),
            ],
          ),
          if (unavailable.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Greyed-out dates are already booked or blocked by the provider.',
                style: TextStyle(color: textGrey, fontSize: 12),
              ),
            ),

          const SizedBox(height: 22),
          PaymentMethodForm(
            method: _method,
            onMethodChanged: (value) => setState(() => _method = value),
            bank: _bank,
            onBankChanged: (value) => setState(() => _bank = value),
            formKey: _formKey,
            nameController: _nameController,
            numberController: _numberController,
            expiryController: _expiryController,
            cvvController: _cvvController,
            cashInfo: 'Keep paying the provider in cash when you collect the '
                'equipment. You can still edit this booking until the '
                'provider responds.',
          ),

          const SizedBox(height: 18),
          SectionCard(
            title: 'New total',
            child: Column(
              children: [
                InfoRow(
                  label: 'Rental (${price.rentalDays} x '
                      '${formatLkr(price.pricePerDay)})',
                  value: formatLkr(price.rentalCost),
                ),
                if (price.deliveryFee > 0)
                  InfoRow(label: 'Delivery fee', value: formatLkr(price.deliveryFee)),
                InfoRow(label: 'Service fee', value: formatLkr(price.serviceFee)),
                InfoRow(label: 'Refundable deposit', value: formatLkr(price.deposit)),
                const Divider(height: 22, color: borderGrey),
                InfoRow(
                  label: 'Total',
                  value: formatLkr(price.totalPayable),
                  emphasise: true,
                ),
              ],
            ),
          ),

          if (_method != PaymentMethod.cashOnPickup)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'After paying online this booking can no longer be edited. '
                'You can still cancel it for a full refund before pickup.',
                style: TextStyle(color: textGrey, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
