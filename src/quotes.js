import quotes from './quotes-afis-100.json';
import { getUrl } from './getUrl';

quotes.forEach(quote => {
  quote.url = getUrl({ title: quote.movie, year: quote.year });
});

export function getRandomQuote() {
  return quotes[Math.floor(Math.random() * quotes.length)];
}
