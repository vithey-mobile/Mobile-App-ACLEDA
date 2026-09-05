import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class EditAccountSaveButton extends StatelessWidget {
  const EditAccountSaveButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        label: 'Save',
        isLoading: isLoading,
        onPressed: onPressed,
      ),
    );
  }
}
