const db = require("../dbconnection");

var GetDataOther = {
  getdataUserAll: function (callback) {
    return db.query(
      `SELECT u.id , u.email , u.firstname , u.lastname , u.image_profile , u.role , u.create_at , u.update_at , count(u.id) as count_upload FROM db_project.users as u
      LEFT JOIN db_project.object_detection as o ON o.request_user = u.id
      WHERE u.active = 1 AND o.active = 1
      GROUP BY u.id`,
      callback
    );
  },

  getdataObjDetect: function (callback) {
    return db.query(
      `SELECT a.id, b.firstname, b.lastname, b.email, a.image_detection, a.licence_number, a.latitude, a.longitude, a.detection_at, a.status, a.create_at, a.update_by, a.update_at
      FROM db_project.object_detection as a
			JOIN db_project.users as b ON a.request_user = b.id
			WHERE a.active = 1 AND b.active = 1 ORDER BY update_at DESC`,
      callback
    );
  },

  searchdataObjDetect: function (search_value, callback) {
    return db.query(
      `SELECT a.id, b.firstname, b.lastname, b.email, a.image_detection, a.licence_number, a.latitude, a.longitude, a.detection_at, a.status, a.create_at, a.update_by, a.update_at
      FROM db_project.object_detection as a
			JOIN db_project.users as b ON a.request_user = b.id
			WHERE a.active = 1 AND b.active = 1 AND (b.firstname LIKE '%${search_value}%' OR b.lastname LIKE '%${search_value}%' OR a.licence_number LIKE '%${search_value}%') 
      ORDER BY update_at DESC`,
      callback
    );
  },

  getdataReport: function (callback) {
    return db.query(
      `SELECT a.id, b.request_user, b.image_detection, b.licence_number, a.approve_by, a.description, a.active as active_report, a.create_at, a.update_at
      FROM db_project.report as a
      JOIN db_project.object_detection as b ON a.request_object_detection = b.id
      WHERE a.active = 1 AND b.active = 1 ORDER BY a.update_at DESC`,
      callback
    );
  },

  getstaticFromStatus: function (callback) {
    return db.query(
      `SELECT
      (SELECT 10 as status), 
       (SELECT count(id) FROM db_project.object_detection WHERE (NOW() :: DATE = update_at :: DATE) AND status = 10 AND active = 1) as today, 
       (SELECT count(id) FROM db_project.object_detection WHERE ((update_at + interval '7 days') >= now()) AND status = 10 AND active = 1) as toweek,
       (SELECT count(id) FROM db_project.object_detection WHERE ((to_char(update_at, 'YYYY-MM')) = (to_char(now(), 'YYYY-MM'))) AND status = 10 AND active = 1) as tomonth,
       (SELECT count(id) FROM db_project.object_detection WHERE((to_char(update_at, 'YYYY')) = (to_char(now(), 'YYYY'))) AND status = 10 AND active = 1) as toyear,
       (SELECT count(id) FROM db_project.object_detection WHERE  status = 10 AND active = 1) as total
       UNION
       SELECT 
       (SELECT 20 as status), 
       (SELECT count(id) FROM db_project.object_detection WHERE (NOW() :: DATE = update_at :: DATE) AND status = 20 AND active = 1) as today, 
       (SELECT count(id) FROM db_project.object_detection WHERE ((update_at + interval '7 days') >= now()) AND status = 20 AND active = 1) as toweek,
       (SELECT count(id) FROM db_project.object_detection WHERE ((to_char(update_at, 'YYYY-MM')) = (to_char(now(), 'YYYY-MM'))) AND status = 20 AND active = 1) as tomonth,
       (SELECT count(id) FROM db_project.object_detection WHERE((to_char(update_at, 'YYYY')) = (to_char(now(), 'YYYY'))) AND status = 20 AND active = 1) as toyear,
       (SELECT count(id) FROM db_project.object_detection WHERE  status = 20 AND active = 1) as total
       UNION
        SELECT 
       (SELECT 30 as status), 
       (SELECT count(id) FROM db_project.object_detection WHERE (NOW() :: DATE = update_at :: DATE) AND status = 30 AND active = 1) as today, 
       (SELECT count(id) FROM db_project.object_detection WHERE ((update_at + interval '7 days') >= now()) AND status = 30 AND active = 1) as toweek,
       (SELECT count(id) FROM db_project.object_detection WHERE ((to_char(update_at, 'YYYY-MM')) = (to_char(now(), 'YYYY-MM'))) AND status = 30 AND active = 1) as tomonth,
       (SELECT count(id) FROM db_project.object_detection WHERE((to_char(update_at, 'YYYY')) = (to_char(now(), 'YYYY'))) AND status = 30 AND active = 1) as toyear,
       (SELECT count(id) FROM db_project.object_detection WHERE  status = 30 AND active = 1) as total
       UNION
        SELECT 
       (SELECT 40 as status), 
       (SELECT count(id) FROM db_project.object_detection WHERE (NOW() :: DATE = update_at :: DATE) AND status = 40 AND active = 1) as today, 
       (SELECT count(id) FROM db_project.object_detection WHERE ((update_at + interval '7 days') >= now()) AND status = 40 AND active = 1) as toweek,
       (SELECT count(id) FROM db_project.object_detection WHERE ((to_char(update_at, 'YYYY-MM')) = (to_char(now(), 'YYYY-MM'))) AND status = 40 AND active = 1) as tomonth,
       (SELECT count(id) FROM db_project.object_detection WHERE((to_char(update_at, 'YYYY')) = (to_char(now(), 'YYYY'))) AND status = 40 AND active = 1) as toyear,
       (SELECT count(id) FROM db_project.object_detection WHERE  status = 40 AND active = 1) as total
       ORDER BY status ASC`,
      callback
    );
  },
};

module.exports = GetDataOther;
