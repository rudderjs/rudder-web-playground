PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "Todo" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "title" TEXT NOT NULL,
    "completed" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
CREATE TABLE IF NOT EXISTS "User" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT,
    "emailVerified" BOOLEAN NOT NULL DEFAULT false,
    "image" TEXT,
    "role" TEXT NOT NULL DEFAULT 'user',
    "rememberToken" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
CREATE TABLE IF NOT EXISTS "PasswordResetToken" (
    "email" TEXT NOT NULL PRIMARY KEY,
    "token" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "paddle_customers" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "paddleId" TEXT,
    "billableId" TEXT NOT NULL,
    "billableType" TEXT NOT NULL,
    "name" TEXT,
    "email" TEXT,
    "trialEndsAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
CREATE TABLE IF NOT EXISTS "paddle_subscriptions" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "billableId" TEXT NOT NULL,
    "billableType" TEXT NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'default',
    "paddleId" TEXT NOT NULL,
    "paddleStatus" TEXT NOT NULL,
    "paddleProductId" TEXT,
    "trialEndsAt" DATETIME,
    "pausedAt" DATETIME,
    "endsAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
CREATE TABLE IF NOT EXISTS "paddle_subscription_items" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "subscriptionId" TEXT NOT NULL,
    "productId" TEXT NOT NULL,
    "priceId" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL DEFAULT 1,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "paddle_subscription_items_subscriptionId_fkey" FOREIGN KEY ("subscriptionId") REFERENCES "paddle_subscriptions" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE IF NOT EXISTS "paddle_transactions" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "paddleId" TEXT NOT NULL,
    "paddleCustomerId" TEXT,
    "paddleSubscriptionId" TEXT,
    "billableId" TEXT NOT NULL,
    "billableType" TEXT NOT NULL,
    "invoiceNumber" TEXT,
    "status" TEXT NOT NULL,
    "total" TEXT NOT NULL,
    "tax" TEXT NOT NULL DEFAULT '0',
    "currency" TEXT NOT NULL,
    "billedAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "paddle_transactions_paddleSubscriptionId_fkey" FOREIGN KEY ("paddleSubscriptionId") REFERENCES "paddle_subscriptions" ("paddleId") ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE IF NOT EXISTS "paddle_webhook_logs" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "eventId" TEXT NOT NULL,
    "eventType" TEXT NOT NULL,
    "processedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "Notification" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "notifiable_id" TEXT NOT NULL,
    "notifiable_type" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "data" TEXT NOT NULL,
    "read_at" TEXT,
    "created_at" TEXT NOT NULL,
    "updated_at" TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS "oauth_clients" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "secret" TEXT,
    "redirectUris" TEXT NOT NULL DEFAULT '[]',
    "grantTypes" TEXT NOT NULL DEFAULT '["authorization_code"]',
    "scopes" TEXT NOT NULL DEFAULT '[]',
    "confidential" BOOLEAN NOT NULL DEFAULT true,
    "revoked" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
CREATE TABLE IF NOT EXISTS "oauth_access_tokens" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT,
    "clientId" TEXT NOT NULL,
    "name" TEXT,
    "scopes" TEXT NOT NULL DEFAULT '[]',
    "revoked" BOOLEAN NOT NULL DEFAULT false,
    "expiresAt" DATETIME NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "oauth_refresh_tokens" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "accessTokenId" TEXT NOT NULL,
    "revoked" BOOLEAN NOT NULL DEFAULT false,
    "expiresAt" DATETIME NOT NULL
);
CREATE TABLE IF NOT EXISTS "oauth_auth_codes" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "scopes" TEXT NOT NULL DEFAULT '[]',
    "revoked" BOOLEAN NOT NULL DEFAULT false,
    "expiresAt" DATETIME NOT NULL,
    "codeChallenge" TEXT,
    "codeChallengeMethod" TEXT
);
CREATE TABLE IF NOT EXISTS "oauth_device_codes" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "clientId" TEXT NOT NULL,
    "userCode" TEXT NOT NULL,
    "deviceCode" TEXT NOT NULL,
    "scopes" TEXT NOT NULL DEFAULT '[]',
    "userId" TEXT,
    "approved" BOOLEAN,
    "expiresAt" DATETIME NOT NULL,
    "lastPolledAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
CREATE UNIQUE INDEX "paddle_customers_paddleId_key" ON "paddle_customers"("paddleId");
CREATE INDEX "paddle_customers_paddleId_idx" ON "paddle_customers"("paddleId");
CREATE UNIQUE INDEX "paddle_customers_billableType_billableId_key" ON "paddle_customers"("billableType", "billableId");
CREATE UNIQUE INDEX "paddle_subscriptions_paddleId_key" ON "paddle_subscriptions"("paddleId");
CREATE INDEX "paddle_subscriptions_billableType_billableId_idx" ON "paddle_subscriptions"("billableType", "billableId");
CREATE INDEX "paddle_subscriptions_paddleStatus_idx" ON "paddle_subscriptions"("paddleStatus");
CREATE UNIQUE INDEX "paddle_subscription_items_subscriptionId_priceId_key" ON "paddle_subscription_items"("subscriptionId", "priceId");
CREATE UNIQUE INDEX "paddle_transactions_paddleId_key" ON "paddle_transactions"("paddleId");
CREATE INDEX "paddle_transactions_billableType_billableId_idx" ON "paddle_transactions"("billableType", "billableId");
CREATE INDEX "paddle_transactions_paddleCustomerId_idx" ON "paddle_transactions"("paddleCustomerId");
CREATE UNIQUE INDEX "paddle_webhook_logs_eventId_key" ON "paddle_webhook_logs"("eventId");
CREATE INDEX "paddle_webhook_logs_eventType_idx" ON "paddle_webhook_logs"("eventType");
CREATE INDEX "Notification_notifiable_type_notifiable_id_idx" ON "Notification"("notifiable_type", "notifiable_id");
CREATE INDEX "oauth_access_tokens_userId_idx" ON "oauth_access_tokens"("userId");
CREATE UNIQUE INDEX "oauth_refresh_tokens_accessTokenId_key" ON "oauth_refresh_tokens"("accessTokenId");
CREATE UNIQUE INDEX "oauth_device_codes_userCode_key" ON "oauth_device_codes"("userCode");
CREATE UNIQUE INDEX "oauth_device_codes_deviceCode_key" ON "oauth_device_codes"("deviceCode");
COMMIT;
