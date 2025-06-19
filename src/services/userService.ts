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
  if (!data.username || !data.email || !data.password || !data.name || !data.age) {
    throw new Error("Missing required fields");
  }

  const { success: emailSuccess } = await isEmailTaken({ email: data.email });

  if (emailSuccess) {
    throw new Error("Email already taken");
  }

  const { success: usernameSuccess } = await isUsernameTaken({ username: data.username });

  if (usernameSuccess) {
    throw new Error("Username already taken");
  }

  // Generate UUID and hashed password
  const userId = uuidv4();
  const passwordHash = await hashPassword(data.password);

  //validate password?

  // Call repository to persist
  await insertUser({
    userId,
    name: data.name,
    email: data.email,
    username: data.username,
    age: data.age,
    passwordHash,
  });

  return { success: true, message: "User created successfully." };
};

export const isEmailTaken = async (
  data: GetUserEmailInput
): Promise<{ success: boolean; message: string }> => {
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
