import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/features/simulation/presentation/controllers/simulation_controller.dart';
import 'package:egx/features/simulation/presentation/widgets/transaction_history_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionHistoryPage extends GetView<SimulationController> {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          toolbarHeight: 80,
          backgroundColor: context.background,
          elevation: 0,
          leadingWidth: 80,
          leading: Center(
            child: Container(
              margin: const EdgeInsets.only(left: 0.0),
              decoration: BoxDecoration(
                color: context.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.primary.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          title: Text(
            context.s.sim_transaction_history,
            style: TextStyle(
              color: context.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: const TransactionHistoryList(),
    );
  }
}
