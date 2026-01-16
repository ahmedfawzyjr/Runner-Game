'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "a50e8b9f13eb3b4c34d64797a92b4440",
"assets/AssetManifest.bin.json": "5e22a6a52d3a4be88299549c852af92a",
"assets/assets/audio/platform/Sounds/sfx_bump.ogg": "784eaa4f650d61bdde45020866225468",
"assets/assets/audio/platform/Sounds/sfx_coin.ogg": "8d5d19ba75522f85219975286ad39c72",
"assets/assets/audio/platform/Sounds/sfx_disappear.ogg": "bbabbf8cd27d802d516a1310a09485ba",
"assets/assets/audio/platform/Sounds/sfx_gem.ogg": "9cd9a020acf642bd0c95db40d8f68080",
"assets/assets/audio/platform/Sounds/sfx_hurt.ogg": "11c58c5ccbe0ea7ab73d8692a01ac6ac",
"assets/assets/audio/platform/Sounds/sfx_jump-high.ogg": "faa8c0f266eafcdcef30f4eea1a0e444",
"assets/assets/audio/platform/Sounds/sfx_jump.ogg": "e8b4f05030169b3b4d8e6edd749e8aa1",
"assets/assets/audio/platform/Sounds/sfx_magic.ogg": "f28b44f51c3e102d9702dd3b21b5518e",
"assets/assets/audio/platform/Sounds/sfx_select.ogg": "687ee689ce0b11ad97114d5e83aecd38",
"assets/assets/audio/platform/Sounds/sfx_throw.ogg": "4efdf73af20b5f778f78f699787985ab",
"assets/assets/audio/README.md": "51a2827e93b82f2d64f1f006fa49d5c9",
"assets/assets/images/platform/Sprites/Characters/Default/character_beige_climb_a.png": "f490532e68d69266ef3b35991b9f6998",
"assets/assets/images/platform/Sprites/Characters/Default/character_beige_climb_b.png": "67f1a6dd9ba656910f12619257b9825e",
"assets/assets/images/platform/Sprites/Characters/Default/character_beige_duck.png": "484380c5226f2edf49b4d4b3a01437f9",
"assets/assets/images/platform/Sprites/Characters/Default/character_beige_front.png": "4d4db3a703dd8ffbdb292be7f5ddbcfe",
"assets/assets/images/platform/Sprites/Characters/Default/character_beige_hit.png": "91afd794cff652c0e07a585dba488416",
"assets/assets/images/platform/Sprites/Characters/Default/character_beige_idle.png": "d9c6aa5fef1b4a5b15d962a3ad6999cb",
"assets/assets/images/platform/Sprites/Characters/Default/character_beige_jump.png": "33f8d8068b14483329a7d92a8abe77e8",
"assets/assets/images/platform/Sprites/Characters/Default/character_beige_walk_a.png": "aa3f7550840960176f0af54fa738e89f",
"assets/assets/images/platform/Sprites/Characters/Default/character_beige_walk_b.png": "b5165d37c1ce6c523f0eefcd1783a56c",
"assets/assets/images/platform/Sprites/Characters/Default/character_green_climb_a.png": "5d783167dfe9d76a4b8015dd6a7d9251",
"assets/assets/images/platform/Sprites/Characters/Default/character_green_climb_b.png": "caa244a02c268e5b13f464ed3ad4de3c",
"assets/assets/images/platform/Sprites/Characters/Default/character_green_duck.png": "614fbf399479757dff14e22b0f9f0df2",
"assets/assets/images/platform/Sprites/Characters/Default/character_green_front.png": "df96dfe82b80f675c29f52f71ed75a2b",
"assets/assets/images/platform/Sprites/Characters/Default/character_green_hit.png": "ac52dfccaeecbcd9b6997c72de4cc670",
"assets/assets/images/platform/Sprites/Characters/Default/character_green_idle.png": "aa8a89f05280c98deeced56b740a9465",
"assets/assets/images/platform/Sprites/Characters/Default/character_green_jump.png": "efc40037b3b81fffa8a9ef7bbcca5fa1",
"assets/assets/images/platform/Sprites/Characters/Default/character_green_walk_a.png": "a21f48e89e4f4b6fed9d37e334d6f41a",
"assets/assets/images/platform/Sprites/Characters/Default/character_green_walk_b.png": "3a8d16c65a4a407ee336d5828fd689df",
"assets/assets/images/platform/Sprites/Characters/Default/character_pink_climb_a.png": "571190201e3d67dc8436c07210053e8c",
"assets/assets/images/platform/Sprites/Characters/Default/character_pink_climb_b.png": "53bfb0cfc262a71ebe59e9e20ce55f52",
"assets/assets/images/platform/Sprites/Characters/Default/character_pink_duck.png": "4cd74acd52c8c76df6e17aa30313f7ec",
"assets/assets/images/platform/Sprites/Characters/Default/character_pink_front.png": "1cc7b6b1429470185edca9e6dd1a5a96",
"assets/assets/images/platform/Sprites/Characters/Default/character_pink_hit.png": "83411443de7bbf3a6fc670d8a31946bf",
"assets/assets/images/platform/Sprites/Characters/Default/character_pink_idle.png": "2c2bbf8629413a5995d5517ab7270348",
"assets/assets/images/platform/Sprites/Characters/Default/character_pink_jump.png": "db64b3a824e7119ecd6bfda1dc8767bb",
"assets/assets/images/platform/Sprites/Characters/Default/character_pink_walk_a.png": "1a0d558758107c8dd5469338cbb9dbc5",
"assets/assets/images/platform/Sprites/Characters/Default/character_pink_walk_b.png": "fa30c91f16ac40e89a7fe5034fba73bf",
"assets/assets/images/platform/Sprites/Characters/Default/character_purple_climb_a.png": "7ee12e1e3979b2cfa8eee3d090fa4a25",
"assets/assets/images/platform/Sprites/Characters/Default/character_purple_climb_b.png": "6bbe177be6bddda11cee26895d0e74eb",
"assets/assets/images/platform/Sprites/Characters/Default/character_purple_duck.png": "87cf8b4a487d9689ec81be3aa3d3a92b",
"assets/assets/images/platform/Sprites/Characters/Default/character_purple_front.png": "69bcbcf39a0149f3d1b2a7b5d77986db",
"assets/assets/images/platform/Sprites/Characters/Default/character_purple_hit.png": "cbc3c89f0edb035c82486d7b7c5c3d1f",
"assets/assets/images/platform/Sprites/Characters/Default/character_purple_idle.png": "43ac95a8ba54fe1f5ee015623397af86",
"assets/assets/images/platform/Sprites/Characters/Default/character_purple_jump.png": "ba786e0c8011be2c4a460e9dfb0c4c34",
"assets/assets/images/platform/Sprites/Characters/Default/character_purple_walk_a.png": "14bc4c10b7ec7ae8ef5ecab871920182",
"assets/assets/images/platform/Sprites/Characters/Default/character_purple_walk_b.png": "a5e9de47d45ddad2217fd08605262a57",
"assets/assets/images/platform/Sprites/Characters/Default/character_yellow_climb_a.png": "0e20ba49e6db322ee8aba70580c0ba17",
"assets/assets/images/platform/Sprites/Characters/Default/character_yellow_climb_b.png": "b57f78b59ea374a7061222f835b9a41e",
"assets/assets/images/platform/Sprites/Characters/Default/character_yellow_duck.png": "1dbbfb78943a7ca0c63ffe6b56cc3d41",
"assets/assets/images/platform/Sprites/Characters/Default/character_yellow_front.png": "a26fbc5e6bff128f5c58bfefa6e983f7",
"assets/assets/images/platform/Sprites/Characters/Default/character_yellow_hit.png": "718cf7738f9388a1b061d5ad2197ac94",
"assets/assets/images/platform/Sprites/Characters/Default/character_yellow_idle.png": "91b0cc7f13495ec04d24e53afd89ba94",
"assets/assets/images/platform/Sprites/Characters/Default/character_yellow_jump.png": "eff24e58f0a180e73a5208fda224b01d",
"assets/assets/images/platform/Sprites/Characters/Default/character_yellow_walk_a.png": "afd53688ca2efa57e1d8c0315a81f9c1",
"assets/assets/images/platform/Sprites/Characters/Default/character_yellow_walk_b.png": "14c5be582940558d9421a667a43ec6bc",
"assets/assets/images/platform/Sprites/Enemies/Default/barnacle_attack_a.png": "ac2a2c6ac7cd97946b0c4eb1e679db1b",
"assets/assets/images/platform/Sprites/Enemies/Default/barnacle_attack_b.png": "29ea393228278e8d45994d14b35c96af",
"assets/assets/images/platform/Sprites/Enemies/Default/barnacle_attack_rest.png": "af99f782d7afef584021a680938a8be9",
"assets/assets/images/platform/Sprites/Enemies/Default/bee_a.png": "b772f5225708cad1ce124068272f3ec1",
"assets/assets/images/platform/Sprites/Enemies/Default/bee_b.png": "8c1659d09a9cbf58d67f2075f5d51542",
"assets/assets/images/platform/Sprites/Enemies/Default/bee_rest.png": "e30ecd7a3683d60abe276371947abaad",
"assets/assets/images/platform/Sprites/Enemies/Default/block_fall.png": "b5be70ab4f628acfeffdc9d101d87356",
"assets/assets/images/platform/Sprites/Enemies/Default/block_idle.png": "bd7d7ca6b7766844a8afcde2d2a3abcb",
"assets/assets/images/platform/Sprites/Enemies/Default/block_rest.png": "c1f6f8ee7422ab038835f9e418b837af",
"assets/assets/images/platform/Sprites/Enemies/Default/fish_blue_rest.png": "03406baf4e50bed1928e9320d788d4e3",
"assets/assets/images/platform/Sprites/Enemies/Default/fish_blue_swim_a.png": "4fb54f445549ba4b399df32da97ca37b",
"assets/assets/images/platform/Sprites/Enemies/Default/fish_blue_swim_b.png": "b1f440912acd11eae42ea0bfd0b76f78",
"assets/assets/images/platform/Sprites/Enemies/Default/fish_purple_down.png": "7ea981543abbaa6483c6b6ef88ca5905",
"assets/assets/images/platform/Sprites/Enemies/Default/fish_purple_rest.png": "63ebca4e811aaeb089e611a19719f278",
"assets/assets/images/platform/Sprites/Enemies/Default/fish_purple_up.png": "bb354de78a8fc4d6d02ff5af53a457b4",
"assets/assets/images/platform/Sprites/Enemies/Default/fish_yellow_rest.png": "ba7a1b2bff5c3ed4aaf0cb2920a5de53",
"assets/assets/images/platform/Sprites/Enemies/Default/fish_yellow_swim_a.png": "7270fbad8d95821d2143a3ef0935b0ed",
"assets/assets/images/platform/Sprites/Enemies/Default/fish_yellow_swim_b.png": "b23c2295c6c771fde5bad7f48dc8efa8",
"assets/assets/images/platform/Sprites/Enemies/Default/fly_a.png": "bd4d8be2826ed64f640cf3cfb5657631",
"assets/assets/images/platform/Sprites/Enemies/Default/fly_b.png": "75924da218b7fa949d36ece4555e6708",
"assets/assets/images/platform/Sprites/Enemies/Default/fly_rest.png": "af118f4971881547682762c70aa2a43e",
"assets/assets/images/platform/Sprites/Enemies/Default/frog_idle.png": "84039d5cc1c3acd6131ff2a223122618",
"assets/assets/images/platform/Sprites/Enemies/Default/frog_jump.png": "f50edd256f8f95c4789f3e391b35e8ea",
"assets/assets/images/platform/Sprites/Enemies/Default/frog_rest.png": "dd27fdbdee3a22710a9aa36978722ae6",
"assets/assets/images/platform/Sprites/Enemies/Default/ladybug_fly.png": "fdc868d83ded49959fd6b7154ea6afd7",
"assets/assets/images/platform/Sprites/Enemies/Default/ladybug_rest.png": "7f646d3619be4c745453f04b6fcbb07b",
"assets/assets/images/platform/Sprites/Enemies/Default/ladybug_walk_a.png": "55daf96371407d805bf284dfdaf912e2",
"assets/assets/images/platform/Sprites/Enemies/Default/ladybug_walk_b.png": "f3b16b7a305f5dcb069266b0bf7178e9",
"assets/assets/images/platform/Sprites/Enemies/Default/mouse_rest.png": "cd124c7505f43d2f2597845ae7c29361",
"assets/assets/images/platform/Sprites/Enemies/Default/mouse_walk_a.png": "572953c04df2c4c3c5959cd689c0c3d0",
"assets/assets/images/platform/Sprites/Enemies/Default/mouse_walk_b.png": "9e6edfbb9726e6dac7a39a14a5d447fd",
"assets/assets/images/platform/Sprites/Enemies/Default/saw_a.png": "854801239eedacb72a73a83b406f665b",
"assets/assets/images/platform/Sprites/Enemies/Default/saw_b.png": "a754a679c57cda155e0c92c28d20afe4",
"assets/assets/images/platform/Sprites/Enemies/Default/saw_rest.png": "993107e48322a52094dd79e3a14a2abd",
"assets/assets/images/platform/Sprites/Enemies/Default/slime_block_jump.png": "50748868cbf3ff7ece653dd6c69b070e",
"assets/assets/images/platform/Sprites/Enemies/Default/slime_block_rest.png": "6c7cfad23e60c019318eeb9011dddcb0",
"assets/assets/images/platform/Sprites/Enemies/Default/slime_block_walk_a.png": "5c2596967871cb03fd2850221782ce0b",
"assets/assets/images/platform/Sprites/Enemies/Default/slime_block_walk_b.png": "4fe924ba58f8b0e3f5af5b21f1ef264e",
"assets/assets/images/platform/Sprites/Enemies/Default/slime_fire_flat.png": "8b20ec7755ea61bc9662d007d2cc94b2",
"assets/assets/images/platform/Sprites/Enemies/Default/slime_fire_rest.png": "640da6c2107319c5d844cdfbd85c2226",
"assets/assets/images/platform/Sprites/Enemies/Default/slime_fire_walk_a.png": "c0721381cc30f7e1e7e13da77a5c2e64",
"assets/assets/images/platform/Sprites/Enemies/Default/slime_fire_walk_b.png": "b86e51b4bee9a84e0d3a677b58401d89",
"assets/assets/images/platform/Sprites/Enemies/Default/slime_normal_flat.png": "096f2a21c68285fd49dfc39d1b52d4e7",
"assets/assets/images/platform/Sprites/Enemies/Default/slime_normal_rest.png": "3f2df7ac9dd20406b8a609ca98886150",
"assets/assets/images/platform/Sprites/Enemies/Default/slime_normal_walk_a.png": "be36282d97fc34dba45884798c657e6e",
"assets/assets/images/platform/Sprites/Enemies/Default/slime_normal_walk_b.png": "759e5c2dc099042615560dc40de852b7",
"assets/assets/images/platform/Sprites/Enemies/Default/slime_spike_flat.png": "ea3ef7d658894595ac1379b90b54cd4d",
"assets/assets/images/platform/Sprites/Enemies/Default/slime_spike_rest.png": "a1e02995ca1a6099a1048ce6cfc7add4",
"assets/assets/images/platform/Sprites/Enemies/Default/slime_spike_walk_a.png": "23d2476160bb7db15f0a92d7f91a415e",
"assets/assets/images/platform/Sprites/Enemies/Default/slime_spike_walk_b.png": "2ab11fe6f811d46b1b480fb2d92c9fe6",
"assets/assets/images/platform/Sprites/Enemies/Default/snail_rest.png": "2cce53c5c35a949f08d70e0089dd4030",
"assets/assets/images/platform/Sprites/Enemies/Default/snail_shell.png": "eee6078ac9d759b806b6fb81a932b85a",
"assets/assets/images/platform/Sprites/Enemies/Default/snail_walk_a.png": "df98d15aff277b13ad26671018e3ddd9",
"assets/assets/images/platform/Sprites/Enemies/Default/snail_walk_b.png": "9b0ebbef73cc5971aea8148c2307b714",
"assets/assets/images/platform/Sprites/Enemies/Default/worm_normal_move_a.png": "43fc0b99907815f59a1e61a2fb113d5a",
"assets/assets/images/platform/Sprites/Enemies/Default/worm_normal_move_b.png": "9cb94e7a354d2cda5ed3173657f0c7d1",
"assets/assets/images/platform/Sprites/Enemies/Default/worm_normal_rest.png": "04c9381eb2b2900ce765753a26aad163",
"assets/assets/images/platform/Sprites/Enemies/Default/worm_ring_move_a.png": "12f480704a1f9803438af3ffc48a4777",
"assets/assets/images/platform/Sprites/Enemies/Default/worm_ring_move_b.png": "8e5e629c4dc9cef7490ee96b7ebca49c",
"assets/assets/images/platform/Sprites/Enemies/Default/worm_ring_rest.png": "d0783e78dee7bf52cca20101bf119194",
"assets/assets/images/plx-1.png": "25c49cc12aeed4d2799dc9fb52e3c213",
"assets/assets/images/plx-2.png": "53d9e937ac94613d7d408fcc50fa67c7",
"assets/assets/images/plx-3.png": "b50ebfb91131365a479f229c0325c033",
"assets/assets/images/plx-4.png": "58662c8e1ed9bd74717dfa54df862788",
"assets/assets/images/plx-5.png": "552941c58ccaa9782ebee6496e77e003",
"assets/assets/images/plx-6.png": "07b9aeda90128cb6e63954f56d0af5d7",
"assets/assets/images/Run__000.png": "e373ee3af1cf4fa7dc60dbb7b8afdcc0",
"assets/assets/images/Run__001.png": "ebe74c31a268641792adbd811da48905",
"assets/assets/images/Run__002.png": "36410b85b7d8f96c732fe1b1f50d7acf",
"assets/assets/images/Run__003.png": "00929c9c2e03349e6f39cd7746767c6e",
"assets/assets/images/Run__004.png": "11f67a4c13bcc7f8b312eeb2ff40c73f",
"assets/assets/images/Run__005.png": "0f0f3fcceff0834d5aad48750a297d22",
"assets/assets/images/Run__006.png": "da5f14b8b96b5d7f76de159c623ed37e",
"assets/assets/images/Run__007.png": "4855c1af470a5272fac9c807568f3236",
"assets/assets/images/Run__008.png": "3f9e01085f521f8c9c0bcbed7156d7a2",
"assets/assets/images/Run__009.png": "f47bbab827b20bde1e846a03e5ac9f11",
"assets/assets/images/Zombiz1.png": "676a5ba3c243f412580614aa58d979d4",
"assets/assets/images/Zombiz2.png": "39405be618492982a5755e97755c7f1b",
"assets/assets/images/Zombiz3.png": "6ae6756fe3ba5f85e2e868526ff0e60a",
"assets/assets/images/Zombiz4.png": "cbbe37daffc26d26088a8c0255d4dec7",
"assets/assets/images/Zombiz5.png": "31a0b3b6542eb7f646025aee952697ad",
"assets/assets/images/Zombiz6.png": "192f80427d71910606f1ed832d0d847d",
"assets/assets/images/Zombiz7.png": "cfb892b75be55cc5c9bd60af1cd0a6a9",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "bb318d7d6c295488c0a93daf0d38f3c9",
"assets/NOTICES": "d9ece44036a09c0d4aa5c39fcb640146",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "5f72d664707e4d711a1c0c240912cd50",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "eae12c7720895aa5268e3d9fac389d81",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "9117d05feb16d47ff94f7466068deef2",
"icons/Icon-192.png": "eae12c7720895aa5268e3d9fac389d81",
"icons/Icon-512.png": "eae12c7720895aa5268e3d9fac389d81",
"icons/Icon-maskable-192.png": "eae12c7720895aa5268e3d9fac389d81",
"icons/Icon-maskable-512.png": "eae12c7720895aa5268e3d9fac389d81",
"index.html": "33f1d26601573040aa62db6cc1ef8cad",
"/": "33f1d26601573040aa62db6cc1ef8cad",
"main.dart.js": "7b9a187cbf2053e5176fb534ca4dc756",
"manifest.json": "283129579d69eed497aa8d3d8da7f134",
"version.json": "88fe7e241640feadb7e946e4276493e8"};
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
