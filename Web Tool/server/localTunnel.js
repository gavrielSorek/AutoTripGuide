const localtunnel = require('localtunnel');

(async () => {
  const tunnel = await localtunnel({ port: 5500 , subdomain: 'autotripguide'});

  // the assigned public url for your tunnel
  // i.e. https://abcdefgjhij.localtunnel.me
  tunnel.url;
  console.log(tunnel.url)

  tunnel.on('close', () => {
      console.log('tunnel closed')
    // tunnels are closed
  });
})();