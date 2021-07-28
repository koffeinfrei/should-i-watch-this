export async function fetchMovie(title, year, fetchFunction) {
  if (!title) {
    return { error: "Hmm? I think you forgot to enter the movie title." };
  }

  const url =
    "https://faasd.koffeinfrei.org" +
    "/function/should-i-watch-this-free" +
    `?show_links=true&year=${year}`;

  const response = await fetchFunction(url, {
    method: "POST",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: title,
  });

  return await response.json();
}
