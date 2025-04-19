/**
 * Dota Companion A/B Testing Worker
 * 
 * This Cloudflare Worker enables A/B testing for the Dota Companion app.
 * It assigns users to different experiment groups and maintains consistent
 * group assignments using cookies.
 */

// Experiment configuration
const EXPERIMENTS = {
  'ui-design': {
    variants: ['control', 'new-design'],
    weights: [0.5, 0.5], // 50/50 split
  },
  'coach-voice': {
    variants: ['default', 'calm', 'excited'],
    weights: [0.4, 0.3, 0.3], // 40/30/30 split
  }
};

// Cookie settings
const COOKIE_SETTINGS = {
  name: 'dota-companion-experiments',
  maxAge: 30 * 24 * 60 * 60, // 30 days
  path: '/',
  secure: true,
  httpOnly: true,
  sameSite: 'Strict'
};

// Main request handler
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request));
});

/**
 * Handle incoming requests
 * @param {Request} request - The incoming request
 * @returns {Response} - The modified response
 */
async function handleRequest(request) {
  // Parse the URL and get experiment name
  const url = new URL(request.url);
  const pathParts = url.pathname.split('/');
  const experimentName = pathParts[2]; // /experiment/{name}/...
  
  if (!experimentName || !EXPERIMENTS[experimentName]) {
    return new Response('Experiment not found', { status: 404 });
  }
  
  // Get or create user experiments
  const experiments = getUserExperiments(request);
  
  // Assign variant if user doesn't have one for this experiment
  if (!experiments[experimentName]) {
    experiments[experimentName] = assignVariant(experimentName);
  }
  
  // Fetch the original response
  const response = await fetch(request);
  const newResponse = new Response(response.body, response);
  
  // Set the cookie with updated experiments
  newResponse.headers.set('Set-Cookie', createCookie(experiments));
  
  // Add experiment info to response headers
  newResponse.headers.set('X-Experiment-Variant', experiments[experimentName]);
  
  return newResponse;
}

/**
 * Get user experiments from cookies
 * @param {Request} request - The incoming request
 * @returns {Object} - User experiment assignments
 */
function getUserExperiments(request) {
  const cookies = parseCookies(request.headers.get('Cookie') || '');
  
  if (cookies[COOKIE_SETTINGS.name]) {
    try {
      return JSON.parse(atob(cookies[COOKIE_SETTINGS.name]));
    } catch (e) {
      // Invalid cookie, return empty experiments
    }
  }
  
  return {};
}

/**
 * Assign a variant for an experiment based on weights
 * @param {string} experimentName - The name of the experiment
 * @returns {string} - The assigned variant
 */
function assignVariant(experimentName) {
  const experiment = EXPERIMENTS[experimentName];
  const random = Math.random();
  let cumulativeWeight = 0;
  
  for (let i = 0; i < experiment.variants.length; i++) {
    cumulativeWeight += experiment.weights[i];
    if (random < cumulativeWeight) {
      return experiment.variants[i];
    }
  }
  
  // Fallback to first variant
  return experiment.variants[0];
}

/**
 * Create a cookie string with experiment assignments
 * @param {Object} experiments - User experiment assignments
 * @returns {string} - The cookie string
 */
function createCookie(experiments) {
  const value = btoa(JSON.stringify(experiments));
  const expires = new Date(Date.now() + COOKIE_SETTINGS.maxAge * 1000).toUTCString();
  
  return `${COOKIE_SETTINGS.name}=${value}; ` +
         `Expires=${expires}; ` +
         `Path=${COOKIE_SETTINGS.path}; ` +
         `${COOKIE_SETTINGS.secure ? 'Secure; ' : ''}` +
         `${COOKIE_SETTINGS.httpOnly ? 'HttpOnly; ' : ''}` +
         `SameSite=${COOKIE_SETTINGS.sameSite}`;
}

/**
 * Parse cookies from a cookie header
 * @param {string} cookieHeader - The Cookie header value
 * @returns {Object} - Parsed cookies
 */
function parseCookies(cookieHeader) {
  const cookies = {};
  
  if (cookieHeader) {
    cookieHeader.split(';').forEach(cookie => {
      const parts = cookie.trim().split('=');
      if (parts.length === 2) {
        cookies[parts[0]] = parts[1];
      }
    });
  }
  
  return cookies;
}
