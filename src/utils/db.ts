import mysql from "mysql2/promise";

export async function getConnection() {
  return mysql.createConnection({
    host: "aurora-cluster.cluster-cf8w0u2c4r27.us-east-1.rds.amazonaws.com",
    user: "admin",
    password: "SuperSecret123!",
    database: "domosqldb",
  });
}
