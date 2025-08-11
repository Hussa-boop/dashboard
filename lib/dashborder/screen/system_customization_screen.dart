import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/settings_controller.dart';

class SystemCustomizationScreen extends StatefulWidget {
  @override
  _SystemCustomizationScreenState createState() => _SystemCustomizationScreenState();
}

class _SystemCustomizationScreenState extends State<SystemCustomizationScreen> {
  late SettingsController settingsController;
  Color _selectedPrimaryColor = Colors.blue; // اللون الافتراضي
  String _selectedFont = 'Roboto'; // الخط الافتراضي

  @override
  void initState() {
    super.initState();
    settingsController = Provider.of<SettingsController>(context, listen: false);
    // _selectedPrimaryColor = settingsController.primaryColor;
    // _selectedFont = settingsController.selectedFont;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تخصيص النظام'),
        backgroundColor: _selectedPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('لون النظام الأساسي'),
            _buildColorPicker(),

            SizedBox(height: 20),

            _buildSectionHeader('اختر الخط'),
            _buildFontSelector(),

            SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: _saveCustomizations,
                style: ElevatedButton.styleFrom(
                  primary: _selectedPrimaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('حفظ التغييرات', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildColorPicker() {
    List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return Wrap(
      spacing: 10,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPrimaryColor = color;
            });
          },
          child: CircleAvatar(
            backgroundColor: color,
            radius: 20,
            child: _selectedPrimaryColor == color ? Icon(Icons.check, color: Colors.white) : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFontSelector() {
    List<String> fonts = ['Roboto', 'Arial', 'Cairo', 'Montserrat'];

    return DropdownButtonFormField<String>(
      value: _selectedFont,
      items: fonts.map((font) {
        return DropdownMenuItem(
          value: font,
          child: Text(font, style: TextStyle(fontFamily: font)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedFont = value!;
        });
      },
    );
  }

  void _saveCustomizations() {
    // settingsController.updateCustomization(_selectedPrimaryColor, _selectedFont);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ التغييرات بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
