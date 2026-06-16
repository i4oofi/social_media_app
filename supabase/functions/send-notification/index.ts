import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { JWT } from 'npm:google-auth-library'

// Firebase Service Account Credentials (Store these in Supabase Secrets)
// Do NOT hardcode them here in production, use Deno.env.get('FIREBASE_SERVICE_ACCOUNT')
const FIREBASE_PROJECT_ID = Deno.env.get('FIREBASE_PROJECT_ID') || '';
const FIREBASE_CLIENT_EMAIL = Deno.env.get('FIREBASE_CLIENT_EMAIL') || '';
// Private key needs newlines replaced correctly
const FIREBASE_PRIVATE_KEY = (Deno.env.get('FIREBASE_PRIVATE_KEY') || '').replace(/\\n/g, '\n');

async function getAccessToken() {
  const jwtClient = new JWT({
    email: FIREBASE_CLIENT_EMAIL,
    key: FIREBASE_PRIVATE_KEY,
    scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
  });
  const tokens = await jwtClient.authorize();
  return tokens.access_token;
}

Deno.serve(async (req) => {
  try {
    // 1. Get the payload from the Database Webhook
    const payload = await req.json();
    console.log('Webhook Payload:', payload);

    // The webhook sends the inserted row inside payload.record
    const notification = payload.record;
    
    if (!notification || !notification.receiver_id) {
      return new Response(JSON.stringify({ error: 'Invalid payload' }), { status: 400 });
    }

    // 2. Initialize Supabase Client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    );

    // 3. Fetch the FCM token of the receiver
    const { data: userData, error: userError } = await supabaseClient
      .from('users')
      .select('fcm_token')
      .eq('id', notification.receiver_id)
      .single();

    if (userError || !userData || !userData.fcm_token) {
      console.log('User has no FCM token or error occurred:', userError);
      return new Response(JSON.stringify({ message: 'No FCM token found for user.' }), { status: 200 });
    }

    const fcmToken = userData.fcm_token;

    // 4. Construct Notification Body
    let title = 'New Notification';
    let bodyText = 'Someone interacted with your profile.';

    if (notification.type === 'like') bodyText = 'liked your post.';
    if (notification.type === 'comment') bodyText = 'commented on your post.';
    if (notification.type === 'follow') bodyText = 'started following you.';

    const senderName = notification.sender_name || 'Someone';

    // 5. Generate FCM Access Token
    const accessToken = await getAccessToken();

    // 6. Send the Notification to FCM API v1
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`;
    
    const fcmMessage = {
      message: {
        token: fcmToken,
        notification: {
          title: title,
          body: `${senderName} ${bodyText}`,
          image: notification.sender_image_url || undefined,
        },
        data: {
          type: notification.type,
          postId: notification.post_id || '',
          senderId: notification.sender_id || '',
        },
      },
    };

    const response = await fetch(fcmUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(fcmMessage),
    });

    const result = await response.json();
    console.log('FCM Response:', result);

    return new Response(JSON.stringify({ success: true, result }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (error) {
    console.error('Error sending push notification:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});
