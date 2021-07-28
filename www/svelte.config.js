import vercel from "@sveltejs/adapter-vercel";
import preprocess from "svelte-preprocess";

/** @type {import('@sveltejs/kit').Config} */
const config = {
  kit: {
    target: "body",
    adapter: vercel(),
  },
  preprocess: preprocess(),
};

export default config;
