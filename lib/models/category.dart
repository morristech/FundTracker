import 'package:flutter/material.dart';

class Category {
  String cid;
  String name;
  int icon;
  Color iconColor;
  bool enabled;
  bool unfiltered;
  int orderIndex;
  String uid;

  Category({
    this.cid,
    this.name,
    this.icon,
    this.iconColor,
    this.enabled,
    this.unfiltered,
    this.orderIndex,
    this.uid,
  });

  Category.empty(int numExistingCategories) {
    cid = null;
    name = null;
    icon = Icons.crop_original.codePoint;
    iconColor = Colors.black;
    enabled = true;
    unfiltered = true;
    orderIndex = numExistingCategories;
    uid = null;
  }

  Category.example() {
    cid = '';
    name = '';
    icon = 0;
    iconColor = Colors.black;
    enabled = true;
    unfiltered = false;
    orderIndex = 0;
    uid = '';
  }

  Category.fromMap(Map<String, dynamic> map) {
    this.cid = map['cid'];
    this.name = map['name'];
    this.icon = map['icon'];
    this.iconColor = map['iconColor'] is String
        ? Color(int.parse(map['iconColor']))
        : map['iconColor'];
    this.enabled = map['enabled'] == 1;
    this.unfiltered = map['unfiltered'] == 1;
    this.orderIndex = map['orderIndex'];
    this.uid = map['uid'];
  }

  Map<String, dynamic> toMap() {
    return {
      'cid': cid,
      'name': name,
      'icon': icon,
      'iconColor': '0X${iconColor.value.toRadixString(16).toUpperCase()}',
      'enabled': enabled ? 1 : 0,
      'unfiltered': unfiltered ? 1 : 0,
      'orderIndex': orderIndex,
      'uid': uid,
    };
  }

  Category setEnabled(bool enabled) {
    this.enabled = enabled;
    return this;
  }

  Category setUnfiltered(bool unfiltered) {
    this.unfiltered = unfiltered;
    return this;
  }

  Category setOrder(int orderIndex) {
    this.orderIndex = orderIndex;
    return this;
  }

  bool equalTo(Category category) {
    return (this.cid == category.cid &&
        this.name == category.name &&
        this.icon == category.icon &&
        this.iconColor == category.iconColor &&
        this.orderIndex == category.orderIndex &&
        this.uid == category.uid);
  }
}
