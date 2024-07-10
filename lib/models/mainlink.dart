// To parse this JSON data, do
//
//     final mainLink = mainLinkFromJson(jsonString);

import 'dart:convert';

MainLink mainLinkFromJson(String str) => MainLink.fromJson(json.decode(str));

String mainLinkToJson(MainLink data) => json.encode(data.toJson());

class MainLink {
    bool status;
    String message;
    List<Otherlink> otherlinks;

    MainLink({
        required this.status,
        required this.message,
        required this.otherlinks,
    });

    factory MainLink.fromJson(Map<String, dynamic> json) => MainLink(
        status: json["status"],
        message: json["message"],
        otherlinks: List<Otherlink>.from(json["otherlinks"].map((x) => Otherlink.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "otherlinks": List<dynamic>.from(otherlinks.map((x) => x.toJson())),
    };
}

class Otherlink {
    int id;
    String reason;
    String link;
    dynamic createdAt;
    dynamic updatedAt;

    Otherlink({
        required this.id,
        required this.reason,
        required this.link,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Otherlink.fromJson(Map<String, dynamic> json) => Otherlink(
        id: json["id"],
        reason: json["Reason"],
        link: json["link"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "Reason": reason,
        "link": link,
        "created_at": createdAt,
        "updated_at": updatedAt,
    };
}
