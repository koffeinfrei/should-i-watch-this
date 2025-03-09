export function getUrl(movie) {
  return `/${encodeURIComponent(movie.title)}/${movie.year}`;
}
