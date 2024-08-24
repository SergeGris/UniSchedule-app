'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"flutter_bootstrap.js": "3881b297e368653f1294bc8123cc4aec",
"index.html": "331b3d83af821baa58954ffc013a81aa",
"/": "331b3d83af821baa58954ffc013a81aa",
"main.dart.js": "05cefb689e9992fc5e419cd94a418746",
"version.json": "7d1121e0763a89daab25178e50499b8d",
"assets/assets/images/icon.png": "dd98cf980dcce0037f3f927fb2f26c19",
"assets/assets/images/services/GPLv3Logo.svg.vec": "7eef9ca997305df8d3640a5688062584",
"assets/assets/images/services/light-cmc-logo.svg.vec": "929013d2e0c8b8c53cc429b5c3eed2a2",
"assets/assets/images/services/money.svg.vec": "884909a84d9960c31d8a26545c59c442",
"assets/assets/images/services/bus.svg.vec": "e8dd012d5e56cad1cec56964ce213db2",
"assets/assets/images/services/cmc-logo.svg.vec": "25aea476aaddad8db954d191ccb5bb2f",
"assets/assets/images/services/trex.svg.vec": "202e2c2accf966478cca74d1cfd3e170",
"assets/assets/images/services/write_us.svg.vec": "62b04de5010d9ddf5a3efb5c8dbf5769",
"assets/assets/images/services/yandex_disk.svg.vec": "b8662934da0e1f913d1ffcc7d81471fa",
"assets/assets/images/services/courses.svg.vec": "ea2ff338856fa1657cfe0d6117b049c3",
"assets/assets/images/services/feedback.svg.vec": "38a56b6d6b8f912f883a02da006e2df1",
"assets/assets/images/services/info.svg.vec": "de91dd137934ccbbd02db91f0ec22177",
"assets/assets/images/services/join.svg.vec": "8a4d8dc78ef8905c4afabc91a57a2a8d",
"assets/assets/images/services/map.svg.vec": "d2731bd1051885a0d486bfea075ef31e",
"assets/assets/images/services/report.svg.vec": "3aa8d8cd4d5981150bcfff44fb5a6c81",
"assets/assets/images/services/study_office.svg.vec": "e3b25204d8280f23b2c570386310a3f1",
"assets/assets/dino-runner/index.html": "2378e298cca1b7cfb16d367a6754e0ab",
"assets/assets/copying.md": "ba29b1da0f9c28e2a9e072aba46cf040",
"assets/assets/plans/MSU/PHYS/floor-plan-1.svg.vec": "8a079459ddcb8143549717bdea8b4a1b",
"assets/assets/plans/MSU/PHYS/floor-plan1.svg.vec": "63fce7dcd306ca8e528274ebdcca36cd",
"assets/assets/plans/MSU/PHYS/floor-plan2.svg.vec": "e3e4eb450482806aaf27d97c5d8c6dde",
"assets/assets/plans/MSU/PHYS/floor-plan3.svg.vec": "b48b13c816889cd61d8489db85b1d840",
"assets/assets/plans/MSU/PHYS/floor-plan4.svg.vec": "a71e7d22a72209a2b078be7a6b0b5a05",
"assets/assets/plans/MSU/PHYS/floor-plan5.svg.vec": "998e94646ca0d7ecb570009dbfe0fe02",
"assets/assets/plans/MSU/SAB/floor-plan1.svg.vec": "7c4f537faf64969c4da8075b354ae57f",
"assets/assets/plans/MSU/SAB/floor-plan2.svg.vec": "52c5e9c5253d2fea05ba16f4def0326b",
"assets/assets/plans/MSU/BIO/floor-plan1.svg.vec": "d9b7d63e69ba43ebf9a70415a2707553",
"assets/fonts/MaterialIcons-Regular.otf": "278b1a4e2721af67a7fa3f07589cb3ee",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.json": "6124ab6fb5160b4b6cbde285e820fb18",
"assets/AssetManifest.bin.json": "89bc65395971737cbf1694f0e2fe786a",
"assets/AssetManifest.bin": "bb91021f988e2b8d998a5b6bae9fc652",
"assets/NOTICES": "e89b4aa4bf293946312ce3deab4e33d4",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview_web/assets/web/web_support.js": "ffd063c5ddbbe185f778e7e41fdceb31",
"manifest.json": "859a2facc0b9b3faf071be871af321cb",
"favicon.png": "dd98cf980dcce0037f3f927fb2f26c19",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
