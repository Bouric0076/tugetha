import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TransactionData {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final String time;
  final String status;

  const TransactionData({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    required this.time,
    required this.status,
  });
}

class TransactionItem extends StatelessWidget {
  final TransactionData data;
  const TransactionItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greyLighter),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data.amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: data.amountColor,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                data.time,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}