import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  String _amount = "0";

  void _onNumpadPressed(String value) {
    setState(() {
      if (_amount == "0" && value != "0") {
        _amount = value;
      } else if (_amount != "0") {
        _amount += value;
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
      } else {
        _amount = "0";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Display Amount Area
          Expanded(
            flex: 2,
            child: Container(
              color: theme.colorScheme.primaryContainer,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Rp $_amount',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          
          // Numpad Area
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildNumpadRow(['1', '2', '3']),
                  _buildNumpadRow(['4', '5', '6']),
                  _buildNumpadRow(['7', '8', '9']),
                  _buildNumpadRow(['.', '0', 'DEL']),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement save
                      },
                      child: const Text('Lanjutkan', style: TextStyle(fontSize: 18)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNumpadRow(List<String> items) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items.map((item) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: item == 'DEL'
                ? IconButton(
                    onPressed: _onDeletePressed,
                    icon: const Icon(Icons.backspace_outlined, size: 28),
                  )
                : TextButton(
                    onPressed: () => _onNumpadPressed(item),
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

