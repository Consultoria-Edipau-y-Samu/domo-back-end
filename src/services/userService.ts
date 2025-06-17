import { v4 as uuidv4 } from "uuid";
import { insertUser, findUser, findEmail, findUsername } from "../repositories/userRepo";
import {
  AuthenticateUserInput,
  GetUserEmailInput,
  GetUserUsernameInput,
  PostUserInput,
  GetUserInput,
} from "../types/userTypes";
import { hashPassword } from "../utils/password";
import bcrypt from "bcryptjs";

export const postUser = async (data: PostUserInput) => {
  // Validate minimal required fields
  if (!data.name || !data.email || !data.password) {
    throw new Error("Missing required fields");
  }

  // Generate UUID and hashed password
  const userId = uuidv4();
  const passwordHash = await hashPassword(data.password);

  // Call repository to persist
  await insertUser({
    userId,
    name: data.name,
    email: data.email,
    username: data.username || null,
    age: data.age || null,
    passwordHash,
  });

  return { success: true, userId };
};

export const isEmailTaken = async (data: GetUserEmailInput) => {
  if (!data.email) {
    throw new Error("Email is required");
  }

  const [row] = await findEmail(data.email);
  if (!row) {
    return { success: false, message: "Email not taken" };
  }
  return { success: true, message: "Email already taken" };
};

export const isUsernameTaken = async (data: GetUserUsernameInput) => {
  if (!data.username) {
    throw new Error("Username is required");
  }

  const [row] = await findUsername(data.username);
  if (!row) {
    return { success: false, message: "Username not taken" };
  }
  return { success: true, message: "Username already taken" };
};

//Returns all the db info it is for testing purposes right now
export const getUser = async (data: GetUserInput) => {
  if (!data.email && !data.username) {
    throw new Error("Missing required fields");
  }

  const user = await findUser(data);

  if (!user || (user as any[]).length === 0) {
    throw new Error("User not found");
  }

  return { success: true, user };
};

export const authenticateUser = async (data: AuthenticateUserInput) => {
  const { email, username, password } = data;

  if (!email && !username) {
    throw new Error("Missing email or username");
  }

  if (!password) {
    throw new Error("Password is required");
  }

  // Get user by email or username
  const result = await findUser({ email, username });

  const user = result[0];
  if (!user) {
    throw new Error("User not found");
  }

  const passwordMatches = await bcrypt.compare(password, user.passwordHash);
  if (!passwordMatches) {
    throw new Error("Invalid credentials");
  }

  // Optional: remove passwordHash before returning
  delete user.passwordHash;

  return { success: true, user };
};
