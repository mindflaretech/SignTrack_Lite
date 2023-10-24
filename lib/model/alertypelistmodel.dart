class AlertsListModel {
  AlertsListModel({
    required this.status,
    required this.items,
  });
  late final dynamic status;
  late final Items items;

  AlertsListModel.fromJson(Map<dynamic, dynamic> json) {
    status = json['status'];
    items = Items.fromJson(json['items']);
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['status'] = status;
    _data['items'] = items.toJson();
    return _data;
  }
}

class Items {
  Items({
    required this.alerts,
  });
  late final List<Alerts> alerts;

  Items.fromJson(Map<dynamic, dynamic> json) {
    alerts = List.from(json['alerts']).map((e) => Alerts.fromJson(e)).toList();
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['alerts'] = alerts.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Alerts {
  Alerts({
    required this.id,
    required this.userId,
    required this.active,
    required this.name,
    required this.type,
  });
  late final dynamic id;
  late final dynamic userId;
  late final dynamic active;
  late final dynamic name;
  late final dynamic type;

  Alerts.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    active = json['active'];
    name = json['name'];
    type = json['type'];

    //  eventsCustom = List.castFrom<dynamic, dynamic>(json['events_custom']);
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "active": active,
        "name": name,
        "type": type,
      };
}

class Notifications {
  Notifications({
    required this.sound,
    required this.autoHide,
    required this.push,
    required this.email,
    required this.webhook,
    required this.sharingEmail,
  });
  late final Sound sound;
  late final AutoHide autoHide;
  late final Push push;
  late final Email email;
  late final Webhook webhook;
  late final SharingEmail sharingEmail;

  Notifications.fromJson(Map<dynamic, dynamic> json) {
    sound = Sound.fromJson(json['sound']);
    autoHide = AutoHide.fromJson(json['auto_hide']);
    push = Push.fromJson(json['push']);
    email = Email.fromJson(json['email']);
    webhook = Webhook.fromJson(json['webhook']);
    sharingEmail = SharingEmail.fromJson(json['sharing_email']);
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['sound'] = sound.toJson();
    _data['auto_hide'] = autoHide.toJson();
    _data['push'] = push.toJson();
    _data['email'] = email.toJson();
    _data['webhook'] = webhook.toJson();
    _data['sharing_email'] = sharingEmail.toJson();
    return _data;
  }
}

class Sound {
  Sound({
    required this.active,
  });
  late final dynamic active;

  Sound.fromJson(Map<dynamic, dynamic> json) {
    active = json['active'];
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['active'] = active;
    return _data;
  }
}

class AutoHide {
  AutoHide({
    required this.active,
  });
  late final dynamic active;

  AutoHide.fromJson(Map<dynamic, dynamic> json) {
    active = json['active'];
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['active'] = active;
    return _data;
  }
}

class Push {
  Push({
    required this.active,
  });
  late final dynamic active;

  Push.fromJson(Map<dynamic, dynamic> json) {
    active = json['active'];
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['active'] = active;
    return _data;
  }
}

class Email {
  Email({
    required this.active,
    required this.input,
  });
  late final dynamic active;
  late final dynamic input;

  Email.fromJson(Map<dynamic, dynamic> json) {
    active = json['active'];
    input = json['input'];
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['active'] = active;
    _data['input'] = input;
    return _data;
  }
}

class Webhook {
  Webhook({
    required this.active,
    required this.input,
  });
  late final dynamic active;
  late final dynamic input;

  Webhook.fromJson(Map<dynamic, dynamic> json) {
    active = json['active'];
    input = json['input'];
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['active'] = active;
    _data['input'] = input;
    return _data;
  }
}

class SharingEmail {
  SharingEmail({
    required this.active,
    required this.input,
  });
  late final dynamic active;
  late final dynamic input;

  SharingEmail.fromJson(Map<dynamic, dynamic> json) {
    active = json['active'];
    input = json['input'];
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['active'] = active;
    _data['input'] = input;
    return _data;
  }
}

class Command {
  Command({
    required this.active,
    required this.type,
  });
  late final dynamic active;
  late final dynamic type;

  Command.fromJson(Map<dynamic, dynamic> json) {
    active = json['active'];
    type = json['type'];
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['active'] = active;
    _data['type'] = type;
    return _data;
  }
}
