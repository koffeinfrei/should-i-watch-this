export function setUrl(movie) {
  location.hash = `/${encodeURI(movie.title)}/${movie.year}`;
}

export function getMovieFromUrl() {
  const [_, titleFromUrl, yearFromUrl] = location.hash.split(/\//);

  if (!titleFromUrl) {
    return {};
  }

  return {
    yearFromUrl,
    titleFromUrl: decodeURI(titleFromUrl)
  }
}
