import { getConnection } from "../utils/db";

interface UserRecord {
  userId: string;
  name: string;
  email: string;
  username: string;
  age: number;
  passwordHash: string;
}

export async function insertUser(user: UserRecord): Promise<void> {
  const conn = await getConnection();

  try {
    await conn.execute(
      `INSERT INTO Users (userId, name, email, username, age, passwordHash)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [user.userId, user.name, user.email, user.username, user.age, user.passwordHash]
    );
  } finally {
    await conn.end();
  }
}

export async function findUser(input: any) {
  const conn = await getConnection();
  try {
    const [rows] = await conn.execute(`SELECT * FROM Users WHERE email = ? OR username = ?`, [
      input.email ?? null,
      input.username ?? null,
    ]);
    return rows;
  } finally {
    await conn.end();
  }
}

export const findEmail = async (email: string) => {
  const conn = await getConnection();
  try {
    const [rows] = await conn.execute(`SELECT email FROM Users WHERE email = ?`, [email]);
    return rows;
  } finally {
    await conn.end();
  }
};

export const findUsername = async (email: string) => {
  const conn = await getConnection();
  try {
    const [rows] = await conn.execute(`SELECT username FROM Users WHERE username = ?`, [email]);
    return rows;
  } finally {
    await conn.end();
  }
};

export const removeUser = async (input: any) => {
  const conn = await getConnection();
  try {
    const [result] = await conn.execute(`DELETE FROM Users WHERE email = ? OR username = ?`, [
      input.email ?? null,
      input.username ?? null,
    ]);
    return result;
  } finally {
    await conn.end();
  }
};
