class FacebookUser {
  final String userId;
  final String? name;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? email;
  final String? birthday;
  final Picture? picture;

  FacebookUser.fromMap(Map<String, dynamic> map)
      : userId = map['id'] as String,
        name = map['name'] as String?,
        firstName = map['first_name'] as String?,
        middleName = map['middle_name'] as String?,
        lastName = map['last_name'] as String?,
        email = map['email'] as String?,
        birthday = map['birthday'] as String?,
        picture =
            map['picture'] != null ? Picture.fromMap(map['picture']) : null;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'name': name,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'email': email,
      'birthday': birthday,
      'picture': picture?.toMap(),
    };
  }
}

class Picture {
  final Data? data;

  Picture.fromMap(Map<String, dynamic> map)
      : data = map['data'] != null
            ? Data.fromMap(map['data'] ?? <String, dynamic>{})
            : null;

  Map<String, dynamic> toMap() {
    final _map = <String, dynamic>{};
    if (data != null) {
      _map['data'] = data?.toMap();
    }
    return _map;
  }
}

class Data {
  final int? height;
  final int? width;
  final String? url;
  final bool? isSilhouette;

  Data.fromMap(Map<String, dynamic> map)
      : height = map['height'] as int?,
        width = map['width'] as int?,
        url = map['url'] as String?,
        isSilhouette = map['is_silhouette'] as bool?;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'height': height,
      'width': width,
      'url': url,
      'is_silhouette': isSilhouette,
    };
  }
}
