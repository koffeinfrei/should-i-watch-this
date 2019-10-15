export async function fetchMovie(title, year) {
  if (!title) {
    return { error: 'Hmm? I think you forgot to enter the movie title.' };
  }

  const url = 'https://faas.koffeinfrei.org' +
    '/function/should-i-watch-this' +
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
