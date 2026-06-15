import 'package:bazarnicole/Presentation/Context/pos_sale_provider.dart';
import 'package:bazarnicole/Presentation/Utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────
//  Widget: Resumen de Venta
// ─────────────────────────────────────────────────────────────────

class PosResumenVentaCard extends StatelessWidget {
  final double subtotal;

  const PosResumenVentaCard({
    super.key,
    required this.subtotal,
  });

  @override
  Widget build(BuildContext context) {
    final sale = context.watch<PosSaleProvider>();
    final total = sale.effectiveTotal(subtotal);
    final received = sale.receivedAmount();
    final change = received - total;

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
                        controller: sale.discountController,
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
                        onChanged: context.read<PosSaleProvider>().setDiscount,
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
                        controller: sale.transportController,
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
                        onChanged: context.read<PosSaleProvider>().setTransport,
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
                        controller: sale.receivedController,
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
                        onChanged: context.read<PosSaleProvider>().onReceivedChanged,
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

// ── Fila de resumen reutilizable
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
