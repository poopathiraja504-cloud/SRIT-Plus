importScripts(
  'https://www.gstatic.com/firebasejs/12.19.0/firebase-app-compat.js',
);
importScripts(
  'https://www.gstatic.com/firebasejs/12.19.0/firebase-messaging-compat.js',
);

const appShellCache = 'srit-plus-app-shell-v1';
const appShellFiles = [
  '/',
  '/index.html',
  '/manifest.json',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/favicon.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches
      .open(appShellCache)
      .then((cache) => cache.addAll(appShellFiles))
      .then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((cacheNames) =>
        Promise.all(
          cacheNames
            .filter(
              (cacheName) =>
                cacheName.startsWith('srit-plus-app-shell-') &&
                cacheName !== appShellCache,
            )
            .map((cacheName) => caches.delete(cacheName)),
        ),
      )
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  const requestUrl = new URL(request.url);
  if (request.method !== 'GET' || requestUrl.origin !== self.location.origin) {
    return;
  }

  event.respondWith(
    (async () => {
      const cache = await caches.open(appShellCache);
      let response;
      try {
        response = await fetch(request);
      } catch (error) {
        const cachedResponse = await cache.match(request);
        if (cachedResponse) return cachedResponse;
        if (request.mode === 'navigate') {
          const cachedAppShell = await cache.match('/');
          if (cachedAppShell) return cachedAppShell;
        }
        throw error;
      }

      if (response.ok && response.type === 'basic') {
        try {
          await cache.put(request, response.clone());
        } catch (error) {
          console.warn('Could not cache an SRIT Plus resource:', error);
        }
      }
      return response;
    })(),
  );
});

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
