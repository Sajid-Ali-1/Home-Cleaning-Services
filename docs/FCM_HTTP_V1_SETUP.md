# Firebase Cloud Messaging HTTP v1 API Setup Guide

This guide will walk you through setting up FCM HTTP v1 API with Service Account for push notifications.

## Step-by-Step Setup Instructions

### Part 1: Firebase Console - Create Service Account

1. **Go to Firebase Console**
   - Open https://console.firebase.google.com/
   - Select your project

2. **Navigate to Project Settings**
   - Click the gear icon (⚙️) next to "Project Overview"
   - Select "Project settings"

3. **Go to Service Accounts Tab**
   - Click on the "Service accounts" tab
   - You'll see options for Firebase Admin SDK

4. **Create or Use Existing Service Account**
   - If you don't have a service account, click "Generate new private key"
   - If you already have one, you can use it or create a new one
   - Click "Generate new private key" button
   - A dialog will appear warning you about security
   - Click "Generate key"
   - A JSON file will be downloaded to your computer

5. **Note Your Project ID**
   - In the same "Service accounts" tab, you'll see your Project ID
   - Copy this value (e.g., `my-project-12345`)

### Part 2: Enable Required APIs

1. **Go to Google Cloud Console**
   - Open https://console.cloud.google.com/
   - Make sure you're in the correct project (same as Firebase)

2. **Enable Firebase Cloud Messaging API**
   - Go to "APIs & Services" → "Library"
   - Search for "Firebase Cloud Messaging API"
   - Click on it and press "Enable"
   - Wait for it to enable (usually takes a few seconds)

### Part 3: Configure Your App

1. **Prepare the Service Account JSON**
   - Open the downloaded JSON file
   - You need to minify it (remove all line breaks and extra spaces)
   - You can use an online JSON minifier: https://jsonformatter.org/json-minify
   - Or use this command in terminal:
     ```bash
     cat path/to/service-account-key.json | jq -c .
     ```

2. **Update Your .env File**
   - Create or update your `.env` file in the project root
   - Add these two lines:
     ```
     FIREBASE_PROJECT_ID=your-project-id-here
     FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account","project_id":"...","private_key_id":"...","private_key":"-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n","client_email":"...","client_id":"...","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"...","client_x509_cert_url":"..."}
     ```
   
   **Important Notes:**
   - Replace `your-project-id-here` with your actual Project ID from Step 1.5
   - Replace the entire JSON object with your minified service account JSON
   - The JSON must be on a single line (no line breaks)
   - Keep the quotes around the JSON string

3. **Example .env Entry**
   ```
   FIREBASE_PROJECT_ID=home-cleaning-app-12345
   FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account","project_id":"home-cleaning-app-12345","private_key_id":"abc123...","private_key":"-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----\n","client_email":"firebase-adminsdk-xyz@home-cleaning-app-12345.iam.gserviceaccount.com","client_id":"123456789","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_x509_cert_url":"https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xyz%40home-cleaning-app-12345.iam.gserviceaccount.com"}
   ```

### Part 4: Verify Setup

1. **Run the App**
   - The app will automatically initialize the service account on startup
   - Check the console for any errors
   - If you see "Warning: FCM Service Account initialization failed", check your .env file

2. **Test Notifications**
   - Try sending a test notification through your app
   - Check the console logs for any errors

## Troubleshooting

### Error: "FIREBASE_PROJECT_ID is missing"
- Make sure you've added `FIREBASE_PROJECT_ID` to your `.env` file
- Check that the value matches your Firebase project ID

### Error: "FIREBASE_SERVICE_ACCOUNT_JSON is missing"
- Make sure you've added the service account JSON to your `.env` file
- Ensure the JSON is minified (single line, no line breaks)
- Make sure it's wrapped in quotes

### Error: "Failed to initialize service account"
- Verify the JSON is valid (use a JSON validator)
- Check that all required fields are present in the JSON
- Ensure the service account has the necessary permissions

### Error: "FCM v1 API error: 403"
- Make sure you've enabled "Firebase Cloud Messaging API" in Google Cloud Console
- Verify the service account has the correct permissions

### Error: "FCM v1 API error: 401"
- The access token might be invalid
- Try regenerating the service account key
- Make sure the JSON is correctly formatted in .env

## Security Best Practices

1. **Never commit .env to version control**
   - Make sure `.env` is in your `.gitignore`
   - The `env.example` file is safe to commit (it has placeholder values)

2. **Keep Service Account Key Secure**
   - Don't share the service account JSON file
   - Don't commit it to any repository
   - Rotate keys periodically

3. **Use Environment Variables in Production**
   - For production, consider using environment variables instead of .env file
   - Or use a secure secrets management service

## Migration from Legacy API

If you were using the Legacy API (FIREBASE_SERVER_KEY), you can now remove it:
- Remove `FIREBASE_SERVER_KEY` from your `.env` file
- The new HTTP v1 API will be used automatically

## Additional Resources

- [FCM HTTP v1 API Documentation](https://firebase.google.com/docs/cloud-messaging/migrate-v1)
- [Service Account Documentation](https://cloud.google.com/iam/docs/service-accounts)
- [Google Cloud Console](https://console.cloud.google.com/)

