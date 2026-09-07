import 'package:bazarnicole/Presentation/Controller/customers_controller.dart';
import 'package:bazarnicole/Presentation/Utils/Colors.dart';
import 'package:bazarnicole/Presentation/Widgets/Products/shared_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CustomersView extends StatefulWidget {
  const CustomersView({super.key});

  @override
  State<CustomersView> createState() => _CustomersViewState();
}

class _CustomersViewState extends State<CustomersView>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _idController = TextEditingController();
  final _addressController = TextEditingController();
  final _referencesController = TextEditingController();
  final _uuidController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomersController>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _idController.dispose();
    _addressController.dispose();
    _referencesController.dispose();
    _uuidController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<CustomersController>();
    try {
      final uid = await controller.createCustomer(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        notes: _notesController.text,
        apellidos: _lastNameController.text,
        cedula: _idController.text,
        address: _addressController.text,
        referencias: _referencesController.text,
      );

      _nameController.clear();
      _lastNameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _idController.clear();
      _addressController.clear();
      _referencesController.clear();
      _uuidController.text = uid;
      _notesController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente registrado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryLogo,
        foregroundColor: AppColors.whiteOverlay,
        title: const Text('Clientes · CRM'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.whiteOverlay,
          indicatorWeight: 3,
          labelColor: AppColors.whiteOverlay,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.person_add_alt_1), text: "Registrar"),
            Tab(icon: Icon(Icons.history), text: "Buscar / Historial"),
          ],
        ),
      ),
      body: Consumer<CustomersController>(
        builder: (context, controller, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              const IgnorePointer(
                child: CustomPaint(painter: _CustomerBackgroundPainter()),
              ),
              TabBarView(
                controller: _tabController,
                children: [
                  /// TAB 1
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 580),
                        child: SizedBox(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Center(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: 88,
                                          height: 88,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              CircleAvatar(
                                                radius: 42,
                                                backgroundColor:
                                                    AppColors.whiteOverlay,
                                                child: Icon(
                                                  Icons.person_outline,
                                                  size: 48,
                                                  color: AppColors.primaryLogo,
                                                ),
                                              ),
                                              Positioned(
                                                right: 0,
                                                bottom: 3,
                                                child: Container(
                                                  width: 28,
                                                  height: 28,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppColors.primaryLogo,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: AppColors
                                                          .whiteOverlay,
                                                      width: 3,
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.add,
                                                    size: 17,
                                                    color:
                                                        AppColors.whiteOverlay,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Registrar cliente',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryLogo,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Agrega un nuevo cliente a tu sistema',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.mediumGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isTwoColumns =
                                          constraints.maxWidth >= 520;
                                      final fieldWidth = isTwoColumns
                                          ? (constraints.maxWidth - 14) / 2
                                          : constraints.maxWidth;

                                      return Wrap(
                                        spacing: 14,
                                        runSpacing: 14,
                                        children: [
                                          SizedBox(
                                            width: fieldWidth,
                                            child: SharedTextFormField(
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                              controller: _nameController,
                                              label: 'Nombre completo',
                                              prefixIcon: const Icon(
                                                Icons.person_outline,
                                              ),
                                              validator: (value) =>
                                                  value == null ||
                                                      value.trim().isEmpty
                                                  ? 'Ingresa el nombre'
                                                  : null,
                                            ),
                                          ),
                                          SizedBox(
                                            width: fieldWidth,
                                            child: SharedTextField(
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                              controller: _lastNameController,
                                              label: 'Apellidos',
                                              prefixIcon: const Icon(
                                                Icons.person_outline,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: fieldWidth,
                                            child: SharedTextField(
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                              controller: _phoneController,
                                              label: 'Teléfono',
                                              prefixIcon: const Icon(
                                                Icons.phone_outlined,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: fieldWidth,
                                            child: SharedTextField(
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                              controller: _emailController,
                                              label: 'Correo',
                                              prefixIcon: const Icon(
                                                Icons.email_outlined,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: fieldWidth,
                                            child: SharedTextField(
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                              controller: _idController,
                                              label: 'Cédula',
                                              prefixIcon: const Icon(
                                                Icons.badge_outlined,
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                          SizedBox(
                                            width: fieldWidth,
                                            child: SharedTextField(
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                              controller: _addressController,
                                              label: 'Dirección',
                                              prefixIcon: const Icon(
                                                Icons.location_on_outlined,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: fieldWidth,
                                            child: SharedTextField(
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                              controller: _referencesController,
                                              label: 'Referencias',
                                              prefixIcon: const Icon(
                                                Icons.bookmark_border,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: fieldWidth,
                                            child: SharedTextField(
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: AppColors.mediumGray,
                                              ),
                                              controller: _uuidController,
                                              label: 'Código (UUID)',
                                              hint: 'Se genera automáticamente',
                                              helperText:
                                                  'Generado automáticamente · Solo lectura',
                                              prefixIcon: const Icon(
                                                Icons.fingerprint,
                                              ),
                                              suffixIcon: const Icon(
                                                Icons.lock_outline,
                                                size: 18,
                                                color: AppColors.mediumGray,
                                              ),
                                              readOnly: true,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: FilledButton.icon(
                                      onPressed: _saveCustomer,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: AppColors.whiteOverlay,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(Icons.person_add_alt_1),
                                      label: const Text('Guardar cliente'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: .1),
                  ),

                  /// TAB 2
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;

                      final listPanel = Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SharedTextField(
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              controller: _searchController,
                              hint:
                                  'Buscar cliente por nombre, correo o teléfono',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        controller.loadCustomers();
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.clear),
                                    ),
                              useFilterStyle: true,
                              onChanged: (value) {
                                setState(() {});
                                controller.loadCustomers(searchValue: value);
                              },
                            ),
                            const SizedBox(height: 2),
                            Expanded(
                              child:
                                  controller.isLoading &&
                                      controller.customers.isEmpty
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : ListView.separated(
                                      itemCount: controller.customers.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final customer =
                                            controller.customers[index];
                                        final isSelected =
                                            controller
                                                .selectedCustomer?['id'] ==
                                            customer['id'];
                                        return ListTile(
                                          selected: isSelected,
                                          leading: const CircleAvatar(
                                            child: Icon(Icons.person_outline),
                                          ),
                                          title: Text(
                                            customer['name']?.toString() ?? '',
                                          ),
                                          subtitle: Text(
                                            '${customer['phone'] ?? 'Sin teléfono'} · ${customer['email'] ?? 'Sin correo'}',
                                          ),
                                          onTap: () => controller
                                              .selectCustomer(customer),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      );

                      final historyPanel = SizedBox(
                        width: isWide ? 340 : double.infinity,
                        child: Card(
                          color: AppColors.lightGray,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Ver historial',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (controller.selectedCustomer == null)
                                  const Text(
                                    'Selecciona un cliente para ver sus compras.',
                                  )
                                else ...[
                                  Text(
                                    controller.selectedCustomer!['name']
                                        .toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 260,
                                    child: controller.history.isEmpty
                                        ? const Text(
                                            'Todavía no registra ventas.',
                                          )
                                        : ListView.separated(
                                            itemCount:
                                                controller.history.length,
                                            separatorBuilder: (_, __) =>
                                                const Divider(),
                                            itemBuilder: (context, index) {
                                              final sale =
                                                  controller.history[index];
                                              final date = DateTime.tryParse(
                                                sale['date']?.toString() ?? '',
                                              );
                                              return ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                title: Text(
                                                  'Venta #${sale['id']}',
                                                ),
                                                subtitle: Text(
                                                  '${sale['store_name']} · ${date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : ''}',
                                                ),
                                                trailing: Text(
                                                  '\$${((sale['total'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 16),
                                  Expanded(child: listPanel)
                                      .animate()
                                      .fadeIn(delay: 150.ms, duration: 400.ms)
                                      .slideY(
                                        begin: 0.1,
                                        end: 0,
                                        delay: 150.ms,
                                        duration: 400.ms,
                                        curve: Curves.easeOut,
                                      ),
                                  const SizedBox(width: 16),
                                  historyPanel
                                      .animate()
                                      .fadeIn(delay: 250.ms, duration: 400.ms)
                                      .slideX(
                                        begin: 0.1,
                                        end: 0,
                                        delay: 250.ms,
                                        duration: 400.ms,
                                        curve: Curves.easeOut,
                                      ),
                                ],
                              )
                            : ListView(
                                children: [
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 340,
                                    child: listPanel
                                        .animate()
                                        .fadeIn(delay: 150.ms, duration: 400.ms)
                                        .slideY(
                                          begin: 0.1,
                                          end: 0,
                                          delay: 150.ms,
                                          duration: 400.ms,
                                          curve: Curves.easeOut,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  historyPanel
                                      .animate()
                                      .fadeIn(delay: 250.ms, duration: 400.ms)
                                      .slideY(
                                        begin: 0.1,
                                        end: 0,
                                        delay: 250.ms,
                                        duration: 400.ms,
                                        curve: Curves.easeOut,
                                      ),
                                ],
                              ),
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CustomerBackgroundPainter extends CustomPainter {
  const _CustomerBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final diagonalPaint = Paint()
      ..color = AppColors.primaryBlue.withValues(alpha: .045)
      ..style = PaintingStyle.fill;
    final accentPaint = Paint()
      ..color = AppColors.accentColor.withValues(alpha: .08)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = AppColors.primaryLogo.withValues(alpha: .07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final patternPaint = Paint()
      ..color = AppColors.primaryBlue.withValues(alpha: .055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final upperShape = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height * .28)
      ..lineTo(size.width * .72, 0)
      ..close();
    canvas.drawPath(upperShape, diagonalPaint);

    final lowerShape = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * .72)
      ..lineTo(size.width * .28, size.height)
      ..close();
    canvas.drawPath(lowerShape, accentPaint);

    final stripeWidth = size.width * .34;
    for (var index = 0; index < 3; index++) {
      final offset = index * 18.0;
      final stripe = Path()
        ..moveTo(size.width - stripeWidth + offset, 0)
        ..lineTo(size.width + offset, 0)
        ..lineTo(size.width - size.height * .18 + offset, size.height * .18)
        ..lineTo(size.width - stripeWidth + offset, size.height * .18)
        ..close();
      canvas.drawPath(stripe, diagonalPaint);
    }

    final shapeWidth = size.width < 520 ? size.width * .34 : 220.0;
    final shapeHeight = size.height < 700 ? 150.0 : 190.0;
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width - shapeWidth - 28,
        size.height * .22,
        shapeWidth,
        shapeHeight,
      ),
      const Radius.circular(22),
    );
    canvas.drawRRect(cardRect, patternPaint);

    final cardLeft = cardRect.left + 20;
    final cardRight = cardRect.right - 20;
    for (var index = 0; index < 4; index++) {
      final lineY = cardRect.top + 38 + (index * 23);
      canvas.drawLine(
        Offset(cardLeft, lineY),
        Offset(cardRight - (index.isEven ? 16 : 42), lineY),
        patternPaint,
      );
    }

    final plusPaint = Paint()
      ..color = AppColors.accentColor.withValues(alpha: .16)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final point in [
      Offset(size.width * .12, size.height * .18),
      Offset(size.width * .86, size.height * .78),
    ]) {
      canvas.drawLine(
        Offset(point.dx - 7, point.dy),
        Offset(point.dx + 7, point.dy),
        plusPaint,
      );
      canvas.drawLine(
        Offset(point.dx, point.dy - 7),
        Offset(point.dx, point.dy + 7),
        plusPaint,
      );
    }

    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        -size.width * .08,
        size.height * .08,
        size.width * 1.16,
        size.height * .84,
      ),
      const Radius.circular(34),
    );
    canvas.drawRRect(frame, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
