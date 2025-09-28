import 'package:cric_live/utils/import_exports.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final TextCapitalization? textCapitalization;
  final String hintText;
  final String labelText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Function(String?)? onChanged;
  final Function()? onTap;
  final Function(String)? onFieldSubmitted;
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onTap,
    this.onFieldSubmitted,
    this.textCapitalization,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 15.0,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2.0,
          ),
        ),
        labelText: labelText,
      ),
      // Common validator can be passed in
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
