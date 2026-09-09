// Аналог services/prefs.dart, но на базе localStorage (веб/десктоп в браузере)
const KEY_PREFIX = 'metallcalc:';

function safeGet(key) {
  try {
    return localStorage.getItem(KEY_PREFIX + key);
  } catch {
    return null;
  }
}

function safeSet(key, value) {
  try {
    localStorage.setItem(KEY_PREFIX + key, value);
  } catch {
    // ignore (e.g. private mode / storage disabled)
  }
}

export const prefs = {
  getString: (key) => safeGet(key),
  setString: (key, value) => safeSet(key, value),
};
