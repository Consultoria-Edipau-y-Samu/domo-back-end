import mysql from "mysql2/promise";
import { SecretsManagerClient, GetSecretValueCommand } from "@aws-sdk/client-secrets-manager";

const secretName = "aurora-credentials";
const region = "us-east-1";

async function getDBCredentials() {
  console.log("Fetching DB credentials from Secrets Manager...");
  const client = new SecretsManagerClient({ region });
  const command = new GetSecretValueCommand({ SecretId: secretName });
  console.log(client, command);

  const response = await client.send(command);

  if (!response.SecretString) {
    throw new Error("Secret not found or empty");
  }

  return JSON.parse(response.SecretString);
}

export async function getConnection() {
  const creds = await getDBCredentials();
  console.log("Connecting to Aurora host:", creds.host);

  return mysql.createConnection({
    host: creds.host,
    user: creds.username,
    password: creds.password,
    database: creds.database,
  });
}
