import 'package:bazarnicole/Presentation/Controller/pos_controller.dart';
import 'package:bazarnicole/Presentation/Renders/responsive_helper.dart';
import 'package:bazarnicole/Presentation/Utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────
//  POS View — Sistema de Ventas
// ─────────────────────────────────────────────────────────────────

class PosView extends StatefulWidget {
  const PosView({super.key});

  @override
  State<PosView> createState() => _PosViewState();
}

class _PosViewState extends State<PosView> {
  String _receiptType = 'Nota de Venta';
  final List<String> _receiptTypes = ['Nota de Venta', 'Factura', 'Recibo'];
  bool _isConsumerFinal = true;
  int? _selectedPaymentMethodId;
  final List<Map<String, dynamic>> _payments = [];
  double _discount = 0;
  double _transport = 0;
  final _discountController = TextEditingController(text: '0');
  final _transportController = TextEditingController(text: '0');
  final _receivedController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PosController>().initialize();
    });
  }

  @override
  void dispose() {
    _discountController.dispose();
    _transportController.dispose();
    _receivedController.dispose();
    super.dispose();
  }

  double _effectiveTotal(double cartTotal) =>
      (cartTotal - _discount + _transport).clamp(0, double.infinity);

  void _showProductSearch(BuildContext ctx, PosController controller) {
    showDialog(
      context: ctx,
      builder: (_) => _ProductSearchDialog(controller: controller),
    );
  }

  void _showClientSearch(BuildContext ctx, PosController controller) {
    showDialog(
      context: ctx,
      builder: (_) => _ClientSearchDialog(controller: controller),
    ).then((_) {
      if (mounted) {
        setState(() {
          _isConsumerFinal = controller.selectedCustomerId == null;
        });
      }
    });
  }

  void _addPayment(PosController controller, double total) {
    if (controller.paymentMethods.isEmpty) return;
    final received = _payments.fold<double>(
      0,
      (s, p) => s + (p['amount'] as double),
    );
    final remaining = total - received;
    if (remaining <= 0) return;
    final methodId =
        _selectedPaymentMethodId ??
        (controller.paymentMethods.first['id'] as num).toInt();
    final method = controller.paymentMethods.firstWhere(
      (m) => (m['id'] as num).toInt() == methodId,
      orElse: () => controller.paymentMethods.first,
    );
    setState(() {
      _payments.add({
        'method_id': methodId,
        'method_name': method['name'].toString(),
        'amount': remaining,
      });
    });
  }

  void _limpiarVenta(PosController controller) {
    controller.clearCart();
    setState(() {
      _payments.clear();
      _discount = 0;
      _transport = 0;
      _discountController.text = '0';
      _transportController.text = '0';
      _receivedController.text = '0';
      _isConsumerFinal = true;
    });
  }

  Future<void> _finalizarVenta(PosController controller) async {
    final messenger = ScaffoldMessenger.of(context);
    final effectiveTotal = _effectiveTotal(controller.total);
    if (controller.cart.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Agrega productos antes de vender')),
      );
      return;
    }
    try {
      final paymentsToSend = _payments.isNotEmpty
          ? List<Map<String, dynamic>>.of(_payments)
          : [
              {
                'method_id':
                    _selectedPaymentMethodId ??
                    (controller.paymentMethods.isNotEmpty
                        ? (controller.paymentMethods.first['id'] as num).toInt()
                        : 1),
                'method_name': _selectedPaymentMethodId != null
                    ? controller.paymentMethods
                          .firstWhere(
                            (m) =>
                                (m['id'] as num).toInt() ==
                                _selectedPaymentMethodId,
                            orElse: () => controller.paymentMethods.first,
                          )['name']
                          .toString()
                    : (controller.paymentMethods.isNotEmpty
                          ? controller.paymentMethods.first['name'].toString()
                          : 'Efectivo'),
                'amount': effectiveTotal,
              },
            ];
      final saleId = await controller.checkout(payments: paymentsToSend);
      if (!mounted) return;
      setState(() {
        _payments.clear();
        _discount = 0;
        _transport = 0;
        _discountController.text = '0';
        _transportController.text = '0';
        _receivedController.text = '0';
        _isConsumerFinal = true;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text('Venta #$saleId registrada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = ResponsiveHelper.getAppBarHeight(context) + 48;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f9): () =>
            _finalizarVenta(context.read<PosController>()),
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            _limpiarVenta(context.read<PosController>()),
      },
      child: Focus(
        autofocus: true,
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: const Color(0xFFF2F2F2),
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(appBarHeight),
              child: ClipRRect(
                clipBehavior: Clip.hardEdge,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(25),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.blackOverlay,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AppBar(
                    surfaceTintColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    elevation: 4,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.whiteOverlay,
                        size: 30,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: const Text(
                      'Sistema de Ventas',
                      style: TextStyle(
                        fontSize: 22,
                        color: AppColors.whiteOverlay,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    actions: [
                      IconButton(
                        tooltip: 'Nueva venta · ESC',
                        onPressed: () =>
                            _limpiarVenta(context.read<PosController>()),
                        icon: const Icon(
                          Icons.add,
                          color: AppColors.whiteOverlay,
                          size: 28,
                        ),
                      ),
                    ],
                    bottom: const TabBar(
                      labelColor: AppColors.whiteOverlay,
                      unselectedLabelColor: AppColors.mediumGray,
                      indicatorColor: AppColors.whiteOverlay,
                      tabs: [
                        Tab(
                          text: 'Venta 1',
                          icon: Icon(Icons.receipt_outlined),
                        ),
                        Tab(
                          text: 'Historial',
                          icon: Icon(Icons.history_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: TabBarView(
              children: [
                Consumer<PosController>(
                  builder: (ctx, controller, _) {
                    final cartTotal = controller.total;
                    final total = _effectiveTotal(cartTotal);
                    final received =
                        double.tryParse(_receivedController.text) ?? 0;
                    final change = received - total;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Tipo de comprobante
                          _ReceiptTypeCard(
                            receiptType: _receiptType,
                            receiptTypes: _receiptTypes,
                            onChanged: (v) => setState(() => _receiptType = v),
                          ),
                          const SizedBox(height: 16),
                          // ── Cliente
                          _ClienteSection(
                            controller: controller,
                            isConsumerFinal: _isConsumerFinal,
                            onConsumerFinalChanged: (v) {
                              setState(() {
                                _isConsumerFinal = v;
                                if (v) controller.selectCustomer(null);
                              });
                            },
                            onShowClientSearch: (bCtx, ctrl) =>
                                _showClientSearch(bCtx, ctrl),
                          ),
                          const SizedBox(height: 16),
                          // ── Local
                          if (controller.stores.isNotEmpty)
                            DropdownButtonFormField<int>(
                              value: controller.selectedStoreId,
                              decoration: InputDecoration(
                                labelText: 'Local',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: controller.stores.map((store) {
                                return DropdownMenuItem<int>(
                                  value: (store['id'] as num).toInt(),
                                  child: Text(store['name'].toString()),
                                );
                              }).toList(),
                              onChanged: controller.selectStore,
                            ),
                          const SizedBox(height: 16),
                          // ── Productos
                          _ProductosSection(
                            controller: controller,
                            onShowProductSearch: (bCtx, ctrl) =>
                                _showProductSearch(bCtx, ctrl),
                          ),
                          const SizedBox(height: 16),
                          // ── Forma de pago
                          _FormaPagoSection(
                            controller: controller,
                            selectedMethodId: _selectedPaymentMethodId,
                            onSelect: (id) =>
                                setState(() => _selectedPaymentMethodId = id),
                          ),
                          const SizedBox(height: 16),
                          // ── Pagos recibidos
                          _PagosRecibidosSection(
                            payments: _payments,
                            total: total,
                            onAddPayment: () => _addPayment(controller, total),
                            onRemovePayment: (i) =>
                                setState(() => _payments.removeAt(i)),
                          ),
                          const SizedBox(height: 16),
                          // ── Resumen de venta
                          _ResumenVentaCard(
                            subtotal: cartTotal,
                            discount: _discount,
                            transport: _transport,
                            total: total,
                            received: received,
                            change: change,
                            discountController: _discountController,
                            transportController: _transportController,
                            receivedController: _receivedController,
                            onDiscountChanged: (v) => setState(
                              () => _discount = double.tryParse(v) ?? 0,
                            ),
                            onTransportChanged: (v) => setState(
                              () => _transport = double.tryParse(v) ?? 0,
                            ),
                            onReceivedChanged: (v) => setState(() {}),
                          ),
                          const SizedBox(height: 20),
                          // ── Botones finales
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade600,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () => _limpiarVenta(controller),
                                    icon: const Icon(
                                      Icons.delete_sweep_outlined,
                                    ),
                                    label: const Text(
                                      'Limpiar Venta',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2D5A27),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: controller.cart.isEmpty
                                        ? null
                                        : () => _finalizarVenta(controller),
                                    icon: const Icon(Icons.sell_outlined),
                                    label: const Text(
                                      'Finalizar Venta',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    );
                  },
                ),
                const _SalesHistoryTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Widget: Tipo de comprobante
// ─────────────────────────────────────────────────────────────────

class _ReceiptTypeCard extends StatelessWidget {
  final String receiptType;
  final List<String> receiptTypes;
  final void Function(String) onChanged;

  const _ReceiptTypeCard({
    required this.receiptType,
    required this.receiptTypes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Card(
          elevation: 0,
          color: const Color(0xFFF0EDEA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo de comprobante',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButton<String>(
                      value: receiptType,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      items: receiptTypes
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) onChanged(v);
                      },
                    ),
                    const Text(
                      'Cada tipo tiene numeración independiente',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
                Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
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

// ─────────────────────────────────────────────────────────────────
//  Widget: Sección Cliente
// ─────────────────────────────────────────────────────────────────

class _ClienteSection extends StatelessWidget {
  final PosController controller;
  final bool isConsumerFinal;
  final void Function(bool) onConsumerFinalChanged;
  final void Function(BuildContext, PosController) onShowClientSearch;

  const _ClienteSection({
    required this.controller,
    required this.isConsumerFinal,
    required this.onConsumerFinalChanged,
    required this.onShowClientSearch,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCustomer = controller.selectedCustomerId != null
        ? controller.customers.firstWhere(
            (c) => (c['id'] as num).toInt() == controller.selectedCustomerId,
            orElse: () => {},
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Fila de título
        Row(
          children: [
            const Text(
              'Cliente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            if (selectedCustomer != null && selectedCustomer.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.white, size: 13),
                    SizedBox(width: 4),
                    Text(
                      'Seleccionado',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blackOverlay,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => onShowClientSearch(context, controller),
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Buscar Cliente'),
            ),
          ],
        ),
        // ── Checkbox consumidor final
        Row(
          children: [
            Checkbox(
              value: isConsumerFinal,
              activeColor: AppColors.blackOverlay,
              onChanged: (v) {
                if (v != null) onConsumerFinalChanged(v);
              },
            ),
            const Text('Consumidor final'),
          ],
        ),
        // ── Panel editable del cliente seleccionado
        if (selectedCustomer != null && selectedCustomer.isNotEmpty)
          _ClienteDetailPanel(
            customer: selectedCustomer,
            onUpdate: (data) => controller.updateCustomer(
              id: (selectedCustomer['id'] as num).toInt(),
              name: data['name'] ?? '',
              phone: data['phone'],
              email: data['email'],
              notes: data['notes'],
              cedula: data['cedula'],
              identificationType: data['identification_type'],
              address: data['address'],
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Widget: Panel editable de datos del cliente
// ─────────────────────────────────────────────────────────────────

class _ClienteDetailPanel extends StatefulWidget {
  final Map<String, dynamic> customer;
  final Future<void> Function(Map<String, String?>) onUpdate;

  const _ClienteDetailPanel({required this.customer, required this.onUpdate});

  @override
  State<_ClienteDetailPanel> createState() => _ClienteDetailPanelState();
}

class _ClienteDetailPanelState extends State<_ClienteDetailPanel> {
  late TextEditingController _cedulaCtrl;
  late TextEditingController _nombresCtrl;
  late TextEditingController _apellidosCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _direccionCtrl;
  late String _idType;
  bool _saving = false;

  final _idTypes = ['cedula', 'ruc', 'pasaporte', 'otro'];

  @override
  void initState() {
    super.initState();
    _initControllers(widget.customer);
  }

  @override
  void didUpdateWidget(_ClienteDetailPanel old) {
    super.didUpdateWidget(old);
    if (old.customer['id'] != widget.customer['id']) {
      _disposeControllers();
      _initControllers(widget.customer);
    }
  }

  void _initControllers(Map<String, dynamic> c) {
    final fullName = c['name']?.toString() ?? '';
    final parts = fullName.trim().split(' ');
    final half = (parts.length / 2).ceil();
    final nombres = parts.sublist(0, half).join(' ');
    final apellidos = parts.length > 1 ? parts.sublist(half).join(' ') : '';
    _cedulaCtrl = TextEditingController(text: c['cedula']?.toString() ?? '');
    _nombresCtrl = TextEditingController(text: nombres);
    _apellidosCtrl = TextEditingController(text: apellidos);
    _emailCtrl = TextEditingController(text: c['email']?.toString() ?? '');
    _telefonoCtrl = TextEditingController(text: c['phone']?.toString() ?? '');
    _direccionCtrl = TextEditingController(
      text: c['address']?.toString() ?? '',
    );
    final rawType = c['identification_type']?.toString() ?? '';
    _idType = _idTypes.contains(rawType) ? rawType : 'cedula';
  }

  void _disposeControllers() {
    _cedulaCtrl.dispose();
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final n = _nombresCtrl.text.trim();
      final a = _apellidosCtrl.text.trim();
      final fullName = [n, a].where((s) => s.isNotEmpty).join(' ');
      await widget.onUpdate({
        'name': fullName.isNotEmpty ? fullName : n,
        'phone': _telefonoCtrl.text.trim().isNotEmpty
            ? _telefonoCtrl.text.trim()
            : null,
        'email': _emailCtrl.text.trim().isNotEmpty
            ? _emailCtrl.text.trim()
            : null,
        'notes': null,
        'cedula': _cedulaCtrl.text.trim().isNotEmpty
            ? _cedulaCtrl.text.trim()
            : null,
        'identification_type': _idType,
        'address': _direccionCtrl.text.trim().isNotEmpty
            ? _direccionCtrl.text.trim()
            : null,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cliente actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Aviso
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cliente seleccionado. Puedes editar cualquier campo y presionar "Actualizar Cliente" para guardar los cambios.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Tipo ident + Cédula
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo ident.:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _idType,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, size: 18),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      items: _idTypes
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _idType = v);
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _idType,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                        ),
                      ),
                      TextField(
                        controller: _cedulaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Número de identificación',
                          border: UnderlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // ── Nombres + Apellidos
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nombres',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextField(
                        controller: _nombresCtrl,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Apellidos',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextField(
                        controller: _apellidosCtrl,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // ── Correo + Teléfono
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Correo electrónico',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Teléfono',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextField(
                        controller: _telefonoCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // ── Dirección
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dirección',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextField(
                  controller: _direccionCtrl,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ── Botón guardar
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blackOverlay,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: const Text('Actualizar Cliente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────

class _ProductosSection extends StatelessWidget {
  final PosController controller;
  final void Function(BuildContext, PosController) onShowProductSearch;

  const _ProductosSection({
    required this.controller,
    required this.onShowProductSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Productos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            if (controller.cart.isNotEmpty)
              Text(
                '${controller.totalItems} unidades',
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
          ],
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.blackOverlay,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => onShowProductSearch(context, controller),
          icon: const Icon(Icons.search, size: 18),
          label: const Text('Buscar Producto'),
        ),
        if (controller.errorMessage != null) ...[
          const SizedBox(height: 6),
          Text(
            controller.errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
        ],
        if (controller.cart.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                for (int i = 0; i < controller.cart.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _CartItemRow(
                    item: controller.cart[i],
                    onDecrement: () => controller.decrementQuantity(
                      controller.cart[i]['product_id'] as int,
                    ),
                    onIncrement: () => controller.incrementQuantity(
                      controller.cart[i]['product_id'] as int,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _CartItemRow({
    required this.item,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final price = item['price'] as double;
    final qty = item['quantity'] as int;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'].toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '\$${price.toStringAsFixed(2)} c/u',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_circle_outline, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$qty',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add_circle_outline, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 10),
          Text(
            '\$${(price * qty).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Widget: Forma de Pago
// ─────────────────────────────────────────────────────────────────

class _FormaPagoSection extends StatelessWidget {
  final PosController controller;
  final int? selectedMethodId;
  final void Function(int) onSelect;

  const _FormaPagoSection({
    required this.controller,
    required this.selectedMethodId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final defaultId = controller.paymentMethods.isNotEmpty
        ? (controller.paymentMethods.first['id'] as num).toInt()
        : null;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forma de Pago',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.paymentMethods.map((m) {
                final id = (m['id'] as num).toInt();
                final isSelected = (selectedMethodId ?? defaultId) == id;
                return GestureDetector(
                  onTap: () => onSelect(id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.blackOverlay
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.blackOverlay
                            : Colors.black26,
                      ),
                    ),
                    child: Text(
                      m['name'].toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Widget: Pagos Recibidos
// ─────────────────────────────────────────────────────────────────

class _PagosRecibidosSection extends StatelessWidget {
  final List<Map<String, dynamic>> payments;
  final double total;
  final VoidCallback onAddPayment;
  final void Function(int) onRemovePayment;

  const _PagosRecibidosSection({
    required this.payments,
    required this.total,
    required this.onAddPayment,
    required this.onRemovePayment,
  });

  @override
  Widget build(BuildContext context) {
    final received = payments.fold<double>(
      0,
      (s, p) => s + (p['amount'] as double),
    );
    final change = received - total;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pagos recibidos',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                TextButton.icon(
                  onPressed: onAddPayment,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Agregar pago'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            if (payments.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Sin pagos registrados',
                  style: TextStyle(color: Colors.black38, fontSize: 13),
                ),
              )
            else ...[
              for (int i = 0; i < payments.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        size: 18,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(payments[i]['method_name'].toString()),
                      ),
                      Text(
                        '\$${(payments[i]['amount'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => onRemovePayment(i),
                        child: const Icon(Icons.close, size: 16),
                      ),
                    ],
                  ),
                ),
              if (change > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Cambio: ',
                        style: TextStyle(color: Colors.green),
                      ),
                      Text(
                        '\$${change.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Widget: Resumen de Venta
// ─────────────────────────────────────────────────────────────────

class _ResumenVentaCard extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double transport;
  final double total;
  final double received;
  final double change;
  final TextEditingController discountController;
  final TextEditingController transportController;
  final TextEditingController receivedController;
  final void Function(String) onDiscountChanged;
  final void Function(String) onTransportChanged;
  final void Function(String) onReceivedChanged;

  const _ResumenVentaCard({
    required this.subtotal,
    required this.discount,
    required this.transport,
    required this.total,
    required this.received,
    required this.change,
    required this.discountController,
    required this.transportController,
    required this.receivedController,
    required this.onDiscountChanged,
    required this.onTransportChanged,
    required this.onReceivedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Resumen de Venta',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                _ResumenRow(
                  label: 'Subtotal:',
                  value: '\$${subtotal.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 10),
                // Descuento
                Row(
                  children: [
                    const Expanded(child: Text('Descuento:')),
                    const Text('\$ '),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: discountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4,
                          ),
                          border: UnderlineInputBorder(),
                        ),
                        onChanged: onDiscountChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Transporte
                Row(
                  children: [
                    const Expanded(child: Text('Transporte:')),
                    const Text('\$ '),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: transportController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4,
                          ),
                          border: UnderlineInputBorder(),
                        ),
                        onChanged: onTransportChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 10),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blackOverlay,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Recibido
                Row(
                  children: [
                    const Expanded(child: Text('Recibido:')),
                    const Text('\$ '),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: receivedController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4,
                          ),
                          border: UnderlineInputBorder(),
                        ),
                        onChanged: onReceivedChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Cambio
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cambio:',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '\$${change >= 0 ? change.toStringAsFixed(2) : '0.00'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: change > 0
                            ? Colors.green.shade600
                            : Colors.black54,
                      ),
                    ),
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

class _ResumenRow extends StatelessWidget {
  final String label;
  final String value;
  const _ResumenRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────
//  Dialog: Búsqueda de Producto
// ─────────────────────────────────────────────────────────────────

class _ProductSearchDialog extends StatefulWidget {
  final PosController controller;
  const _ProductSearchDialog({required this.controller});

  @override
  State<_ProductSearchDialog> createState() => _ProductSearchDialogState();
}

class _ProductSearchDialogState extends State<_ProductSearchDialog> {
  int _selectedIndex = 0;
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _products => widget.controller.products;

  void _selectNext() {
    if (_products.isEmpty) return;
    setState(() => _selectedIndex = (_selectedIndex + 1) % _products.length);
  }

  void _selectPrev() {
    if (_products.isEmpty) return;
    setState(
      () => _selectedIndex =
          (_selectedIndex - 1 + _products.length) % _products.length,
    );
  }

  void _addSelected() {
    if (_products.isEmpty) return;
    final idx = _selectedIndex.clamp(0, _products.length - 1);
    final product = _products[idx];
    final stock = ((product['stock'] as num?)?.toInt()) ?? 0;
    if (stock <= 0) return;
    widget.controller.addToCart(product);
    Navigator.pop(context);
  }

  void _updateSearch(String v) {
    widget.controller.updateSearch(v);
    setState(() => _selectedIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): _selectNext,
        const SingleActivator(LogicalKeyboardKey.arrowUp): _selectPrev,
        const SingleActivator(LogicalKeyboardKey.enter): _addSelected,
      },
      child: Focus(
        autofocus: true,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 580,
            height: 600,
            child: Column(
              children: [
                // ── Título
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                  child: Row(
                    children: [
                      const Text(
                        'Buscar Producto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // ── Campos de búsqueda
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _codeController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText:
                              'Buscar por código, código auxiliar o código de barras...',
                          prefixIcon: Icon(Icons.search),
                          border: UnderlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: _updateSearch,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                hintText: 'Buscar por Producto...',
                                prefixIcon: Icon(Icons.search, size: 18),
                                border: UnderlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: _updateSearch,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _descController,
                              decoration: const InputDecoration(
                                hintText: 'Buscar por Descripción...',
                                prefixIcon: Icon(Icons.search, size: 18),
                                border: UnderlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: _updateSearch,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ── Barra de navegación
                Consumer<PosController>(
                  builder: (ctx, ctrl, _) => Container(
                    margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.keyboard_arrow_up, size: 20),
                          onPressed: _selectPrev,
                          tooltip: 'Anterior',
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                          onPressed: _selectNext,
                          tooltip: 'Siguiente',
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Use las flechas para navegar, Enter para seleccionar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            ctrl.products.isEmpty
                                ? '0/0'
                                : '${_selectedIndex + 1}/${ctrl.products.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Lista de productos
                Expanded(
                  child: Consumer<PosController>(
                    builder: (ctx, ctrl, _) {
                      if (ctrl.isLoading && ctrl.products.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (ctrl.products.isEmpty) {
                        return const Center(
                          child: Text('No se encontraron productos'),
                        );
                      }
                      final safeIndex = _selectedIndex.clamp(
                        0,
                        ctrl.products.length - 1,
                      );
                      final selectedProduct = ctrl.products[safeIndex];

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              itemCount: ctrl.products.length,
                              itemBuilder: (_, index) {
                                final product = ctrl.products[index];
                                final stock =
                                    ((product['stock'] as num?)?.toInt()) ?? 0;
                                final price =
                                    ((product['price'] as num?)?.toDouble()) ??
                                    0;
                                final isSelected = index == safeIndex;

                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedIndex = index),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue.shade50
                                          : Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.blue.shade300
                                            : Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product['name']?.toString() ??
                                                    '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: isSelected
                                                      ? Colors.blue.shade800
                                                      : Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                'Código: ${product['sku']?.toString() ?? ''}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              Text(
                                                'Precio: \$${price.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green.shade700,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                'Stock: $stock',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: stock <= 2
                                                      ? Colors.red
                                                      : Colors.green.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          CircleAvatar(
                                            backgroundColor:
                                                Colors.blue.shade600,
                                            radius: 16,
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          )
                                        else
                                          GestureDetector(
                                            onTap: stock > 0
                                                ? () {
                                                    ctrl.addToCart(product);
                                                    Navigator.pop(context);
                                                  }
                                                : null,
                                            child: CircleAvatar(
                                              backgroundColor: stock > 0
                                                  ? Colors.green.shade600
                                                  : Colors.grey.shade400,
                                              radius: 16,
                                              child: const Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // ── Panel de detalle del producto seleccionado
                          Container(
                            margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Descripción:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  selectedProduct['description']?.toString() ??
                                      selectedProduct['name']?.toString() ??
                                      '',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      'Precio de Venta: \$${((selectedProduct['price'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Text(
                                      'Stock Disponible: ${((selectedProduct['stock'] as num?)?.toInt()) ?? 0}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // ── Acciones
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _addSelected,
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: const Text('Agregar Producto'),
                      ),
                    ],
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

// ─────────────────────────────────────────────────────────────────
//  Diálogo: Búsqueda de Cliente
// ─────────────────────────────────────────────────────────────────

class _ClientSearchDialog extends StatefulWidget {
  final PosController controller;
  const _ClientSearchDialog({required this.controller});

  @override
  State<_ClientSearchDialog> createState() => _ClientSearchDialogState();
}

class _ClientSearchDialogState extends State<_ClientSearchDialog> {
  String _query = '';
  String _searchBy = 'Nombre';
  final _searchByOptions = ['Nombre', 'Cédula / RUC', 'Teléfono'];

  List<Map<String, dynamic>> get _filtered {
    final q = _query.toLowerCase().trim();
    if (q.isEmpty) return widget.controller.customers;
    return widget.controller.customers.where((c) {
      switch (_searchBy) {
        case 'Cédula / RUC':
          return (c['cedula']?.toString() ?? '').toLowerCase().contains(q);
        case 'Teléfono':
          return (c['phone']?.toString() ?? '').toLowerCase().contains(q);
        default:
          return (c['name']?.toString() ?? '').toLowerCase().contains(q);
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 520,
        height: 540,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Cabecera
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
              child: Row(
                children: [
                  const Text(
                    'Buscar Cliente',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // ── Buscar por
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: Row(
                children: [
                  const Text(
                    'Buscar por: ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  DropdownButton<String>(
                    value: _searchBy,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                    items: _searchByOptions
                        .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null)
                        setState(() {
                          _searchBy = v;
                          _query = '';
                        });
                    },
                  ),
                ],
              ),
            ),
            // ── Campo de búsqueda
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Ingrese criterio de búsqueda',
                  prefixIcon: Icon(Icons.search, size: 20),
                  border: UnderlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 8),
            // ── Lista
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                children: [
                  // Consumidor final
                  GestureDetector(
                    onTap: () {
                      widget.controller.selectCustomer(null);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 18,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Consumidor final',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Icon(
                            Icons.check,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...filtered.map((c) {
                    final name = c['name']?.toString() ?? '';
                    final cedula = c['cedula']?.toString();
                    return GestureDetector(
                      onTap: () {
                        widget.controller.selectCustomer(
                          (c['id'] as num).toInt(),
                        );
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (cedula != null && cedula.isNotEmpty)
                                    Text(
                                      'Cédula: $cedula',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.check,
                              color: Colors.green.shade600,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (filtered.isEmpty && _query.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'No se encontraron clientes',
                          style: TextStyle(color: Colors.black45),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // ── Cancelar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Cancelar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Tab: Historial de Ventas
// ─────────────────────────────────────────────────────────────────

class _SalesHistoryTab extends StatelessWidget {
  const _SalesHistoryTab();

  // Nombres de los meses
  static const _months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<PosController>(
      builder: (context, controller, _) {
        final currentYear = DateTime.now().year;
        final years = List.generate(currentYear - 2019, (i) => currentYear - i);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ════════════════════════════════════════════════════
            //  Cabecera: título + botón Actualizar
            // ════════════════════════════════════════════════════
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  const Text(
                    'Historial de Ventas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: controller.loadSalesHistory,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Actualizar'),
                  ),
                ],
              ),
            ),

            // ════════════════════════════════════════════════════
            //  Panel de filtros
            // ════════════════════════════════════════════════════
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtros de Búsqueda',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // ── Año
                      Expanded(
                        child: _FilterDropdown<int?>(
                          label: 'Año:',
                          value: controller.historyYear,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Todos los años'),
                            ),
                            ...years.map(
                              (y) => DropdownMenuItem(
                                value: y,
                                child: Text(y.toString()),
                              ),
                            ),
                          ],
                          onChanged: controller.setHistoryYear,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // ── Mes
                      Expanded(
                        child: _FilterDropdown<int?>(
                          label: 'Mes:',
                          value: controller.historyMonth,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Todos'),
                            ),
                            ...List.generate(
                              12,
                              (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text(_months[i]),
                              ),
                            ),
                          ],
                          onChanged: controller.historyYear == null
                              ? null
                              : controller.setHistoryMonth,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // ── Día
                      Expanded(
                        child: _FilterDropdown<int?>(
                          label: 'Día:',
                          value: controller.historyDay,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Todos'),
                            ),
                            ...List.generate(
                              31,
                              (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text((i + 1).toString()),
                              ),
                            ),
                          ],
                          onChanged: controller.historyMonth == null
                              ? null
                              : controller.setHistoryDay,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Spacer(),
                      if (controller.historyYear != null ||
                          controller.historyMonth != null ||
                          controller.historyDay != null ||
                          controller.historyCustomerId != null)
                        TextButton.icon(
                          onPressed: controller.clearHistoryFilters,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text(
                            'Limpiar Filtros',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Text(
                        'Mostrando: ${controller.salesHistory.length} de ${controller.totalSalesCount} ventas',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ════════════════════════════════════════════════════
            //  Lista de ventas
            // ════════════════════════════════════════════════════
            Expanded(
              child: controller.salesHistory.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.black26,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No hay ventas registradas',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: controller.salesHistory.length,
                      itemBuilder: (context, index) {
                        final sale = controller.salesHistory[index];
                        final saleId = (sale['id'] as num).toInt();
                        final date = DateTime.tryParse(
                          sale['date']?.toString() ?? '',
                        );
                        final total =
                            (sale['total'] as num?)?.toDouble() ?? 0.0;
                        final clientName =
                            sale['client_name']?.toString() ??
                            'Consumidor final';
                        final storeName = sale['store_name']?.toString() ?? '';
                        final paymentName = sale['payment_method_name']
                            ?.toString();

                        // Número de NV formateado
                        final nvNum = saleId.toString().padLeft(3, '0');
                        final nvLabel = 'NV\n#$nvNum';

                        return _SaleHistoryCard(
                          saleId: saleId,
                          nvLabel: nvLabel,
                          clientName: clientName,
                          storeName: storeName,
                          date: date,
                          total: total,
                          paymentName: paymentName,
                          onTap: () =>
                              _showSaleDetail(context, controller, saleId),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSaleDetail(
    BuildContext context,
    PosController controller,
    int saleId,
  ) async {
    final items = await controller.getSaleItems(saleId);
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => _SaleDetailDialog(saleId: saleId, items: items),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Widget: Dropdown de filtro con label superior
// ─────────────────────────────────────────────────────────────────

class _FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: onChanged == null ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
              items: items,
              onChanged: onChanged,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: onChanged == null ? Colors.grey : Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Widget: Card de cada venta en el historial
// ─────────────────────────────────────────────────────────────────

class _SaleHistoryCard extends StatelessWidget {
  final int saleId;
  final String nvLabel;
  final String clientName;
  final String storeName;
  final DateTime? date;
  final double total;
  final String? paymentName;
  final VoidCallback onTap;

  const _SaleHistoryCard({
    required this.saleId,
    required this.nvLabel,
    required this.clientName,
    required this.storeName,
    required this.date,
    required this.total,
    required this.paymentName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = date != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(date!)
        : '';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar circular con número NV
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'NV\n#${saleId.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // ── Datos principales
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título: Nota de Venta #001-001-XXXXXX
                    Text(
                      'Nota de Venta #001-001-${saleId.toString().padLeft(9, '0')}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Cliente
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Colors.black45,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Cliente: ${clientName.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Fecha
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Colors.black45,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Fecha: $dateStr',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    if (paymentName != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.payment_outlined,
                            size: 14,
                            color: Colors.black45,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            paymentName!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Badge Total
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        'Total: \$${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Menú de opciones
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.black45),
                onPressed: onTap,
                tooltip: 'Ver detalle',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Widget: Dialog de detalle de venta
// ─────────────────────────────────────────────────────────────────

class _SaleDetailDialog extends StatelessWidget {
  final int saleId;
  final List<Map<String, dynamic>> items;

  const _SaleDetailDialog({required this.saleId, required this.items});

  @override
  Widget build(BuildContext context) {
    double grandTotal = 0;
    for (final item in items) {
      grandTotal +=
          ((item['quantity'] as num?)?.toInt() ?? 0) *
          ((item['price'] as num?)?.toDouble() ?? 0);
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Cabecera del dialog
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Nota de Venta #001-001-${saleId.toString().padLeft(9, '0')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),
            // ── Lista de productos
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No hay productos en esta venta.',
                    style: TextStyle(color: Colors.black45),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 380),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final item = items[index];
                    final qty = (item['quantity'] as num?)?.toInt() ?? 0;
                    final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                    final subtotal = qty * price;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '$qty',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['product_name']?.toString() ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Precio unitario: \$${price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            // ── Total
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '\$${grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            // ── Botón cerrar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.black54),
                  child: const Text('Cerrar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
