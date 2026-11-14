importScripts(
  'https://www.gstatic.com/firebasejs/12.19.0/firebase-app-compat.js',
);
importScripts(
  'https://www.gstatic.com/firebasejs/12.19.0/firebase-messaging-compat.js',
);

firebase.initializeApp({
  apiKey: 'AIzaSyCAJ3WtfH0YyiaME-iqneQOeWpQ4HuMJN4',
  appId: '1:609694857720:web:13abbba212677757813e0d',
  authDomain: 'srit-app-d51f4.firebaseapp.com',
  messagingSenderId: '609694857720',
  projectId: 'srit-app-d51f4',
  storageBucket: 'srit-app-d51f4.firebasestorage.app',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification || {};
  const section = payload.data && payload.data.section;
  const title = notification.title || 'SRIT Plus update';
  const options = {
    body: notification.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/favicon.png',
    data: { section: section || 'Home' },
  };

  return self.registration.showNotification(title, options);
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const url = new URL('/', self.location.origin);
  const section = event.notification.data && event.notification.data.section;
  if (typeof section === 'string' && section.length <= 100) {
    url.searchParams.set('section', section);
  }

  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(
      (clients) => {
        for (const client of clients) {
          if (client.url.startsWith(self.location.origin) && 'focus' in client) {
            return client.navigate(url.href).then((windowClient) =>
              windowClient ? windowClient.focus() : null,
            );
          }
        }
        return self.clients.openWindow(url.href);
      },
    ),
  );
});
