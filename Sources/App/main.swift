import Vapor
import VaporMySQL

// MARK: - Database

do {
    let driver = try MySQLDriver(
        host: "127.0.0.1",
        user: "root",
        password: MySQLSecret.mySQLPassword,
        database: "never_music_development",
        port: 3306,
        flag: 0,
        encoding: "utf8"
    )
    Database.default = Database(driver)
} catch {
    print("Could not initialize driver: \(error)")
}

let drop = Droplet(
    database: Database.default,
    preparations: [User.self, Post.self]
)

drop.post("users") { request in
    guard let json = request.json else {
        throw Abort.badRequest
    }
    var user = try User(node: json)
    try user.save()
    return try user.makeJSON()
}

drop.get("users") { request in
    return try User.all().makeNode().converted(to: JSON.self)
}

drop.get("users", Int.self) { request, userId in
    guard let user = try User.find(userId) else {
        throw Abort.notFound
    }
    return try user.makeJSON()
}

drop.patch("users", Int.self) { request, userId in
    guard let _ = try User.find(userId) else {
        throw Abort.notFound
    }
    guard let json = request.json else {
        throw Abort.badRequest
    }
    var user = try User(node: json)
    user.id = try userId.makeNode()
    try user.save()
    return try user.makeJSON()
}

drop.delete("users", Int.self) { request, userId in
    guard let user = try User.find(userId) else {
        throw Abort.notFound
    }
    try user.delete()
    return try user.makeJSON()
}



//drop.get { req in
//    return try drop.view.make("welcome", [
//    	"message": drop.localization[req.lang, "welcome", "title"]
//    ])
//}

//drop.resource("posts", PostController())

drop.run()
















