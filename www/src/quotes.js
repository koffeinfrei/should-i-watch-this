import quotesAfi from "./quotes-afis-100.json";
import quotesLifehack from "./quotes-lifehack-25.json";
import { getUrl } from "./getUrl";

let quotes = [...quotesAfi, ...quotesLifehack];

quotes.forEach((quote) => {
  quote.url = getUrl({ title: quote.movie, year: quote.year });
});

export function getRandomQuote() {
  return quotes[Math.floor(Math.random() * quotes.length)];
}
