import { APIGatewayProxyEvent } from "aws-lambda";
import {
  postUser,
  getUser,
  isEmailTaken,
  isUsernameTaken,
  authenticateUser,
  deleteUser,
} from "./services/userService";
import jwt from "jsonwebtoken";

export const handler = async (event: APIGatewayProxyEvent) => {
  const methodType = event.httpMethod;

  //Handling CORS preflight request
  if (methodType && methodType.toUpperCase() === "OPTIONS") {
    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "http://localhost:3000",
        "Access-Control-Allow-Methods": "POST,OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Credentials": "true",
      },
      body: JSON.stringify({ message: "CORS preflight OK" }),
    };
  }

  const sharedHeaders = {
    "Access-Control-Allow-Origin": "http://localhost:3000",
    "Access-Control-Allow-Methods": "POST,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Credentials": "true",
  };

  try {
    const body = event.body ? JSON.parse(event.body) : {};
    const method = body.method;

    // 🔐 Check cookie and decode JWT

    let userIdFromToken = null;
    let usernameFromToken = null;
    let emailFromToken = null;
    const publicMethods = ["authenticateUser"];

    if (!publicMethods.includes(method)) {
      const cookies = event.headers?.cookie || event.headers?.Cookie || "";
      const token = cookies
        .split(";")
        .find((c) => c.trim().startsWith("auth_token="))
        ?.split("=")[1];

      if (!token) {
        return {
          statusCode: 401,
          headers: sharedHeaders,
          body: JSON.stringify({ error: "Unauthorized: No token provided" }),
        };
      }

      try {
        const decoded = jwt.verify(token, "superSecret") as any;
        const { userId, username, email } = decoded;
        userIdFromToken = userId;
        usernameFromToken = username;
        emailFromToken = email;
      } catch (err) {
        return {
          statusCode: 401,
          headers: sharedHeaders,
          body: JSON.stringify({ error: "Unauthorized: Invalid token" }),
        };
      }
    }

    const respond = (statusCode: number, result: any) => ({
      statusCode,
      headers: sharedHeaders,
      body: JSON.stringify(result),
    });

    switch (method) {
      case "postUser":
        return respond(200, await postUser(body));
      case "getUser":
        return respond(200, await getUser(body));
      case "isEmailTaken":
        return respond(200, await isEmailTaken(body));
      case "isUsernameTaken":
        return respond(200, await isUsernameTaken(body));
      case "authenticateUser":
        const { success, user, token } = await authenticateUser(body);
        return {
          statusCode: 200,
          headers: {
            ...sharedHeaders,
            "Set-Cookie": `auth_token=${token}; HttpOnly; Secure; Path=/; Max-Age=3600; SameSite=Strict`,
          },
          body: JSON.stringify({ success, user }),
        };
      case "deleteUser":
        return respond(200, await deleteUser(body));
      default:
        console.warn("Unknown or missing method in request body.");
        return respond(400, { error: "Unknown method" });
    }
  } catch (err: any) {
    console.error("Handler error:", err);
    return {
      statusCode: 500,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST,OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
      },
      body: JSON.stringify({ error: "Internal error", message: err.message }),
    };
  }
};
