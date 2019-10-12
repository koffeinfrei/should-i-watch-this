export async function fetchMovie(title, year) {
  if (!title) {
    return { error: 'Hmm? I think you forgot to enter the movie title.' };
  }

  const url = 'http://openfaas.koffeinfrei.org:31112' +
    '/function/should-i-watch-this-www' +
    `?show_links=true&year=${year}`;

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
      'X-Auth-Token': ''
    },
    body: title
  });

  return await response.json();
}
