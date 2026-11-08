import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_motion.dart';
import 'package:pigeon/constants/app_colors.dart';

class SelectBankListSheet extends StatefulWidget {
  const SelectBankListSheet({super.key});

  @override
  State<SelectBankListSheet> createState() => _SelectBankListSheetState();
}

class _SelectBankListSheetState extends State<SelectBankListSheet> {
  String _query = '';

  static const List<String> _banks = <String>[
    'Access Bank',
    'FirstBank',
    'GTBank',
    'Kuda Microfinance Bank',
    'Moniepoint MFB',
    'Opay',
    'Palmpay',
    'United Bank for Africa',
    'Zenith Bank',
    'Accion Microfinance Bank',
    'Advans La Fayette Microfinance Bank',
    'Alternative Bank Limited',
    'Carbon - Digital Neobank / MFB',
    'Citibank Nigeria Limited',
    'Ecobank Nigeria Limited',
    'eTranzact International',
    'Fairmoney Microfinance Bank',
    'Fidelity Bank PLC',
    'First City Monument Bank',
    'Globus Bank Limited',
    'Hope Payment Service Bank',
    'Jaiz Bank PLC',
    'Keystone Bank Limited',
    'LAPO Microfinance Bank',
    'Lotus Bank Limited',
    'MoMO PSB',
    'MoneyMaster PSB',
    'NIRSAL Microfinance Bank',
    'Nova Commercial Bank',
    'NowNow Digital Systems',
    'Optimus Bank Limited',
    'Paga',
    'Parallax Limited',
    'Polaris Bank Limited',
    'PremiumTrust Bank',
    'Providus Bank Limited',
    'Signature Bank Limited',
    'SmartCash PSB',
    'Stanbic IBTC Bank PLC',
    'Standard Chartered Bank Nigeria',
    'Sterling Bank PLC',
    'Summit Bank',
    'SunTrust Bank Nigeria Limited',
    'TAJBank Limited',
    'Tatum Bank',
    'Titan Trust Bank',
    'Union Bank of Nigeria',
    'Unity Bank PLC',
    'VBank',
    'Wema Bank PLC',
  ];

  List<String> get _filteredBanks {
    if (_query.isEmpty) return _banks;
    final String q = _query.toLowerCase();
    return _banks.where((String b) => b.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = MediaQuery.of(context).size.height * 0.95;
    final List<String> banks = _filteredBanks;
    return SizedBox(
      height: sheetHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                height: 4,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDisabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Select Bank',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (String v) => setState(() => _query = v),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      cursorColor: AppColors.textPrimary,
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: 'Search bank',
                        hintStyle: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: banks.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (BuildContext context, int i) {
                  final String bank = banks[i];
                  return _BankRow(
                    name: bank,
                    onTap: () => Navigator.of(context).pop<String>(bank),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankRow extends StatelessWidget {
  const _BankRow({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textMuted, width: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> showSelectBankListSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    sheetAnimationStyle: AppMotion.sheet,
    backgroundColor: AppColors.background,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) => const SelectBankListSheet(),
  );
}
