import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/dashborder/controller/auth_controller.dart';
import 'package:dashboard/dashborder/controller/data_heper_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dashboard/data/models/user_model/user_hive.dart';

class UserController with ChangeNotifier {
  final DatabaseHelperUser _databaseHelperUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Box<UserHive>? _usersBox;
  AuthController? _authController;
  UserHive? _currentUser;
  bool _isDisposed = false; // لتتبع حالة الـ dispose
  // دالة آمنة لإشعار المستمعين
  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
  List<UserHive> usersList = [];
  UserHive usersListFire = UserHive(
    id: '',
    name: '',
    email: '',
    role: '',
    status: '',
    registrationDate: '',
    phoneNumber: '',
    address: '',
    permissions: {},
    password: '',
  );

  UserController(this._databaseHelperUser) {
    init();
  }

  // إضافة دالة لربط AuthController
  void setAuthController(AuthController authController) {
    _authController = authController;
    _authController?.addListener(_onAuthStateChanged);
  }

  // الحصول على المستخدم الحالي
  UserHive? get currentUser => _currentUser;

  List<UserHive> get users => usersList;
  UserHive get usersFire => usersListFire;
  int get totalUser => users.length;
  List<String> get nameuser => users.map((u) => u.id).toList();

  // تحديث عند تغيير حالة المصادقة
  void _onAuthStateChanged() async {
    if (_authController?.currentUserId != null) {
      await loadUser(_authController!.currentUserId!);

      // إذا كان المستخدم مديراً، قم بتحميل جميع المستخدمين
      if (_currentUser?.role == 'مدير') {
        await fetchUsersFromServer(loadAllUsers: true);
      } else {
        // إذا كان مستخدم عادي، قم بمسح قائمة المستخدمين (لا نحتاجها)
        usersList.clear();
        _safeNotify();
      }
    } else {
      _currentUser = null;
      _safeNotify();
    }
  }

  Future<void> init() async {
    _usersBox = await Hive.openBox<UserHive>('usersBox');
    await addDefaultUser();
  }

  // دالة محسنة لتحميل مستخدم معين
  Future<void> loadUser(String userId) async {
    try {
      if (_usersBox == null) {
        await init();
      }

      // 1. تحميل من Firestore
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _currentUser = UserHive(
          id: userId,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          role: data['role'] ?? '',
          status: data['status'] ?? '',
          registrationDate: data['registrationDate'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          address: data['address'] ?? '',
          permissions: Map<String, bool>.from(data['permissions'] ?? {}),
          password: '',
        );

        // 2. حفظ في Hive
        await _usersBox?.put(userId, _currentUser!);
        _safeNotify();
      }
    } catch (e) {
      print('Error loading user: $e');
      rethrow;
    }
  }

  UserHive? getUserById(String userId) {
    if (_usersBox == null) {
      return UserHive.empty();
    }

    // البحث في usersList أولاً
    final userFromList = usersList.firstWhere(
      (user) => user.id == userId,
      orElse: () => UserHive.empty(),
    );

    if (userFromList.id.isNotEmpty) {
      return userFromList;
    }

    // إذا لم يتم العثور عليه في usersList، ابحث في Hive
    final userFromHive = _usersBox?.get(userId);
    if (userFromHive != null) {
      // إضافة المستخدم إلى usersList
      if (!usersList.any((user) => user.id == userId)) {
        usersList.add(userFromHive);
      }
      return userFromHive;
    }

    // إذا لم يتم العثور عليه في أي مكان
    return UserHive.empty();
  }

  Future<void> addDefaultUser() async {
    if (_usersBox == null || _usersBox!.isEmpty) {
      final defaultUser = UserHive(
        id: '1',
        name: 'admin',
        email: 'admin@gmail.com',
        role: 'مدير',
        status: 'نشط',
        registrationDate: DateTime.now().toIso8601String(),
        phoneNumber: '123456789',
        address: 'المكتب الرئيسي',
        permissions: {
          'إضافة مستخدم': true,
          'حذف مستخدم': true,
          'تعديل مستخدم': true,
          'عرض الإحصائيات': true,
          'إضافة شحنة': true,
          'تعديل شحنة': true,
          'حذف شحنة': true,
          'تتبع الشحنة': true,
          'إضافة طلب': true,
          'تعديل طلب': true,
          'حذف طلب': true,
        },
        password: '775479401H',
        profileImage: 'assets/DeliveryTruckLoading.png',
      );

      await _usersBox?.put(defaultUser.id, defaultUser);
      await _firestore
          .collection('users')
          .doc(defaultUser.id)
          .set(defaultUser.toJson());
    }
  }

  void loadUsersFromHive(
      {required String? currentUserId, required String currentUserRole}) async {
    if (currentUserRole == 'مدير') {
      // تحميل جميع المستخدمين من Firebase
      final firebaseSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      final firebaseUsers = firebaseSnapshot.docs.map((doc) {
        final data = doc.data();
        return UserHive.fromJson(data);
      }).toList();

      // مزامنة مع Hive
      await _usersBox?.clear();
      for (var user in firebaseUsers) {
        await _usersBox?.put(user.id, user);
      }

      // تحديث القائمة
      final updatedUsers = _usersBox?.values.toList();
      if (usersList.length != updatedUsers?.length ||
          !_listsEqual(usersList, updatedUsers!)) {
        usersList = updatedUsers!;
        _safeNotify();
      }
    } else {
      // تحميل المستخدم الحالي فقط من Firebase
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (doc.exists) {
        final user = UserHive.fromJson(doc.data()!);

        // تحديث Hive
        await _usersBox?.put(user.id, user);

        // تحديث القائمة
        final updatedUsers = [user];
        if (usersList.length != 1 || usersList.first.id != user.id) {
          usersList = updatedUsers;
          _safeNotify();
        }
      }
    }
  }

// دالة لمقارنة قائمتين من المستخدمين
  bool _listsEqual(List<UserHive> a, List<UserHive> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i] != b[i]) return false;
    }
    return true;
  }

  void saveUsersToHive() {
    for (var user in usersList) {
      _usersBox?.put(user.id, user);
    }
    _safeNotify();
  }

  Future<void> linkShipmentsToUser(String userId, String phone) async {
    final firestore = FirebaseFirestore.instance;

    // البحث عن الشحنات المرتبطة برقم الهاتف
    final queryByPhone = await firestore
        .collection('parcel')
        .where('receiverPhone', isEqualTo: phone)
        .get();

    for (var doc in queryByPhone.docs) {
      final data = doc.data();
      final currentUsers = List<String>.from(data['userIds'] ?? []);

      // إذا لم يكن المستخدم مضافًا من قبل، قم بإضافته
      if (!currentUsers.contains(userId)) {
        currentUsers.add(userId);
        await firestore.collection('parcel').doc(doc.id).update({
          'userIds': currentUsers,
        });
      }
    }
  }

  Future<void> addUser(UserHive user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
      await linkShipmentsToUser(user.id, user.phoneNumber);
      usersList.add(user);
      _usersBox?.put(user.id, user);
      print('you add user');
      notifyListeners();
    } catch (e) {
      print('❌ خطأ في إضافة المستخدم: $e');
    }
  }

  Future<void> updateUser(String userId, UserHive updatedUser) async {
    final index = users.indexWhere((u) => u.id == userId);

    if (index == -1) {
      print('⚠️ المستخدم غير موجود.');
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update(updatedUser.toJson());

      final firebaseUser = _auth.currentUser;
      final currentUser = getUserById(userId);

      if (firebaseUser != null &&
          currentUser != null &&
          firebaseUser.uid == currentUser.id) {
        if (firebaseUser.email != updatedUser.email) {
          await firebaseUser.updateEmail(updatedUser.email);
        }

     
        print('✅ تم تحديث بيانات FirebaseAuth بنجاح');
      }

      users[index] = updatedUser;
      _usersBox?.put(userId, updatedUser);
      _safeNotify();

      print('✅ تم تحديث المستخدم بنجاح.');
    } catch (e) {
      print('❌ خطأ أثناء تحديث المستخدم أو FirebaseAuth: $e');
    }
  }

  Future<void> clearAllUser() async {
    await _usersBox?.clear();
    _safeNotify();
  }

  Future<void> clearUsersCache() async {
    await _usersBox?.clear();
    await fetchUsersFromServer(loadAllUsers: _currentUser?.role == 'مدير');
  }

  Future<void> deleteWithReauth(String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && user.email != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );

        await user.reauthenticateWithCredential(credential);
        await deleteUserCompletely();
        _safeNotify();
      }
    } catch (e) {
      print('❌ فشلت إعادة المصادقة أو الحذف: $e');
      throw e;
    }
  }

  Future<void> deleteUserCompletely() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();

        await user.delete();
        print('✅ تم حذف المستخدم وبياناته بالكامل');
        _safeNotify();
      }
    } catch (e) {
      print('❌ خطأ في الحذف الكامل: $e');
      throw e;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
      usersList.removeWhere((user) => user.id == id);
      _usersBox?.delete(id);
      _safeNotify();
    } catch (e) {
      print('❌ خطأ في حذف المستخدم: $e');
    }
  }

  // دالة معدلة لجلب بيانات المستخدمين من Firebase مع التحكم في تحميل جميع البيانات
  Future<void> fetchUsersFromServer({bool loadAllUsers = false}) async {
    try {
      if (!loadAllUsers && _currentUser?.role != 'مدير') {
        // إذا لم يكن مديراً ولا نريد تحميل الجميع، نخرج من الدالة
        return;
      }

      final querySnapshot = await _firestore.collection('users').get();

      final users = querySnapshot.docs
          .map((doc) => UserHive.fromJson(doc.data()))
          .toList();

      for (var user in users) {
        _usersBox?.put(user.id, user);
      }

      usersList = users;
      notifyListeners();
      print("✅ بيانات المستخدمين تم تحميلها من Firebase إلى Hive بنجاح");
    } catch (e) {
      print("❌ فشل في جلب بيانات المستخدمين من Firebase: $e");
    }
  }
  @override
  void dispose() {
    _isDisposed = true;
    _authController?.removeListener(_onAuthStateChanged);
    super.dispose();
  }
  // دالة معدلة للاستماع للتحديثات في الوقت الحقيقي مع التحقق من الصلاحيات
  void setupRealtimeUpdates() {
    _firestore.collection('users').snapshots().listen((snapshot) {
      if (_currentUser?.role != 'مدير') {
        return; // لا تقم بالتحديث إذا لم يكن المستخدم مديراً
      }

      final users =
          snapshot.docs.map((doc) => UserHive.fromJson(doc.data())).toList();

      usersList = users;
      _safeNotify();
    });
  }
}
