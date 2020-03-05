import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/pages/categories/iconsList.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/services/sync.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CategoryForm extends StatefulWidget {
  final Category category;
  final int numExistingCategories;

  CategoryForm(this.category, this.numExistingCategories);

  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();

  String _name;
  int _icon;
  Color _iconColor;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);
    final isEditMode =
        !widget.category.equalTo(Category.empty(widget.numExistingCategories));

    return Scaffold(
      appBar: AppBar(
        title: title(isEditMode),
        actions: isEditMode
            ? <Widget>[
                deleteIcon(
                  context,
                  'custom category',
                  () => DatabaseWrapper(_user.uid)
                      .deleteCategories([widget.category]),
                  () => SyncService(_user.uid).syncCategories(),
                )
              ]
            : null, // add reset category here for defaults
      ),
      body: isLoading
          ? Loader()
          : Container(
              padding: formPadding,
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: widget.category.name,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter a name for this category.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Name',
                      ),
                      textCapitalization: TextCapitalization.words,
                      onChanged: (val) {
                        setState(() => _name = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    FlatButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Icon'),
                          Icon(
                            IconData(
                              widget.category.icon,
                              fontFamily: 'MaterialIcons',
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return IconsList();
                          },
                        );
                      },
                    ),
                    SizedBox(height: 20.0),
                    FlatButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Icon Color'),
                          Icon(
                            Icons.brightness_1,
                            color: _iconColor ?? widget.category.iconColor,
                          ),
                        ],
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return categoryColorPicker(
                              _iconColor ?? widget.category.iconColor,
                              callback: (val) =>
                                  setState(() => _iconColor = val),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 20.0),
                    Icon(
                      IconData(
                        widget.category.icon,
                        fontFamily: 'MaterialIcons',
                      ),
                      color: _iconColor ?? widget.category.iconColor,
                    ),
                    SizedBox(height: 20.0),
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      child: Text(
                        isEditMode ? 'Save' : 'Add',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          Category category = Category(
                            cid: widget.category.cid ?? Uuid().v1(),
                            name: _name ?? widget.category.name,
                            icon: _icon ?? widget.category.icon,
                            iconColor: _iconColor ?? widget.category.iconColor,
                            enabled: widget.category.enabled ?? true,
                            unfiltered: widget.category.unfiltered ?? true,
                            orderIndex: widget.category.orderIndex ??
                                widget.numExistingCategories,
                            uid: _user.uid,
                          );
                          setState(() => isLoading = true);
                          isEditMode
                              ? await DatabaseWrapper(_user.uid)
                                  .updateCategories([category])
                              : await DatabaseWrapper(_user.uid)
                                  .addCategories([category]);
                          SyncService(_user.uid).syncPeriods();
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget title(bool isEditMode) {
    return Text(isEditMode ? 'Edit Category' : 'Add Category');
  }
}

Widget categoryColorPicker(Color currentColor, {Function callback}) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Icon Color Picker'),
    ),
    body: Container(
      padding: formPadding,
      child: ColorPicker(
        pickerColor: currentColor,
        onColorChanged: (val) => callback(val),
        showLabel: true,
      ),
    ),
  );
}
