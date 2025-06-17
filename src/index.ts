import { APIGatewayProxyEventV2 } from "aws-lambda";
import {
  postUser,
  getUser,
  isEmailTaken,
  isUsernameTaken,
  authenticateUser,
} from "./services/userService";

export const handler = async (event: APIGatewayProxyEventV2) => {
  try {
    const body = event.body ? JSON.parse(event.body) : {};
    const method = body.method;

    if (method === "postUser") {
      const result = await postUser(body);
      return {
        statusCode: 200,
        body: JSON.stringify(result),
      };
    }

    if (method === "readUser") {
      try {
        const result = await getUser(body);
        return {
          statusCode: 200,
          body: JSON.stringify(result),
        };
      } catch (err: any) {
        return {
          statusCode: 400,
          body: JSON.stringify({ error: err.message }),
        };
      }
    }

    if (method === "isEmailTaken") {
      try {
        const result = await isEmailTaken(body);
        return {
          statusCode: 200,
          body: JSON.stringify(result),
        };
      } catch (err: any) {
        return {
          statusCode: 400,
          body: JSON.stringify({ error: err.message }),
        };
      }
    }

    if (method === "getUserUsername") {
      try {
        const result = await isUsernameTaken(body);
        return {
          statusCode: 200,
          body: JSON.stringify(result),
        };
      } catch (err: any) {
        return {
          statusCode: 400,
          body: JSON.stringify({ error: err.message }),
        };
      }
    }

    if (method === "authenticateUser") {
      try {
        const result = await authenticateUser(body);
        return {
          statusCode: 200,
          body: JSON.stringify(result),
        };
      } catch (err: any) {
        return {
          statusCode: 400,
          body: JSON.stringify({ error: err.message }),
        };
      }
    }

    return {
      statusCode: 400,
      body: JSON.stringify({ error: "Unknown method" }),
    };
  } catch (err) {
    console.error("Handler error:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Internal error" }),
    };
  }
};
