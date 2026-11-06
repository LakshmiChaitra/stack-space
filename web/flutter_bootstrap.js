{{flutter_js}}
{{flutter_build_config}}

(async () => {
  // Retire only this app's legacy worker. Never clear browser workspace storage.
  if ('serviceWorker' in navigator) {
    try {
      const scope = new URL('.', document.baseURI).href;
      const registration = await navigator.serviceWorker.getRegistration(scope);
      const worker = registration?.active || registration?.waiting || registration?.installing;
      const legacyUrl = new URL('flutter_service_worker.js', scope);
      if (registration?.scope === scope && worker &&
          new URL(worker.scriptURL).pathname === legacyUrl.pathname) {
        await registration.unregister();
      }
    } catch (error) {
      console.warn('Could not retire the legacy app cache.', error);
    }
  }
  _flutter.loader.load();
})();
