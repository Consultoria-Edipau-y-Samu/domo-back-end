import bcrypt from "bcryptjs";

export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, 10);
}

export const validatePassword = (password: string): { success: boolean; message: string } => {
  if (password.length < 8) {
    return { success: false, message: "Password must be at least 8 characters" };
  }
  if (!/[A-Z]/.test(password)) {
    return { success: false, message: "Password must include at least one uppercase letter." };
  }
  if (!/[a-z]/.test(password)) {
    return { success: false, message: "Password must include at least one lowercase letter." };
  }
  if (!/[0-9]/.test(password)) {
    return { success: false, message: "Password must include at least one digit." };
  }
  if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
    return { success: false, message: "Password must include at least one special character." };
  }

  return { success: true, message: "Password is valid" };
};
